// In-page filter for state-level Stance on Science pages. Hides response
// cards whose data-* attributes don't match the currently-selected dropdowns,
// and narrows each dropdown's options to values that would still yield a
// match given the other selected filters.

(function () {
  "use strict";

  function recordFromCard(card) {
    var tagAttr = card.dataset.tag || "";
    return {
      el: card,
      candidate: card.getAttribute("data-candidate") || "",
      date: card.getAttribute("data-date") || "",
      tag: tagAttr ? tagAttr.split("|") : [],
      race: card.getAttribute("data-race") || "",
      district: card.getAttribute("data-district") || "",
      party: card.getAttribute("data-party") || "",
      county_race: card.getAttribute("data-county-race") || ""
    };
  }

  function sortedRecords(recs, sortVal) {
    if (sortVal === "newest") return recs.slice().sort(function (a, b) { return b.date.localeCompare(a.date); });
    if (sortVal === "oldest") return recs.slice().sort(function (a, b) { return a.date.localeCompare(b.date); });
    if (sortVal === "alpha") return recs.slice().sort(function (a, b) { return a.candidate.localeCompare(b.candidate); });
    if (sortVal === "alpha-rev") return recs.slice().sort(function (a, b) { return b.candidate.localeCompare(a.candidate); });
    return recs;
  }

  function matches(r, filters, except) {
    var keys = Object.keys(filters);
    for (var i = 0; i < keys.length; i++) {
      var k = keys[i];
      if (k === except) continue;
      var v = filters[k];
      if (!v) continue;
      if (k === "tag") {
        if (r.tag.indexOf(v) === -1) return false;
      } else if (k === "district") {
        if (String(r.district) !== String(v)) return false;
      } else {
        if (r[k] !== v) return false;
      }
    }
    return true;
  }

  function validValuesFor(key, records, filters) {
    var set = Object.create(null);
    for (var i = 0; i < records.length; i++) {
      var r = records[i];
      if (!matches(r, filters, key)) continue;
      if (key === "tag") {
        for (var j = 0; j < r.tag.length; j++) {
          if (r.tag[j]) set[r.tag[j]] = true;
        }
      } else {
        var v = r[key];
        if (v != null && v !== "") set[v] = true;
      }
    }
    return set;
  }

  function init() {
    var bar = document.getElementById("state-filters");
    var list = document.querySelector(".stance-response-list");
    if (!bar || !list) return;

    var selects = bar.querySelectorAll("select[data-filter]");
    var sortSel = bar.querySelector("[data-sort]");
    var reset = bar.querySelector("[data-filter-reset]");
    var emptyState = document.querySelector("[data-empty-state]");
    var countEl = document.querySelector("[data-results-count]");
    var cards = list.querySelectorAll(".stance-response-card");

    var records = [];
    cards.forEach(function (card) { records.push(recordFromCard(card)); });
    for (var _i = records.length - 1; _i > 0; _i--) {
      var _j = Math.floor(Math.random() * (_i + 1));
      var _t = records[_i]; records[_i] = records[_j]; records[_j] = _t;
    }
    records.forEach(function (r) { list.appendChild(r.el); });

    function apply() {
      var filters = {};
      selects.forEach(function (sel) {
        if (sel.value) filters[sel.dataset.filter] = sel.value;
      });

      var visible = 0;
      records.forEach(function (r) {
        var match = matches(r, filters, null);
        r.el.hidden = !match;
        if (match) visible += 1;
      });

      if (countEl) countEl.textContent = String(visible);
      if (emptyState) emptyState.hidden = visible !== 0;

      var sortVal = sortSel ? sortSel.value : "random";
      sortedRecords(records, sortVal).forEach(function (r) { list.appendChild(r.el); });

      selects.forEach(function (sel) {
        var key = sel.dataset.filter;
        var valid = validValuesFor(key, records, filters);
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

    selects.forEach(function (sel) {
      sel.addEventListener("change", apply);
    });

    if (sortSel) sortSel.addEventListener("change", apply);

    if (reset) {
      reset.addEventListener("click", function () {
        selects.forEach(function (sel) { sel.value = ""; });
        if (sortSel) sortSel.value = "random";
        apply();
      });
    }

    apply();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());
