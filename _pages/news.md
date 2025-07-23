---
title: "Press Mentions"
layout: page
sitemap: false
permalink: /news/
---

<ul>
  {% for post in site.news reversed %}
    <li>
      <h2>{{ post.date | date: '%b %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h2>
    </li>
  {% endfor %}
</ul>
