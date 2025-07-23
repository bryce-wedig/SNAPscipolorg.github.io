---
title: "Press Mentions"
layout: page
sitemap: false
permalink: /news/
---

<ul>
  {% for post in site.news %}
    <li>
      {{ post.date | date: '%B %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title}}</a>
    </li>
  {% endfor %}
</ul>
