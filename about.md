---
title: About this blog
menu_title: About
layout: page
---

[About me](/whoami/).

I learned many, many great things from [different people's
blogs](/res/#people), so I decided that I should write a blog too, to show
the world what I know and I don't know. I hope that this blog will be helpful
to you.

Here I will write mostly about computing, especially about Linux/UNIX and
programs that I use/made.

### Tech behind this website

* Home server - Cheap and tiny Dell PC.
	It runs NixOS. Post about it soon!
* Web server - Nginx. I preferred my old setup with [OpenBSD relayd and httpd](https://bsd.plumbing). Nginx is still pretty simple to use.
* Site magic - [Jekyll](https://jekyllrb.com/) and [markdown](https://daringfireball.net/projects/markdown/). I tried rolling [my own blog generator][1] with shell scripts, but it felt "fragile", so I started using Jekyll, which is a mature piece of software. The theme I use is a modification of [vida](https://github.com/syaning/vida/).

Hopefully I will write an article about this blog. BTW I'm using a different
static site generator for my main site. That's
[orator](https://github.com/tudurom/orator/), written by me in
[Go](http://golang.org/) (I should write an article about that too...).

[1]: https://github.com/tudurom/tudurom.github.io/blob/e949788588f58c8cd26ed63a97fbfebf1e5a3401/blog/build/build.sh
