// Search page for /initiatives/stance-on-science/search.
//
// Fetches the pre-rendered responses JSON, populates a list of cards, and
// reactively re-renders when the user types in the search box or changes any
// of the filter dropdowns. Filter state is mirrored to the URL hash so links
// are shareable.

(function () {
  "use strict";

  var FILTER_KEYS = ["tag", "race", "district", "party", "state", "county_race"];

  function sortResponses(arr, sortVal) {
    if (sortVal === "newest") return arr.slice().sort(function (a, b) { return (b.date || "").localeCompare(a.date || ""); });
    if (sortVal === "oldest") return arr.slice().sort(function (a, b) { return (a.date || "").localeCompare(b.date || ""); });
    if (sortVal === "alpha") return arr.slice().sort(function (a, b) { return a.candidate_last_name.localeCompare(b.candidate_last_name); });
    if (sortVal === "alpha-rev") return arr.slice().sort(function (a, b) { return b.candidate_last_name.localeCompare(a.candidate_last_name); });
    return arr;
  }

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

  // Tests whether a response matches the current filter state. `except` (a
  // filter key) lets the caller omit one filter so we can ask "which values
  // would still be valid for THIS dropdown given everything else?"
  function matches(r, state, statesMeta, except) {
    if (except !== "tag" && state.tag && toArray(r.tag).indexOf(state.tag) === -1) return false;
    if (except !== "race" && state.race && r.race !== state.race) return false;
    if (except !== "district" && state.district && String(r.district) !== String(state.district)) return false;
    if (except !== "party" && state.party && r.party !== state.party) return false;
    if (except !== "state" && state.state && r.state !== state.state) return false;
    if (except !== "county_race" && state.county_race && r.county_race !== state.county_race) return false;
    if (state.q) {
      var ql = state.q.toLowerCase();
      var stateName = (statesMeta[r.state] && statesMeta[r.state].name) || r.state;
      var hay = (r.candidate + " " + stateName +
                 " " + r.race + " " + (r.district != null ? "district " + r.district : "") +
                 " " + (r.county_race || "") +
                 " " + toArray(r.tag).join(" ") + " " + (r.response_md || "")).toLowerCase();
      if (hay.indexOf(ql) === -1) return false;
    }
    return true;
  }

  function renderCard(r, statesMeta) {
    var districtLabel = r.district != null ? " — District " + r.district : "";
    var stateMeta = statesMeta[r.state] || { name: r.state, url: "#" };
    var partyHtml = r.party
      ? '<span class="stance-badge stance-badge--party">' + escapeHtml(r.party) + "</span>"
      : "";
    var countyRaceHtml = r.county_race
      ? '<span class="stance-badge stance-badge--county-race">' + escapeHtml(r.county_race) + "</span>"
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
          d.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" }) +
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
            countyRaceHtml +
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

  // Returns the set (as an object map) of values that key `K` takes across all
  // responses that pass every filter EXCEPT the one for K.
  function validValuesFor(key, responses, state, statesMeta) {
    var set = Object.create(null);
    for (var i = 0; i < responses.length; i++) {
      var r = responses[i];
      if (!matches(r, state, statesMeta, key)) continue;
      if (key === "tag") {
        var tags = toArray(r.tag);
        for (var j = 0; j < tags.length; j++) set[tags[j]] = true;
      } else if (key === "district") {
        if (r.district != null) set[String(r.district)] = true;
      } else {
        var v = r[key];
        if (v != null && v !== "") set[v] = true;
      }
    }
    return set;
  }

  function updateOptionVisibility(selects, responses, state, statesMeta) {
    selects.forEach(function (sel) {
      var key = sel.dataset.filter;
      var valid = validValuesFor(key, responses, state, statesMeta);
      var current = sel.value;
      var opts = sel.options;
      for (var i = 0; i < opts.length; i++) {
        var opt = opts[i];
        if (opt.value === "") { opt.hidden = false; continue; }
        if (opt.value === current) { opt.hidden = false; continue; }
        opt.hidden = !valid[opt.value];
      }
    });
  }

  // For dropdowns that the server didn't pre-populate (e.g. County Race on
  // global search), build the option list once from the data.
  function populateOptionsFromData(sel, responses) {
    if (sel.options.length > 1) return; // already populated
    var key = sel.dataset.filter;
    var values = Object.create(null);
    for (var i = 0; i < responses.length; i++) {
      var r = responses[i];
      var v = key === "district" ? (r.district != null ? String(r.district) : null) : r[key];
      if (v != null && v !== "") values[v] = true;
    }
    var sorted = Object.keys(values).sort();
    for (var k = 0; k < sorted.length; k++) {
      var opt = document.createElement("option");
      opt.value = sorted[k];
      opt.textContent = sorted[k];
      sel.appendChild(opt);
    }
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
    var sortSel = root.querySelector("[data-sort]");
    var reset = root.querySelector("[data-filter-reset]");

    var url = window.STANCE_RESPONSES_URL || "/initiatives/stance-on-science/responses.json";

    fetch(url, { credentials: "same-origin" })
      .then(function (resp) {
        if (!resp.ok) throw new Error("HTTP " + resp.status);
        return resp.json();
      })
      .then(function (data) {
        var responses = data.responses || [];
        for (var _i = responses.length - 1; _i > 0; _i--) {
          var _j = Math.floor(Math.random() * (_i + 1));
          var _t = responses[_i]; responses[_i] = responses[_j]; responses[_j] = _t;
        }
        var states = data.states || {};
        if (totalEl) totalEl.textContent = String(responses.length);

        selects.forEach(function (sel) { populateOptionsFromData(sel, responses); });

        var initial = parseHashFilters();
        if (input && initial.q) input.value = initial.q;
        selects.forEach(function (sel) {
          var key = sel.dataset.filter;
          if (initial[key]) sel.value = initial[key];
        });

        function currentState() {
          var s = { q: input ? input.value.trim() : "" };
          selects.forEach(function (sel) { s[sel.dataset.filter] = sel.value; });
          s.sort = sortSel ? sortSel.value : "random";
          return s;
        }

        function apply() {
          var state = currentState();
          var matched = responses.filter(function (r) {
            return matches(r, state, states, null);
          });
          var visible = sortResponses(matched, state.sort);

          if (listEl) {
            if (visible.length === 0) {
              listEl.innerHTML = "";
            } else {
              listEl.innerHTML = visible.map(function (r) { return renderCard(r, states); }).join("");
            }
          }
          if (countEl) countEl.textContent = String(visible.length);
          if (emptyEl) emptyEl.hidden = visible.length !== 0;
          updateOptionVisibility(selects, responses, state, states);
          writeHashFilters(state);
        }

        if (input) input.addEventListener("input", apply);
        selects.forEach(function (sel) { sel.addEventListener("change", apply); });
        if (sortSel) sortSel.addEventListener("change", apply);
        if (reset) {
          reset.addEventListener("click", function () {
            if (input) input.value = "";
            selects.forEach(function (sel) { sel.value = ""; });
            if (sortSel) sortSel.value = "random";
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
