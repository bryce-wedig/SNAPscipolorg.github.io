---
title: "Newsletters"
layout: gridlay
sitemap: false
permalink: /newsletters/
---

## Newsletters

<p>What to keep up with SNAP's latest updates? <a href = "https://docs.google.com/forms/d/e/1FAIpQLSclm6qDeLHbwRk4QPuZR34x77xx5dlKz3tHuHitBdWAiWe5vg/viewform">Sign up</a> for our newsletter! You can also read all our past newsletters below:</p>

<ul>
  {% for post in site.newsletters reversed %}
    <li>
      <p>{{ post.date | date: '%b %d, %Y' }}: <a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></p>
    </li>
  {% endfor %}
</ul>
