---
title: "Press Mentions"
layout: page
sitemap: false
permalink: /news/
---

<ul>
  {% for post in site.posts %}
    <li>
      {{ post.date | date_to_string }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title}}</a>
    </li>
  {% endfor %}
</ul>
