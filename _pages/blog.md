---
title: "Blog"
layout: gridlay
sitemap: false
permalink: /blog/
---

## Blog

SNAP hosts our blog on Medium through our publication [Science Policy in a SNAP](https://medium.com/science-policy-in-a-snap)! Follow both the publication page and [SNAP's page](https://medium.com/@snapscipolorg) on Medium to get notified whenever we publish a new blog post!

<ul>
  {% for post in site.posts %}
    <li>
      <p>{{ post.date | date_to_string }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></p>
    </li>
  {% endfor %}
</ul>
