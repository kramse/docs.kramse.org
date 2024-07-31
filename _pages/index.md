---
layout: page
title: Home
id: home
permalink: /
---

# Welcome! 🌱

This is the digital garden of Kramse.

My real name is Henrik Kramselund and I live in a town close to water called Hundested in Denmark.

Subjects and articles:
* [[Welcome to Kubernetes]]
* [[Homegrown Digital Garden using Kubernetes]]

Various links to the concept of Digital Garden

* [A Brief History & Ethos of the Digital Garden](https://maggieappleton.com/garden-history)
* Mark Bernstein's 1998 essay [Hypertext Gardens](http://www.eastgate.com/garden/Enter.html)
* Digital Gardens by Matthias @CSSence on the site [https://cssence.com/](https://cssence.com/2024/digital-gardens/)
* This digital garden template is free, open-source, and [available on GitHub here](https://github.com/maximevaillancourt/digital-garden-jekyll-template).

There are some instructions below which I keep for my own use, pls ignore.

* The easiest way to get started is to read this [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll).

<strong>Recently updated notes</strong>

<ul>
  {% assign recent_notes = site.notes | sort: "last_modified_at_timestamp" | reverse %}
  {% for note in recent_notes limit: 5 %}
    <li>
      {{ note.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}.html">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>


<style>
  .wrapper {
    max-width: 46em;
  }
</style>
