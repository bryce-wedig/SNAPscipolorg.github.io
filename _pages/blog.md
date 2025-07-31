---
title: "Blog"
layout: gridlay
sitemap: false
permalink: /blog/
---

## Blog

<ul>
  {% for post in site.posts %}
    <li>
      <p>{{ post.date | date_to_string }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title}}</a></p>
    </li>
  {% endfor %}
</ul>
