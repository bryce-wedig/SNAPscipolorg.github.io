// In-page filter for state-level Stance on Science pages. Hides response
// cards whose data-* attributes don't match the currently-selected dropdowns.

(function () {
  "use strict";

  function init() {
    var bar = document.getElementById("state-filters");
    var list = document.querySelector(".stance-response-list");
    if (!bar || !list) return;

    var selects = bar.querySelectorAll("select[data-filter]");
    var reset = bar.querySelector("[data-filter-reset]");
    var emptyState = document.querySelector("[data-empty-state]");
    var countEl = document.querySelector("[data-results-count]");
    var cards = list.querySelectorAll(".stance-response-card");

    function apply() {
      var filters = {};
      selects.forEach(function (sel) {
        if (sel.value) filters[sel.dataset.filter] = sel.value;
      });

      var visible = 0;
      cards.forEach(function (card) {
        var match = true;
        Object.keys(filters).forEach(function (key) {
          if (key === "tag") {
            var tags = (card.dataset.tag || "").split("|");
            if (tags.indexOf(filters[key]) === -1) match = false;
          } else {
            var attr = "data-" + key.replace(/_/g, "-");
            if (card.getAttribute(attr) !== filters[key]) match = false;
          }
        });
        card.hidden = !match;
        if (match) visible += 1;
      });

      if (countEl) countEl.textContent = String(visible);
      if (emptyState) emptyState.hidden = visible !== 0;
    }

    selects.forEach(function (sel) {
      sel.addEventListener("change", apply);
    });

    if (reset) {
      reset.addEventListener("click", function () {
        selects.forEach(function (sel) { sel.value = ""; });
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
