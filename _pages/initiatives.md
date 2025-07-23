---
title: "Initiatives"
layout: gridlay
sitemap: false
permalink: /initiatives/
---

<!-- New style rendering if project categories are defined -->
{% if site.initiatives_category %}
  <div id="archives">
    {% for category in site.categories %}
      <div class="archive-group">
        {% capture category_name %}{{ category | first }}{% endcapture %}
        <div id="#{{ category_name | slugize }}"></div>
        <p></p>

        <h3 class="category-head">{{ category_name }}</h3>
        <a name="{{ category_name | slugize }}"></a>
        {% for post in site.categories[category_name] %}
        <article class="archive-item">
          <h4><a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a></h4>
        </article>
        {% endfor %}
    </div>
  {% endfor %}
</div>

{% endif %}

### Current Initiatives

## McClintock Letters

Improving communication between scientists and the public is crucial for rebuilding trust and addressing misinformation. We're inviting scientists to share their stories with their local hometown paper through the McClintock Letters Initiative — a national op-ed campaign.

Join the McClintock Letter Writer's Space for feedback, community, and resources!

Read the McClintock Press Release here.

Need help getting your letter published? Submit a request for assistance here.

## Press Mentions

- New York Times | To Protest Budget Cuts, Young Scientists Try Letters to the Editor
- Cornell Chronicle | Cornell student campaign for research support reaches 50 states
- NBC News | Researchers have a radical plan to thwart Trump’s war on science: Talking to people
- EurekAlert | Hundreds of scientists speak out to defend science and honor Dr. Barbara McClintock
- New York Academy of Sciences | The McClintock Letters Initiative to Support Science
- Forbes | NSF, NIH Funding Cuts Spur Student-Led Science Communication Campaign
- Big Biology Substack | Show your support for federal science funding – Join the McClintock Letters Initiative

### Past Initiatives

Check back soon for more information!

