---
title: "Newsletters"
layout: gridlay
sitemap: false
permalink: /newsletters/
---

## Newsletters

<p>What to keep up with SNAP's latest updates? Sign-up for our newsletter! You can also read all our past newsletters below:</p>

<ul>
  {% for post in site.newsletters reversed %}
    <li>
      <p>{{ post.date | date: '%b %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></p>
    </li>
  {% endfor %}
</ul>
