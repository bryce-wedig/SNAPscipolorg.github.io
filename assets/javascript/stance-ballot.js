// "Find My Ballot" view for Stance on Science state pages.
//
// The page is rendered (server-side) as race groups, each containing one
// collapsible card per candidate. This script drives the district/race picker,
// hiding any group or candidate that doesn't match and auto-expanding the
// groups that do.

(function () {
  "use strict";

  function init() {
    var root = document.querySelector("[data-ballot]");
    if (!root) return;

    var distSel = root.querySelector("[data-ballot-district]");
    var raceSel = root.querySelector("[data-ballot-race]");
    var resetBtn = root.querySelector("[data-ballot-reset]");
    var emptyState = root.querySelector("[data-ballot-empty]");
    var groups = root.querySelectorAll(".stance-race-group");

    function apply() {
      var district = distSel ? distSel.value : "";
      var race = raceSel ? raceSel.value : "";
      var filtering = !!(district || race);
      var anyGroup = false;

      groups.forEach(function (group) {
        var groupRace = group.getAttribute("data-race") || "";
        var raceMatch = !race || groupRace === race;

        var cands = group.querySelectorAll(".stance-candidate");
        var visibleCands = 0;
        cands.forEach(function (cand) {
          var candDist = cand.getAttribute("data-district") || "";
          var match = raceMatch && (!district || candDist === district);
          cand.hidden = !match;
          if (match) visibleCands += 1;
        });

        var showGroup = raceMatch && visibleCands > 0;
        group.hidden = !showGroup;
        if (showGroup) {
          anyGroup = true;
          // Auto-expand when the voter has narrowed things down.
          group.open = filtering;
        } else {
          group.open = false;
        }

        var countEl = group.querySelector("[data-group-count]");
        if (countEl) countEl.textContent = String(visibleCands);
      });

      if (emptyState) emptyState.hidden = anyGroup;
    }

    function reset() {
      if (distSel) distSel.value = "";
      if (raceSel) raceSel.value = "";
      apply();
    }

    if (resetBtn) resetBtn.addEventListener("click", reset);
    if (distSel) distSel.addEventListener("change", apply);
    if (raceSel) raceSel.addEventListener("change", apply);

    apply();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());
