---
layout: page
title: Home
id: home
permalink: /
---

# Welcome! 🌱

This is the digital garden of Kramse. You can call it a blog, but it does not follow the usual reverse time line article posting. It is more chaotic, but there are some navigation available to find your way. Have fun :-D

My real name is Henrik Kramselund and I live in a town close to water called Hundested in Denmark.

My subjects and articles:
* [[Welcome to Kubernetes 🌱]]
* [[Homegrown Digital Garden using Kubernetes 🌱]]
* [[Welcome to the Library 🌱]]

My article categories:
* [Kubernetes](/kubernetes/kubernetes.html)
* [Learning Library](/library/learning.html)

# My public Git repositories
Maybe you can find something interesting in Github og Codeberg where I put all my educational materials, most of my public projects etc.

* [https://codeberg.org/kramse](https://codeberg.org/kramse)
* [https://github.com/kramse](https://github.com/kramse)

I am in the process of testing [Codeberg](https://codeberg.org/) and moving stuff away from Github. The main reason is that they are pushing hard for AI products, based on source and code from peoples repositories.

# What is a Digital Garden
The concept of digital garden has existed for some time, and it resonates with me. Various links to the concept of Digital Garden that will be much better at explaining it:

* [A Brief History & Ethos of the Digital Garden](https://maggieappleton.com/garden-history)
* Mark Bernstein's 1998 essay [Hypertext Gardens](http://www.eastgate.com/garden/Enter.html)
* Digital Gardens by Matthias @CSSence on the site [https://cssence.com/](https://cssence.com/2024/digital-gardens/)
* This digital garden template is free, open-source, and [available on GitHub here](https://github.com/maximevaillancourt/digital-garden-jekyll-template).

I will try to remember to mark articles with the current matureness level, as described in the post
[A Brief History & Ethos of the Digital Garden](https://maggieappleton.com/garden-history):
> ## 3. Imperfection & Learning in Public
...
* 🌱 Seedlings for very rough and early ideas
* 🌿 Budding for work I've cleaned up and clarified
* 🌳 Evergreen for work that is reasonably complete (though I still tend these over time).


<strong>Recently updated notes</strong>

<ul>
  {% assign recent_notes = site.notes | sort: "last_modified_at_timestamp" | reverse %}
  {% for note in recent_notes limit: 5 %}
    <li>
      {{ note.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}.html">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>

<strong>Setup notes</strong>

Below are some instructions below which I keep for my own use, pls ignore. These are part of the system I use to maintain the garden.

* The easiest way to get started is to read this [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll).

<style>
  .wrapper {
    max-width: 46em;
  }
</style>
