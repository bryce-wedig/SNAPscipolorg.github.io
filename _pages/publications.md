---
title: "Publications"
layout: gridlay
sitemap: false
permalink: /publications/
---

## Publications

<style>
.jumbotron{
    padding:3%;
    padding-bottom:10px;
    padding-top:10px;
    margin-top:10px;
    margin-bottom:10px;
}
</style>

<div class="jumbotron">
### Peer-Reviewed Journal Articles

<style>
.btn{
    margin-bottom:5px;
    padding-top:0px;
    padding-bottom:0px;
    padding-left:15px;
    padding-right:15px;
    height:20px;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    line-height:1;
}
.btn-primary,
.btn-primary:hover,
.btn-primary:focus,
.btn-primary:active,
.btn-primary:focus-visible{
    background-color: var(--snap-blue) !important;
    border-color: var(--snap-blue) !important;
    color: #fff !important;
    box-shadow: none !important;
}
.btn-warning,
.btn-warning:hover,
.btn-warning:focus,
.btn-warning:active,
.btn-warning:focus-visible{
    background-color: var(--snap-orange) !important;
    border-color: var(--snap-orange) !important;
    color: #fff !important;
    box-shadow: none !important;
}
.btn-success,
.btn-success:hover,
.btn-success:focus,
.btn-success:active,
.btn-success:focus-visible{
    background-color: var(--snap-green) !important;
    border-color: var(--snap-green) !important;
    color: var(--snap-purple) !important;
    box-shadow: none !important;
}
pre{
    white-space: pre-wrap;
    word-wrap: break-word;
    width:100%; overflow-x:auto;
}
</style>

{% assign publications = site.data.SNAP_Published_Scientific_Papers_-_Scientific_Journal_Articles %}
{% for pub in publications %}
<div class="text-justify" markdown="0">{{ pub["Citation (APA format)"] }}</div>

<p>{% if pub["DOI link"] contains "http" %}<a href="{{ pub["DOI link"] }}" target="_blank"><button class="btn btn-primary btm-sm">DOI</button></a> {% endif %}{% unless pub["Abstract"] == blank %}<button class="btn btn-warning btm-sm" onclick="toggleAbstract{{ forloop.index }}()">ABSTRACT</button> {% endunless %}{% unless pub["Science For Society (Layman's terms summary)"] == blank %}<button class="btn btn-success btm-sm" onclick="toggleSociety{{ forloop.index }}()">SCIENCE FOR SOCIETY</button>{% endunless %}</p>

{% unless pub["Abstract"] == blank %}
<div id="a{{ forloop.index }}" style="display: none; background-color:white; border-radius:5px; padding:10px; margin-bottom:20px;" markdown="0">
<pre>{{ pub["Abstract"] }}</pre>
</div>
<script>
function toggleAbstract{{ forloop.index }}(){
  var x = document.getElementById('a{{ forloop.index }}');
  if (x.style.display === 'none') { x.style.display = 'block'; } else { x.style.display = 'none'; }
}
</script>
{% endunless %}
{% unless pub["Science For Society (Layman's terms summary)"] == blank %}
<div id="s{{ forloop.index }}" style="display: none; background-color:white; border-radius:5px; padding:10px; margin-bottom:20px;" markdown="0">
<pre>{{ pub["Science For Society (Layman's terms summary)"] }}</pre>
</div>
<script>
function toggleSociety{{ forloop.index }}(){
  var x = document.getElementById('s{{ forloop.index }}');
  if (x.style.display === 'none') { x.style.display = 'block'; } else { x.style.display = 'none'; }
}
</script>
{% endunless %}
{% endfor %}
</div>
