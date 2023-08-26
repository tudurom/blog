---
title: About this blog
menu_title: About
layout: page
---

[About me](/whoami/).

I learned many, many great things from different people's
blogs, so I decided that I should write a blog too, to show
the world what I do and do not know. I hope that this blog will be helpful
to you.

### Tech behind this website

Because I am a tech person and I expect some tech persons
to read this, here are the specs:

* Home server - Cheap and tiny Dell PC. It runs NixOS.
* Web server - Nginx, configured with NixOS.
* Site magic - [Good ol' Jekyll](https://jekyllrb.com/).
  I tried rolling [my own blog generator][1] with shell scripts, but it felt "fragile", so I started using Jekyll, which is a mature piece of software. 
  In `$CURRENT_YEAR` it might be considered old-fashioned, but it works. The theme I use is a modification of [vida](https://github.com/syaning/vida/).

For legacy reasons, my main website is based on a handwritten static site generator I made in less than a day some years ago: 
[orator](https://github.com/tudurom/orator/).

[1]: https://github.com/tudurom/tudurom.github.io/blob/e949788588f58c8cd26ed63a97fbfebf1e5a3401/blog/build/build.sh
