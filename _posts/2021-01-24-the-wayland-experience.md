---
layout: post
title: "Should You Write a Wayland Compositor?"
date: 2021-01-26 10:59:23+02:00
category: technical
---

[Wayland](https://wayland.freedesktop.org/) is the "new" (13 years old already) display server technology on Linux, which is supposed to replace
the antiquated X11. It promises better security, performance, portability, everything, compared to X11, and
it sure does deliver, provided that you're not using [unsupported graphics cards](https://www.nvidia.com/).
You can watch [this talk / rant about X11](https://www.youtube.com/watch?v=RIctzAQOe44) to get an idea about how bad it is.

Some power users also haven't switched to Wayland because their gimmicky window manager doesn't have a
Wayland equivalent (XMonad, Awesome, Bspwm and the others). Some may wonder "hmm maybe I can port it myself". I wrote this post to make you (re)consider that.

One of the main ideas of Wayland is that it's merely a specialised IPC protocol, and the communication is
strictly between the clients (applications on your screen mainly) and the server.

The server is what we are interested in now. Unlike X11, where the server is X.Org and the window manager
is just an X11 client with special privileges, on Wayland the window manager is also a server and a compositor. In fact, the correct terminology is "Wayland compositor". This piece of software has the
task of doing everything it wants with the clients, which is usually among the lines of showing them
on the screen and giving them inputs events from your keyboards, mice, touchscreens etc. In fact, [no one
stops you from leaving window management as an API](https://mir-server.io/).

On my laptop, I prefer using GNOME under Wayland, because it has the most stable, fully-featured and "just works"
experience there is. However, I wanted a better way of organising windows on my screen than leaving them
shuffled around. Tiling was also not good, because every time you launch a new window, the others get
shrunk to fit, which is not good on a small laptop display.

Luckily I discovered [PaperWM](https://github.com/paperwm/PaperWM). It's perfect for laptops, instead of
shrinking your windows, it just renders them off-screen. To switch between one or the other you can just
flick three fingers on the touchpad. It's great. It's also "glossy" and polished and has great UI and animations.

It has some disadvantages though, mainly concerning its speed. I find it sluggish, and it's no surprise that
like all other GNOME Shell extensions, it's a JavaScript behemoth. PaperWM still uses the GNOME Tweener
framework for its animations, which is entirely written in JS. Because of that, it needs to communicate with the main
GNOME compositor process on each operation. And because we're talking animations, said operations happen
for *every frame*. That means there is JS executed for every frame, 60 times a second. It's horrible!

BTW nowadays GNOME uses animations implemented in C (since GNOME 3.34), the "GNOME runs JS on every frame" statement is for the most part false today.

Because of the inefficiency of PaperWM, it also means that it drains my battery quickly, which is bad for a laptop!

So, because I am a student with a lot of free time, together with [Alex](https://alexge50.com/) we figured we shall develop a scrollable tiling (PaperWM-like) Wayland compositor. It's called [Cardboard](https://gitlab.com/cardboardwm/cardboard) (get it??). It also has the nicety of
being controlled and configured by a remote control program, like bspwm.
Neither Alex nor I had experience with any kind of Wayland development. However, I wrote [an X11 window manager](https://tudorr.ro/software/windowchef/),
[some XRandR querying utilities](https://github.com/tudurom/disputils/) and [a window rule daemon](https://github.com/tudurom/ruler). Alex has experience
with [graphics programming](https://git.alexge50.com/a/gie) and [C++ devilry](https://github.com/alexge50/libwatchpoint).

Our "tech stack" was [wlroots](https://github.com/swaywm/wlroots), which is an exceptional Wayland compositor library (apart from its lack of documentation). The description from the README is spot on:

>About 50,000 lines of code you were going to write anyway.

I (because I wrote most of the Wayland-interfacing code) realised soon that there is still a lot of boilerplate involved in writing a compositor, much more than for an X11 window manager,
namely setting up your own rendering code, registering and storing input devices and screens in your own data structures, passing input events to windows, calculating bounds for bars
and other overlays (courtesy of [`layer-shell`](https://github.com/swaywm/wlr-protocols/blob/master/unstable/wlr-layer-shell-unstable-v1.xml)) and others. X11 handles all of this for you,
the window manager just reacts to events regarding window inputs to establish its behaviour. With Wayland, you handle everything, even with wlroots. The upside is that if you don't like the way X11 does something
(which is a given), not only that you can do it in your own way on Wayland, you are required to do so.

Because we weren't really prepared for what writing a compositor involved, we thought that it must be approached like a "normal" program: split code into modules, each with their own responsibilities, call wlroots to do its thing, the usual stuff.
We are writing a program in our way and wlroots lets us "interface with Wayland". Or so we thought.

We were as careful as possible to separate responsibilities into different structures / classes, yet we ended up with most functions taking a pointer to `Server` as their first parameter.
`Server` is a singleton holding all the other "sub-modules" in it. It represents the compositor itself. The reason most functions need `Server` is that everything is related to everything,
not because of a mistake in structuring the code, but by design. This is what a compositor requires, the problem of writing a compositor is somewhat complex because it has a great deal variables ranging
from input events, drawing on the screen, creating behaviours that the user leverages, reacting to application events. All of them can affect the other, you can not separate the thing into modules.
The best you can do is separate the code in different files and folders based on some criteria, like grouping data structures with related routines.

Excerpt from `Seat.h`:

```cpp
/// Hides the \a view from the screen without unmapping. Happens when a Workspace is deactivated.
void hide_view(Server& server, View& view);
/// Gives keyboard focus to a plain surface (OR xwayland usually)
void focus_surface(struct wlr_surface* surface);
/**
  * \brief Sets the focus state on \a view. Auto-scrolls the Workspace if it's tiled.
  *
  * If \a view is null, the previously focused view will be unfocused and no other view will be focused.
  */
void focus_view(Server& server, OptionalRef<View> view, bool condense_workspace = false);
/// Marks the layer as receiving keyboard focus from this seat.
void focus_layer(Server& server, struct wlr_layer_surface_v1* layer);
/**
  * \brief Focus the most recently focused view on \a column.
  *
  * \param column - must be from this workspace
  */
void focus_column(Server& server, Workspace::Column& column);
/// Removes the \a view from the focus stack.
void remove_from_focus_stack(View& view);

void begin_move(Server& server, View& view);
void begin_resize(Server& server, View& view, uint32_t edges);
void begin_workspace_scroll(Server& server, Workspace& workspace);
void process_cursor_motion(Server& server, uint32_t time = 0);
void process_cursor_move(Server&, GrabState::Move move_data);
void process_cursor_resize(Server&, GrabState::Resize resize_data);
void process_swipe_begin(Server& server, uint32_t fingers);
void process_swipe_update(Server& server, uint32_t fingers, double dx, double dy);
void process_swipe_end(Server& server);
void end_interactive(Server& server);
void end_touchpad_swipe(Server& server);

/// Updates the scroll of the workspace during three-finger swipe, taking in account speed and friction.
void update_swipe(Server& server);

/// Returns true if the \a view is currently in a grab operation.
bool is_grabbing(View& view);

/// Returns the workspace under the cursor.
OptionalRef<Workspace> get_focused_workspace(Server& server);

/// Moves the focus to a different workspace, if the workspace is already on a monitor, it focuses that monitor
void focus(Server& server, Workspace& workspace); // TODO: yikes, passing Server*
```

As an example, let's take damage tracking. For starters, because the compositor is also tasked with rendering the content and displaying it on the screen, we have some rendering code that runs on every frame.
Damage tracking is tracking which areas of the screen have changed in an amount of time. An example would
be typing a letter in the terminal. The place where the cursor is changes to the letter you typed, and the cursor advances.
If there is no change, the frame is not rendered, as it would look
exactly the same as the previous one, which would be a waste of processor time.
This way, instead of re-rendering everything 60 times a second (I assume that you use a common display), we can render and paint as little as possible to account for the changed region.
You can read [an introduction to damage tracking](https://emersion.fr/blog/2019/intro-to-damage-tracking/) written by one of the main developers of wlroots.

I have just implemented the most basic form of damage tracking: do not render the frame if nothing on the screen changes.
It doesn't track the damage itself, just that it exists.
To do this, I first added a `wlr_output_damage` object to my `Output` structure:

```diff
struct Output {
    struct wlr_output* wlr_output;
    struct wlr_output_damage* wlr_output_damage;
+   struct wlr_box usable_area;
    ...
```

This structure tracks the damage accumulated per-output, as rendering is also per-output (this means that you can use screens of different refresh rates, yay!). However, to make this initial attempt at
damage tracking easier, I decided to trigger rendering for all attached outputs. I added a `set_dirty()` function to the `OutputManager` class that does just that:

```cpp
void OutputManager::set_dirty()
{
    for (auto& output : outputs) {
        wlr_output_damage_add_whole(output.wlr_output_damage);
    }
}
```

This marks every output as entirely damaged, and as such triggers a render.

With this function set into place, I had to identify when does the "screen" change, namely when a window "commits" (changes its contents) and when a window is moved. The window move is one example
of the way everything is related to everything in the compositor. Before damage tracking, the `View::move()` (we call windows "views") method just changed the `x` and `y` fields of the `View` structures.
Now, a move must call a method of `OutputManager`, so we need to give that as a parameter. This is almost like giving `Server` as a parameter, as `OutputManager` is a singleton inside `Server`.

```diff
-void View::move(int x_, int y_)
+void View::move(OutputManager& output_manager, int x_, int y_)
{
    x = x_;
    y = y_;
+   output_manager.set_dirty();
}
```

That's when it hit me that wlroots is more of a framework and the compositor is one of its modules. Thinking that wlroots is an "interface to Wayland" is plain wrong, as the Wayland server is the
program that I am writing. The next refactor is going to make the `Server` instance global...

Now that we have a `wlr_output_damage` object in place and `set_dirty()` calls where they're needed, we only need to call the render function when `wlr_output_damage` tells us instead of
every `1/60` seconds:

```diff
@@ -46,11 +46,12 @@ void register_output(Server& server, Output&& output_)
    server.output_manager->outputs.emplace_back(output_);
    auto& output = server.output_manager->outputs.back();
    output.wlr_output->data = &output;
+   output.wlr_output_damage = wlr_output_damage_create(output.wlr_output);

    register_handlers(server,
                      &output,
                      {
-                         { &output.wlr_output->events.frame, Output::frame_handler },
+                         { &output.wlr_output_damage->events.frame, Output::frame_handler },
                          { &output.wlr_output->events.present, Output::present_handler },
                          { &output.wlr_output->events.commit, Output::commit_handler },
                          { &output.wlr_output->events.mode, Output::mode_handler },
```

This is not complete code for a basic damage tracking implementation with wlroots. You can see [the whole commit here](https://gitlab.com/cardboardwm/cardboard/-/commit/f2ef2ff076ddbbd23994553b8eff131f9bd0207f).

This is an example of how wlroots provides yet another "module" that we can use in the grand scheme of the compositor. `wlr_output_damage` accumulates damaged rectangles in time and even turns these
numerous small rectangles into a big one as an optimisation. It also calls the frame handler when it's needed, and this is not only just when something on the screen changed, but also when the underlying "backend"
of the compositor changes. The simplest situation is when the compositor starts: it needs to render an initial frame so the screen isn't pitch black.

All in all, I do not recommend writing your own compositor if you only want some gimmicky user interface.
In the X world there is a WM for every single way of window tiling plus a couple more. It doesn't work like
that with Wayland, you will spend more time implementing basic compositor duties than
on your compositor's unique features. Instead, if I were to rewrite Cardboard, I would rather do it
as a [Wayfire plugin](https://github.com/WayfireWM/wayfire/wiki/Plugin-architecture) or maybe as a KWin script. However, I think Wayfire is more "enthusiast-friendly", as it uses [protocols from
wlroots](https://github.com/swaywm/wlr-protocols) such as `layer-shell` (for panels, overlays and backgrounds), `gamma-control` (for Redshift), `screencopy` (for screenshots) and others,
allowing people to write tools that are not specific to the compositor.

Nevertheless, if you want to do it for the learning experience, I definitely recommend writing
a "full-fledged" compositor with wlroots, learning from other compositors ([Sway][sway],
[cage][cage], [Wayfire][wayfire], [hikari][hikari] and others; cage is the simplest, hikari second simplest) and from their creators on
IRC (`#sway-devel` on Freenode), they are very kind and knowledgeable.

There is also a [discussion about introducing a high-level scene API in wlroots](https://github.com/swaywm/wlroots/issues/1826). Maybe when it will arrive, I will change my opinion.

[sway]: https://github.com/swaywm/sway
[cage]: https://github.com/hjdskes/cage
[hikari]: https://hikari.acmelabs.space/
[wayfire]: https://github.com/WayfireWM/wayfire

Recommended lectures:
* [Writing a Wayland Compositor](https://drewdevault.com/2018/02/17/Writing-a-Wayland-compositor-1.html), by Drew DeVault, the author of Sway and wlroots
* [The Wayland Protocol Book](https://wayland-book.com/), also by Drew DeVault
* [The Wayland Protocol](https://wayland.freedesktop.org/docs/html/), the actual protocol (larger than the book)
* Posts from Simon Ser's blog, maintainer of Sway and wlroots:
  * [Writing a Wayland rendering loop](https://emersion.fr/blog/2018/wayland-rendering-loop/)
  * [Introduction to damage tracking](https://emersion.fr/blog/2019/intro-to-damage-tracking/)
  * [Wayland clipboard and drag & drop](https://emersion.fr/blog/2020/wayland-clipboard-drag-and-drop/)
* [The init routine of Wayfire](https://github.com/WayfireWM/wayfire/blob/cb7920187d2546ca375f00e7ef0a71d7a4995ba6/src/core/core.cpp#L173). GTK is rather picky when it comes to the order of advertised Wayland protocols.
Don't waste hours of your life trying to figure out whether you did something wrong, it's GTK...

Also, I suggest you write the compositor in either C, C++ or Zig (with [zig-wlroots](https://github.com/swaywm/zig-wlroots) or just doing your thing, Zig is C compatible).
See this article on why the [Rust bindings failed](http://way-cooler.org/blog/2019/04/29/rewriting-way-cooler-in-c.html).
