---
title: "Publications"
layout: gridlay
sitemap: false
permalink: /publications/
years: [2023, 2024, 2025, 2026, 2027]
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
### Preprints
{% bibliography --query @unpublished %}
</div>

<div class="jumbotron">
### Peer-Reviewed Journal Articles
{% bibliography --query @article %}
</div>

<div class="jumbotron">
### Peer-Reviewed Conference Papers
{% bibliography --query @inproceedings %}
</div>
