---
title: "Team"
layout: gridlay
sitemap: false
permalink: /team/
---

## Team

The SNAP Coalition is a network comprised of over 120 individuals and over 20 student organizations! Meet some of our members below:

## Meet the Core Team!

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
<div class="col-sm-9 col-xs-12">
  <h4>{{ member.name }}</h4>
  <i>{{ member.info }}<br></i>

{% if member.website %}<a href="{{ member.website }}" target="_blank"><i class="fa fa-home fa-2x"></i></a> {% endif %}
{% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa-solid fa-envelope fa-2x"></i></a> {% endif %}
{% if member.bluesky %} <a href="{{ member.bluesky }}" target="_blank"><i class="fa-solid fa-bluesky fa-2x"></i></a> {% endif %}
{% if member.linkedin %} <a href="{{ member.linkedin }}" target="_blank"><i class="fa-solid fa-linkedin fa-2x"></i></a> {% endif %}

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

## Member Organizations

<div class='jumbotron'>
{% assign number_printed = 0 %}
{% for member in site.data.member_orgs %}

{% assign even_odd = number_printed | modulo: 2 %}

{% if even_odd == 0 %}

<div class="row">
{% endif %}

<div class="col-sm-2">
<img src="{{ site.url }}{{ site.baseurl }}/images/{{ member.photo }}" width="100%" style="max-width:250px"/>
</div>
<div class="col-sm-4 col-xs-12">
  <h4>{{ member.name }}</h4>
  <i>{{ member.info }}<br></i>

{% if member.website %}<a href="{{ member.website }}" target="_blank"><i class="fa fa-home fa-2x"></i></a> {% endif %}
{% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa fa-envelope fa-2x"></i></a> {% endif %}
{% if member.scholar %} <a href="{{ member.scholar }}" target="_blank"><i class="ai ai-google-scholar ai-2x"></i></a> {% endif %}
{% if member.cv %} <a href="{{ member.cv }}" target="_blank"><i class="ai ai-cv ai-2x"></i></a> {% endif %}
{% if member.github %} <a href="{{ member.github }}" target="_blank"><i class="fa fa-github fa-2x"></i></a> {% endif %}
{% if member.researchgate %} <a href="{{ member.researchgate }}" target="_blank"><i class="ai ai-researchgate ai-2x"></i></a> {% endif %}

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