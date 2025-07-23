---
title: "Press Mentions"
layout: page
sitemap: false
permalink: /news/
---

<ul>
  {% for post in site.news reversed %}
    <li>
      {{ post.date | date: '%b %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}"><h2>{{ post.title }}</h2></a>
    </li>
  {% endfor %}
</ul>
