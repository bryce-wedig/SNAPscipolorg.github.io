// "Compare" view for Stance on Science state pages.
//
// The page is rendered (server-side) as one block per race, each grouping the
// candidate answers under their question. This script swaps which race's block
// is visible based on the race selector.

(function () {
  "use strict";

  function init() {
    var root = document.querySelector("[data-compare]");
    if (!root) return;

    var raceSel = root.querySelector("[data-compare-race]");
    var blocks = root.querySelectorAll("[data-compare-table]");
    var primaryChk = root.querySelector("[data-compare-primary]");
    var noResponseChk = root.querySelector("[data-compare-noresponse]");
    var cards = root.querySelectorAll(".stance-compare-card");

    function showRace(race) {
      blocks.forEach(function (block) {
        block.hidden = block.getAttribute("data-compare-table") !== race;
      });
    }

    // Primary candidates (who didn't advance past the primary) and candidates
    // who never responded are hidden by default; each checkbox reveals its own
    // group's columns across every question row. Both toggles write the same
    // `hidden` flag, so they have to be resolved together in one pass.
    function applyVisibility() {
      var showPrimary = !!(primaryChk && primaryChk.checked);
      var showNoResponse = !!(noResponseChk && noResponseChk.checked);
      cards.forEach(function (card) {
        card.hidden =
          (!showPrimary && card.getAttribute("data-primary-candidate") === "true") ||
          (!showNoResponse && card.getAttribute("data-did-not-respond") === "true");
      });
    }

    if (raceSel) {
      raceSel.addEventListener("change", function () { showRace(raceSel.value); });
      showRace(raceSel.value);
    }
    if (primaryChk) primaryChk.addEventListener("change", applyVisibility);
    if (noResponseChk) noResponseChk.addEventListener("change", applyVisibility);
    applyVisibility();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}());
