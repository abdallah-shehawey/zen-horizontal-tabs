// Added for the horizontal-tabs layout (chrome/userChrome.css).
// Delete this file to stop forcing these prefs.
user_pref("zen.tabs.vertical", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Ctrl+T floats the address box over the page you are on.
// Zen ties this to the startup screen (ZenSpaceManager.selectStartPage), so
// the price is that a fresh start shows Zen's blank tab with the search box
// instead of the New Tab page:
//   true  = Ctrl+T floats the box   (chosen)
//   false = start on the New Tab page, Ctrl+T opens that page in a tab
user_pref("zen.urlbar.replace-newtab", true);
// Hides the search box on that blank startup screen (the page stays blank):
// user_pref("zen.urlbar.open-on-startup", false);
// Or: bring back the tabs from last time instead of the blank screen, which
// keeps the floating Ctrl+T as well:
// user_pref("zen.workspaces.continue-where-left-off", true);

// where a new tab lands:
//   a tab you open FROM a page (a link) sits right next to that page
user_pref("browser.tabs.insertRelatedAfterCurrent", true);
//   a tab you open yourself (Ctrl+T, the + button) goes to the end
user_pref("browser.tabs.insertAfterCurrent", false);
// Zen puts new tabs right after the pinned ones when this is on; off = the end
user_pref("zen.view.show-newtab-button-top", false);
// tab open / close animations
user_pref("toolkit.cosmeticAnimations.enabled", true);
