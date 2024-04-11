---
layout: page
title: Home
id: home
permalink: /
---

# Welcome! 🌱

This is the digital garden of Kramse.

My real name is Henrik Kramselund and I live in Denmark.

Subjects and articles:
* [[Welcome to Kubernetes]]


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
