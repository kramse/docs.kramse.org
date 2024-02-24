---
layout: page
title: Home
id: home
permalink: /
---

# Welcome! 🌱




<strong>Recently updated notes</strong>

<ul>
  {% assign recent_notes = site.notes | sort: "last_modified_at_timestamp" | reverse %}
  {% for note in recent_notes limit: 5 %}
    <li>
      {{ note.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}.html">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>

## How was this made
The concept of digital garden has existed for some time, and it resonates with me.

This digital garden template is free, open-source, and [available on GitHub here](https://github.com/maximevaillancourt/digital-garden-jekyll-template).

There are some instructions below which I keep for my own use, pls ignore.

* The easiest way to get started is to read this [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll).


<style>
  .wrapper {
    max-width: 46em;
  }
</style>
