---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

## About

{% for member in site.data.snap %}

<div class="jumbotron" align="center">
<div class="row">
<div class="col-sm-12">
  <img src="{{ site.url }}{{ site.baseurl }}/images/{{ member.photo }}" width="100%" style="max-width:500px"/>
</div>
<div class="row">
<div class="col-sm-12">
  <h4><i>{{ member.info }}</i></h4>
  {% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa-solid fa-envelope fa-2x"></i></a> {% endif %}
  {% if member.bluesky %} <a href="{{ member.bluesky }}" target="_blank"><i class="fa-brands fa-bluesky fa-2x"></i></a> {% endif %}
  {% if member.instagram %} <a href="{{ member.instagram }}" target="_blank"><i class="fa-brands fa-instagram fa-2x"></i></a> {% endif %}
  {% if member.linkedin %} <a href="{{ member.linkedin }}" target="_blank"><i class="fa-brands fa-linkedin fa-2x"></i></a> {% endif %}
</div>
</div>
</div>
</div>
{% endfor %}

{% if site.data.grants %}

<div class="jumbotron">
  <h3>Grants</h3>
  <ul>
    {% for grant in site.data.grants %}
      <li>{{ grant.name }}</li>
    {% endfor %}
  </ul>
</div>
{% endif %}

{% if site.data.awards %}

<div class="jumbotron">
  <h3>Awards</h3>
  <ul>
    {% for award in site.data.awards %}
      <li>{{ award.name | replace: "-","&#8211;" }}</li>
    {% endfor %}
  </ul>
</div>
{% endif %}

<div class="jumbotron">
  <h4>Sponsors</h4>
  <div style='display:block; text-align:center; margin-left:auto; margin-right:auto;'>
  {% for funder in site.data.funders %}<a href="{{ funder.url }}" target="_blank"><img src='{{ site.url }}{{ site.baseurl }}/images/{{ funder.image }}' style='max-height: 80px; max-width: 200px; margin: 1%'/></a>{% endfor %}
  </div>
</div>
