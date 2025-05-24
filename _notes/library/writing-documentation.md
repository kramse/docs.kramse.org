---
title: Writing Documentation 🌱
category: learning
---


## Writing Documentation 🌱

So you want to learn something, then make notes! There are many benefits from writing things down and usually people will remember better what they learn. Other times you will need to persuade someone to do something, or you have created something - a program or system that others will need to interact with.

So documentation is needed, but how?!

First I will present a few options for tools to do the writing in, which are the ones I use:

* MarkDown is an easy to learn writing method which is great for short notes, but can be used for complete books
* LaTeX is originally from *academic cirles* and seldom used in commercial enterprises. Takes some effort to learn, but shines when you create big documents or interlinked document. It can feel like you are programming the output, which is not far from reality

Afterwards you will need to find ways to structure your writing, and that will probably be dependent on the materials you aim to produce. Examples include

* Writing documentation for software projects may want to use a resource such as *Docs for Developers*  by Jared Bhatti, Sarah Corleissen, Jen Lambourne, David Nuñez, Heidi Waterhouse [https://docsfordevelopers.com/](https://docsfordevelopers.com/)

### Writing MarkDown

> Markdown[9] is a lightweight markup language for creating formatted text using a plain-text editor. John Gruber created Markdown in 2004 as an easy-to-read markup language.[9] Markdown is widely used for blogging and instant messaging, and also used elsewhere in online forums, collaborative software, documentation pages, and readme files.

Source: [https://en.wikipedia.org/wiki/Markdown](https://en.wikipedia.org/wiki/Markdown)

You can write MarkDown in many ways, and you will need something like a text editor

Some example text, formatted:

#### H4 small header, rest of this note is H3

**this is bold**, and ~~strike through~~ with *italic* on the side

The same, as MarkDown, copy pasted the above line:
<pre>
  #### H4 small header, rest of this note is H3

  **this is bold**, and ~~strike through~~ with *italic* on the side
</pre>

There are afterwards multiple options for converting this MarkDown into PDF or HTML. My editor has a package for doing MarkDown to PDF, but [pandoc](https://pandoc.org/) is a recommended generic tool.

I have a small script called `markdown2pdf`:
<pre>
  #! /bin/sh
  DOCUMENT=$1
  pandoc $DOCUMENT.md -o $DOCUMENT.pdf --pdf-engine=xelatex --template=eisvogel-hlk.latex
</pre>

It uses this template: [https://github.com/enhuiz/eisvogel](https://github.com/enhuiz/eisvogel) and LaTeX for producing the PDF.

### Writing LaTeX

I was introduced to LaTeX during my years of studying computer science at DIKU, and loved it ever since. While more complex than MarkDown it provides more or less full control over the written page! You can also create beautiful documents with a little bit of effort.

The standard look is well known across academia and will signal, I use LaTeX. If you dont want that there are also lots of options to find other styles, document formatting ready for everything from music publishing to book publishing.

I will recommend two options:
* [Overleaf](https://www.overleaf.com/) which is *a collaborative, online LaTeX editor that anyone can use.* Actually quite easy to get started and they have great documentation. Try it!
* [TeX Live](https://www.tug.org/texlive/) from the Tex User Group is a great system for installation on your local PC. I have used it for many many years! I found an email from the danish TUG chapter about sending me the CD for TeX Live 2005 in my archive.

Examples of my use of LaTeX can be found in my repository of all my teaching materials [security courses repository](https://codeberg.org/kramse/security-courses)
