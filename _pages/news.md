---
title: "News"
layout: gridlay
sitemap: false
permalink: /news/
---

## News

<ul>
  {% for post in site.news reversed %}
    <li>
      <p>{{ post.date | date: '%b %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></p>
    </li>
  {% endfor %}
</ul>
