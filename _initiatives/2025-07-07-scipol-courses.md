---
layout: gridlay
title: "Science Policy Courses"
excerpt: "Learn more about our scipol courses!"
collection: initiatives
category: upcoming
date: 2025-05-05
permalink: /initiatives/scipol-courses
---

<h2>Science Policy Courses</h2>

Placeholder for now.

<ul>
  <li>One.</li>
  <li>Two.</li>
  <li>Three.</li>
</ul>

<div class="jumbotron">
  <h2>Press Mentions</h2>
  <ul>
    {% for article in site.data.press %}
      {% if article.category == 'SciPol Courses' %}
        <li>
          <p><b>{{ article.date | date: '%b %d, %Y' }}:
        <a href="{{ article.website }}">{{ article.headline }}</a> in {{ article.source }}</b></p>
        </li>
      {% else %}
        <p><b>None yet! Check back soon for updates!</b></p>
      {% break %}
      {% endif %}
    {% endfor %}
  </ul>
</div>