---
title: "Team"
layout: gridlay
sitemap: false
permalink: /team/
---

## Meet the Team

<div class='jumbotron'>
{% assign number_printed = 0 %}
{% for member in site.data.members %}

{% assign even_odd = number_printed | modulo: 2 %}

{% if even_odd == 0 %}

<div class="row">
{% endif %}

<div class="col-sm-2">
<img src="{{ site.url }}{{ site.baseurl }}/images/{{ member.photo }}" width="100%" style="max-width:250px"/>
</div>
<div class="col-sm-4 col-xs-12">
  <h4>{{ member.name }}</h4>
  {% if member.pronouns %}<h5>{{ member.pronouns }}</h5></a> {% endif %}
  <i>{{ member.info }}<br></i>

{% if member.website %}<a href="{{ member.website }}" target="_blank"><i class="fa-solid fa-link fa-2x"></i></a> {% endif %}
{% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa-solid fa-envelope fa-2x"></i></a> {% endif %}
{% if member.bluesky %} <a href="{{ member.bluesky }}" target="_blank"><i class="fa-brands fa-bluesky fa-2x"></i></a> {% endif %}
{% if member.instagram %} <a href="{{ member.instagram }}" target="_blank"><i class="fa-brands fa-instagram fa-2x"></i></a> {% endif %}
{% if member.linkedin %} <a href="{{ member.linkedin }}" target="_blank"><i class="fa-brands fa-linkedin fa-2x"></i></a> {% endif %}

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
