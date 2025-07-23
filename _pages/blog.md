---
title: "Blog"
layout: page
sitemap: false
permalink: /blog/
---

<ul>
  {% for post in site.posts %}
    <li>
      <h3>{{ post.date | date_to_string }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title}}</a></h3>
    </li>
  {% endfor %}
</ul>
