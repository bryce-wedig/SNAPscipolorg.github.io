// "Compare Matrix" view for Stance on Science state pages.
//
// The page is rendered (server-side) as one candidates × questions table per
// race. This script swaps which table is visible based on the race selector
// and lets any clamped cell expand to its full answer on click.

(function () {
  "use strict";

  function init() {
    var root = document.querySelector("[data-compare]");
    if (!root) return;

    var raceSel = root.querySelector("[data-compare-race]");
    var tables = root.querySelectorAll("[data-compare-table]");

    function showRace(race) {
      tables.forEach(function (table) {
        table.hidden = table.getAttribute("data-compare-table") !== race;
      });
    }

    if (raceSel) {
      raceSel.addEventListener("change", function () { showRace(raceSel.value); });
      showRace(raceSel.value);
    }

    // Click a cell to toggle the clamp on its answer. The stable ".js-clamp"
    // hook stays put while the ".stance-clamp" truncation class is toggled.
    root.addEventListener("click", function (e) {
      var clamp = e.target.closest(".js-clamp");
      if (!clamp || !root.contains(clamp)) return;
      clamp.classList.toggle("stance-clamp");
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());
