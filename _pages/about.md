---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

<!-- ## About

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
{% endfor %} -->

## Member Organizations

<div class='jumbotron'>
{% assign number_printed = 0 %}
{% for member in site.data.member_orgs %}

{% assign even_odd = number_printed | modulo: 2 %}

{% if even_odd == 0 %}
<div class="row">
{% endif %}

<div class="col-sm-2">
<img src="{{ site.url }}{{ site.baseurl }}/images/member_org_logos/{{ member.photo }}" width="100%" style="max-width:250px"/>
</div>
<div class="col-sm-4 col-xs-12">
  <h4>{{ member.name }}</h4>
  <i>{{ member.info }}<br></i>
<div style="display: flex; gap: 0.25em; align-items: flex-start; flex-wrap: wrap;">
  {% if member.website %}<a href="{{ member.website }}" target="_blank"><i class="fa-solid fa-link fa-2x"></i></a>{% endif %}
  {% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa-solid fa-envelope fa-2x"></i></a>{% endif %}
  {% if member.bluesky %}<a href="https://bsky.app/profile/{{ member.bluesky }}" target="_blank"><i class="fa-brands fa-bluesky fa-2x"></i></a>{% endif %}
  {% if member.instagram %}<a href="https://www.instagram.com/{{ member.instagram }}" target="_blank"><i class="fa-brands fa-instagram fa-2x"></i></a>{% endif %}
  {% if member.linkedin %}<a href="https://www.linkedin.com/company/{{ member.linkedin }}/" target="_blank"><i class="fa-brands fa-linkedin fa-2x"></i></a>{% endif %}
</div>

</div>
<!-- </div> -->

{% assign number_printed = number_printed | plus: 1 %}

{% if even_odd == 1 %}

</div>
{% endif %}

{% endfor %}

{% assign even_odd = number_printed | modulo: 2 %}
{% if even_odd == 1 %}

</div>
{% endif %}
</div>

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

{% if site.data.funders %}

<div class="jumbotron">
  <h4>Sponsors</h4>
  <div style='display:block; text-align:center; margin-left:auto; margin-right:auto;'>
  {% for funder in site.data.funders %}<a href="{{ funder.url }}" target="_blank"><img src='{{ site.url }}{{ site.baseurl }}/images/{{ funder.image }}' style='max-height: 80px; max-width: 200px; margin: 1%'/></a>{% endfor %}
  </div>
</div>
{% endif %}
