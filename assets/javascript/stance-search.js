// Search page for /initiatives/stance-on-science/search.
//
// Fetches the pre-rendered responses JSON, populates a list of cards, and
// reactively re-renders when the user types in the search box or changes any
// of the filter dropdowns. Filter state is mirrored to the URL hash so links
// are shareable.

(function () {
  "use strict";

  var FILTER_KEYS = ["tag", "race", "district", "party", "state"];

  function toArray(v) {
    if (v == null) return [];
    return Array.isArray(v) ? v : [v];
  }

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function renderCard(r, statesMeta) {
    var districtLabel = r.district != null ? " — District " + r.district : "";
    var stateMeta = statesMeta[r.state] || { name: r.state, url: "#" };
    var partyHtml = r.party
      ? '<span class="stance-badge stance-badge--party">' + escapeHtml(r.party) + "</span>"
      : "";
    var tagHtml = toArray(r.tag).map(function (t) {
      return '<span class="stance-badge stance-badge--tag">' + escapeHtml(t) + "</span>";
    }).join("");
    var dateHtml = "";
    if (r.date) {
      var d = new Date(r.date + "T00:00:00");
      if (!isNaN(d.getTime())) {
        dateHtml =
          '<footer class="stance-response-card__footer"><small>Submitted ' +
          d.toLocaleDateString(undefined, { year: "numeric", month: "long", day: "numeric" }) +
          "</small></footer>";
      }
    }
    return (
      '<article class="stance-response-card">' +
        '<header class="stance-response-card__header">' +
          '<h4 class="stance-response-card__candidate">' + escapeHtml(r.candidate) + "</h4>" +
          '<div class="stance-response-card__meta">' +
            '<span class="stance-badge stance-badge--state"><a href="' +
              escapeHtml(stateMeta.url) + '">' + escapeHtml(stateMeta.name) + "</a></span>" +
            '<span class="stance-badge stance-badge--race">' + escapeHtml(r.race) + escapeHtml(districtLabel) + "</span>" +
            partyHtml +
            tagHtml +
          "</div>" +
        "</header>" +
        '<div class="stance-response-card__body">' +
          (r.question_html
            ? '<p class="stance-response-card__question"><em>' +
                r.question_html.replace(/^<p>/, "").replace(/<\/p>\s*$/, "").trim() +
              "</em></p>"
            : "") +
          r.response_html +
        "</div>" +
        dateHtml +
      "</article>"
    );
  }

  function parseHashFilters() {
    var hash = window.location.hash || "";
    if (hash.charAt(0) === "#") hash = hash.slice(1);
    if (hash.charAt(0) === "?") hash = hash.slice(1);
    var out = { q: "" };
    if (!hash) return out;
    hash.split("&").forEach(function (pair) {
      if (!pair) return;
      var idx = pair.indexOf("=");
      var k = idx === -1 ? pair : pair.slice(0, idx);
      var v = idx === -1 ? "" : decodeURIComponent(pair.slice(idx + 1).replace(/\+/g, " "));
      out[decodeURIComponent(k)] = v;
    });
    return out;
  }

  function writeHashFilters(state) {
    var parts = [];
    if (state.q) parts.push("q=" + encodeURIComponent(state.q));
    FILTER_KEYS.forEach(function (k) {
      if (state[k]) parts.push(k + "=" + encodeURIComponent(state[k]));
    });
    var newHash = parts.length ? "#?" + parts.join("&") : "";
    if (newHash !== window.location.hash) {
      // Replace state so the back button doesn't fill with filter changes.
      history.replaceState(null, "", window.location.pathname + window.location.search + newHash);
    }
  }

  function init() {
    var root = document.getElementById("stance-search");
    if (!root) return;
    var listEl = root.querySelector("[data-results-list]");
    var countEl = root.querySelector("[data-results-count]");
    var totalEl = root.querySelector("[data-results-total]");
    var emptyEl = root.querySelector("[data-empty-state]");
    var input = root.querySelector("[data-search-input]");
    var selects = root.querySelectorAll("select[data-filter]");
    var reset = root.querySelector("[data-filter-reset]");

    var url = window.STANCE_RESPONSES_URL || "/initiatives/stance-on-science/responses.json";

    fetch(url, { credentials: "same-origin" })
      .then(function (resp) {
        if (!resp.ok) throw new Error("HTTP " + resp.status);
        return resp.json();
      })
      .then(function (data) {
        var responses = data.responses || [];
        var states = data.states || {};
        if (totalEl) totalEl.textContent = String(responses.length);

        var initial = parseHashFilters();
        if (input && initial.q) input.value = initial.q;
        selects.forEach(function (sel) {
          var key = sel.dataset.filter;
          if (initial[key]) sel.value = initial[key];
        });

        function currentState() {
          var s = { q: input ? input.value.trim() : "" };
          selects.forEach(function (sel) { s[sel.dataset.filter] = sel.value; });
          return s;
        }

        function apply() {
          var state = currentState();
          var ql = state.q.toLowerCase();
          var visible = responses.filter(function (r) {
            if (state.tag && toArray(r.tag).indexOf(state.tag) === -1) return false;
            if (state.race && r.race !== state.race) return false;
            if (state.district && String(r.district) !== String(state.district)) return false;
            if (state.party && r.party !== state.party) return false;
            if (state.state && r.state !== state.state) return false;
            if (ql) {
              var hay = (r.candidate + " " + (states[r.state] && states[r.state].name || r.state) +
                         " " + r.race + " " + toArray(r.tag).join(" ") + " " + (r.response_md || "")).toLowerCase();
              if (hay.indexOf(ql) === -1) return false;
            }
            return true;
          });

          if (listEl) {
            if (visible.length === 0) {
              listEl.innerHTML = "";
            } else {
              listEl.innerHTML = visible.map(function (r) { return renderCard(r, states); }).join("");
            }
          }
          if (countEl) countEl.textContent = String(visible.length);
          if (emptyEl) emptyEl.hidden = visible.length !== 0;
          writeHashFilters(state);
        }

        if (input) input.addEventListener("input", apply);
        selects.forEach(function (sel) { sel.addEventListener("change", apply); });
        if (reset) {
          reset.addEventListener("click", function () {
            if (input) input.value = "";
            selects.forEach(function (sel) { sel.value = ""; });
            apply();
          });
        }

        apply();
      })
      .catch(function (err) {
        if (listEl) {
          listEl.innerHTML = '<p><em>Could not load responses. Please try again later.</em></p>';
        }
        // eslint-disable-next-line no-console
        console.error("stance-search: failed to load", err);
      });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());
