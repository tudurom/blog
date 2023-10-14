---
layout: post
title: "Postmodern Command Line Tools"
date: 2023-10-12T20:23:29+02:00
category: technical
---

The standard UNIX command line tools are still enjoying a multi-decade-long reign,
whether we're talking about the bare-bones `echo` and `cat`, the familiar `ls`,
`date` and `cal` (I can't be the only one who's still using `cal`, right?),
the weirdly-named text processing utilities `tr`, `sed`, `cut`, `grep` and
their main nemesis, `awk`, or the ubiquitous text editors, `vi` and the 30+ year old Vi IMproved.

Here are a couple "postmodern" CLI and TUI tools I like to use. They are mainly
alternatives to the well-established tools that try to take on trivial problems,
like string processing, finding files, looking for strings in files and so on.

These tools have a couple things in common, such as:

* Trying to look good in the terminal emulator, with pretty colours and icons,
yet allowing for easy integration with other tools.
* Rarely written in C.
* Opinionated defaults, usually inspired from experiences with the established tools.

## fd

[fd's webpage](https://github.com/sharkdp/fd).

I don't know about you but I cannot remember for the love of what's holy `find`'s flags.
It also grinds my gears heavily that it doesn't automatically ignore files declared in `.gitignore`,
although `find` was made when `git`'s creator was a toddler.

`fd`, when supplied with an argument, does what you probably want to do most of the time
when looking for files in a directory: look for any files that contain a pattern in the filename.
And it does that with pretty colours! It respects `LS_COLORS` even, so the colours have meaning!

Another nicety is that it uses [Rust's regex library][regex-crate].
GNU Find offers many regex types, which can be quite confusing. Run `find -regextype help` to see them all.

Example usage, finding all Markdown files in the blog's source code repo:

```shell
$ fd .md$
404.md
README.md
_posts/2021-01-24-the-wayland-experience.md
_posts/2023-08-29-modern-shell-tools.md
_posts/2023-09-11-low-tech.md
about.md
index.md
technical.md
writing.md
```

You can find it in your package manager probably: `rust-fd-find` in Fedora, Ubuntu, and EPEL; `fd` in Nixpkgs.
[Repology][repology-fd].

[regex-crate]: https://docs.rs/regex/latest/regex/
[repology-fd]: https://repology.org/project/fd-find/versions

## sd

[sd's webpage](https://github.com/chmln/sd).

`sd` is a lesser-known postmodern alternative to `sed`. It simplifies greatly the most common
use case for `sed` (to replace and extract data), and also uses Rust regexes (no more `sed -E`).
The examples also show nice ways to use it together with `fd`.

Example usage:

```shell
# -f i stands for `flags: case insensitive'
$ sd -f i emacs VIM file.txt
# sd does by default in-place substitution, so this will print nothing.
# we can do, however, the following
$ sd -f i -p emacs VIM file.txt
The original VIM did not have Lisp in it. The lower level language, the non-interpreted language—was PDP-10 Assembler.
The interpreter we wrote in that actually wasn't written for VIM, it was written for TECO.
```

_Text fragment taken from [here](https://www.gnu.org/gnu/rms-lisp.html)_.

This one is also available in the repositories of some popular distros: `rust-sd` for Fedora and Ubuntu (but no EPEL);
`sd` in Nixpkgs. [Repology][repology-sd].

[repology-sd]: https://repology.org/project/sd-find-replace/versions

## Helix

[Helix's webpage](https://github.com/helix-editor/helix).

Currently my text editor of choice. It's a modal text editor, like {neo,}vim,
but it sacrificies extensibility (no plugin support!) for natively implementing
various niceties, such as:

* Tree-sitter integration: syntax highlighting and text object manipulation,
* Language Server Protocol support,
* Nice command navigation: press space and see what other keys you can hit to do various things. Press, for example, `w` and you are presented window manipulation functions,
* Fuzzy file and buffer selector, and more.

It's also heavily inspired by [Kakoune][kak] in the way commands are used:
first you press the key that selects the text object you operate on, and then the action (unlike Vim that does it in reverse).
So, if I want to change the next word, I'd press `wc`. After pressing `w`, the selection is also highlighted.

This one is not as widely-available in distro repositories (yet), but it's easy to install
if you happen to have the Rust toolset installed. [Repology][repology-helix].

[kak]: https://github.com/mawww/kakoune
[repology-helix]: https://repology.org/project/helix/versions

## Nushell

[Nushell's webpage](https://www.nushell.sh/).

I like to describe Nushell as "what if you take Powershell's object oriented everything approach, but you apply it to UNIX".
Instead of using objects, Nushell operates on tables made of records reminescent of JSON's data types.
You have mostly lists, key-value hash tables, numbers, strings, and booleans, plus a couple specific data types like
date, filesize, durations, but also ranges and closures.

What I really like about Nu is that it strives to make all of this cross-platform.
The idea is that you learn once the Nu language and commands, and you use them on all these systems in a portable manner.
So, no platform-specific `ls` flags for example. Of course, this also means that Nu tries to avoid platform-specific commands in the first place.

Besides coming with a very nice command language, it comes with many other niceties,
such as a help system that has syntax highlighted examples and example outputs (for example, type `help ls`),
a command search mode (after typing a pipe, you can press <kbd>F1</kbd> and a menu pops up with a command search and small help overview),
syntax highlighted commands as you type, and quite decent completion.

There aren't many completion definitions for all the other "normal" commands you may use,
but you can easily declare completers in your config, such as [using Fish as a completer][fish-as-completer].
Fish comes with stellar completion support, so now Nu does too!

Many string processing (and not only) tools can feel obsolete when using Nu, which
comes with its own _typed_ functions and function programming-esque constructs.
The `sd` utility named above, for example, is built in, in the form of `str replace`.
We can run `help str replace` and we get a nice coloured, and syntax highlighted, help
page right in the terminal. All these help pages are [also on the website](https://www.nushell.sh/commands/docs/str_replace.html).

[fish-as-completer]: https://www.nushell.sh/cookbook/external_completers.html#fish-completer

Go ahead and try it out!
