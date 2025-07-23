---
title: "Home"
layout: homelay
sitemap: false
permalink: /
---

## Welcome!

We are an international group of early-career scientists dedicated to mobilizing for large-scale initiatives and building capacity to bridge gaps between science and society. Our mission is to inspire and engage fellow scientists by establishing a peer network, developing and sharing resources, and instigating meaningful change.

<div class="container">
<div class="row" align="center">
<img src="{{ site.url }}{{ site.baseurl }}/images/logo.png" width="100%">
</div>
</div>

## Current Initiatives

<div class="aside">
  {% for post in site.initiatives %}
    {% if post.category == 'current' %}
      <h3><a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h3>
    {% endif %}
  {% endfor %}
</div>

### [Click here to learn more!]({{ site.url }}{{ site.baseurl }}/initiatives/)