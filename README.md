# Zen horizontal tabs

Zen Browser with the tabs on the **same row as the address bar** instead of the
vertical sidebar. Tested on Zen 1.21.15b (Linux).

![row](docs/row.png)

```
[sidebar][<][>][reload][home]  [ address ]  [ tab ][ tab ][ open tab ][ tab ] ... [_][□][X]
```

* one 36px toolbar row, everything on it
* every tab that is not the current one is a **120px box** with its favicon and its title, on its own faint pill - the same size whether the pointer is on it or not; its X fades in under the pointer without moving anything
* a **pinned** tab is a **38px favicon chip** instead, and opens to 120px while the pointer is on it
* the current tab is a **220px pill** with its title
* a full strip squeezes the 120px boxes down towards 24px rather than pushing the last tabs out of the window
* the address box is 280px, the address is centred, domain only
* a **"+"** sits after the last tab
* Ctrl+T's floating search box **fades and scales in**, its results fan in behind it
* a **private window is violet**, not the same black as a normal one
* one motion system: tabs grow and collapse on a single curve, the current
  tab's title slides in, buttons answer a press, split panes ease
* window buttons, app menu, downloads all keep working

## Install

Quit Zen completely, then:

```bash
./install.sh
```

It writes exactly two files into the profile and backs up anything already
there:

| file | what it does |
|---|---|
| `chrome/userChrome.css` | the whole layout |
| `user.js` | the handful of prefs the layout needs |

Nothing else in the profile is touched - bookmarks, history, accounts,
extensions, `zen-themes.css` and the mods folder are left alone.
`./uninstall.sh` deletes the two files and Zen goes back to normal.

## Tuning

Every size lives in one place, the top of `chrome/userChrome.css`:

```css
:root {
  --ctab-row: 36px;      /* height of the whole toolbar row */
  --ctab-strip: 30px;    /* height of the tab strip inside it */
  --ctab-tab: 120px;     /* width of a tab that is not the current one */
  --ctab-chip: 38px;     /* width of a PINNED tab: favicon only */
  --ctab-peek: var(--ctab-tab);   /* a pinned chip while the pointer is on it */
  --ctab-active: 220px;  /* width of the current tab */
  --ctab-label: 12px;    /* the title on a tab that is not the current one */
  --ctab-tab-h: 26px;    /* height of a tab */
  --ctab-right: 158px;   /* space kept for app menu + window buttons */
  --ctab-url: 280px;     /* width of the address box */
  --ctab-newtab: 26px;   /* width of the "+" that follows the last tab */
  --ctab-gap: 8px;       /* room on each side of the address box */
  --ctab-private: 128, 116, 255;  /* the private-window accent, as R, G, B */

  --ctab-ease: cubic-bezier(0.2, 0.9, 0.25, 1);   /* things changing size */
  --ctab-ease-in: cubic-bezier(0.16, 1, 0.3, 1);  /* things arriving */
  --ctab-t-tab: 190ms;   /* a tab growing or collapsing */
  --ctab-t-peek: 130ms;  /* the hover preview */
  --ctab-t-omni: 300ms;  /* the floating address box arriving */
  --ctab-bm: 32px;          /* the bookmarks strip */
  --ctab-t-fast: 110ms;  /* colour, hover, press */
}
```

Edit, save, restart Zen.

## The prefs, and the one trade-off

`user.js` forces these:

| pref | why |
|---|---|
| `zen.tabs.vertical=false` | horizontal strip |
| `toolkit.legacyUserProfileCustomizations.stylesheets=true` | let Zen read `userChrome.css` |
| `zen.urlbar.replace-newtab=true` | Ctrl+T floats the address box over the page |
| `browser.tabs.insertRelatedAfterCurrent=true` | a link opens next to the page it came from |
| `browser.tabs.insertAfterCurrent=false` | Ctrl+T goes to the end of the strip |
| `zen.view.show-newtab-button-top=false` | new tabs at the end, not before the pinned ones |
| `zen.tabs.show-newtab-vertical=true` | reveals the "+" after the last tab - Zen ships it `display:none` |
| `zen.view.compact.enable-at-startup=false` | compact mode stays off (see below) |
| `toolkit.cosmeticAnimations.enabled=true` | tabs slide open and closed |

**The trade-off:** Zen ties the floating Ctrl+T box and the startup screen to
the *same* pref (`ZenSpaceManager.selectStartPage`). With
`zen.urlbar.replace-newtab=true` you get the floating box on Ctrl+T but Zen
starts on its blank tab; with `false` you start on the New Tab page but Ctrl+T
opens that page in a tab. There is no third setting - `browser.startup.page`,
`browser.startup.homepage=about:newtab` and `zen.urlbar.open-on-startup` were
all tested and none of them changes it. Two alternatives sit commented out at
the top of `user.js`.

## Motion

Zen already animates a lot of the browser in JS, with the Motion library, and
the rule this file follows is **never transition a property Zen is animating**.
A CSS transition on such a property does not replace the JS animation, it puts
an ease in front of every frame the JS writes: with `opacity` in the tab
transition, a new tab's fade crawled `1.00 -> 0.74 -> 0.51 -> ... -> 0.00`
instead of following Motion. So the split is:

| owned by this file | owned by Zen's JS |
|---|---|
| tab `width` / `min-width` / `max-width` / `height` | tab `opacity` and `scale` on open and close |
| the current tab's title sliding in | dragging a tab to reorder |
| button press, favicon hover, the X | pinning, spaces, glance, downloads |
| split-view panes (`inset`) | compact mode |

Two things Zen writes for the **vertical** sidebar are cancelled here, because
in a horizontal row they are a vertical hop: `margin-bottom` on tab open/close
(the horizontal equivalent, the width transition, is already free) and a stray
`transform: translateY()` on the pinned-tabs separator.

Menus and panels are **shaped but not animated**: rounded inset row
highlights, hairline separators pulled in from the edges, a 16px corner radius,
real padding - and no motion at all. There was an entrance, and it was measured
out again. A popup's own frame genuinely cannot be animated (an `animation` on
`menupopup` and one on `menupopup::part(content)` both produce **zero** entries
in `getAnimations()`), so the only thing that could move was the rows, and rows
fading in one after another is exactly what "the menu hangs while it fills up"
looks like. On a 19-row right-click menu, measured from `popupshown`: with the
entrance the last row was not fully visible until **+310ms**; without it,
**+0ms** - the whole menu is there in the frame that maps it. A menu is opened
to be clicked, often before it has finished appearing, so that third of a
second was not decoration, it was latency. Closing was never animated and
cannot be: the popup is torn down synchronously.

Shape reaches the box the same indirect way: `menupopup::part(content)` is not
honoured from USER origin (a `padding: 21px` set that way left the part at
5px), but inherited custom properties cross into the shadow tree, so
`--panel-border-radius` and `--panel-padding` land. Colours are left to Zen -
everything here derives from `currentColor`, so a theme change cannot strand
it. A popup's own frame is **not** animated. On Linux each menu and panel is its
own OS-level window and both routes are closed from a user stylesheet:
`panel::part(content)` is not honoured from USER origin (verified - an
`outline` set that way never reached the element), and `-moz-window-transform`
/ `-moz-window-opacity` are not supported in this build. What a popup's
*contents* do is another matter: Gecko throws away a popup's frames when it
closes and builds them again when it opens, so an animation on something inside
one replays on every open rather than only the first. That is what made an
entrance possible at all - and both places that used one, the menus and the
Ctrl+Tab switcher, have since had it removed for the latency it cost.

### Why one pixel of `#nav-bar` used to be never still

Firefox stops its refresh driver when nothing is changing on screen, and it
does not reset the animation clock when it starts again. An animation created
by a synchronous style flush - which is what Ctrl+T is, since Zen sets the
attributes and immediately measures the box - is stamped with the *last* tick's
time, so if the browser has been quiet for longer than the animation lasts, the
first frame it is ever sampled on is already past its end. Measured here on the
300ms entrance: with the clock idle 868ms it was alive for **0 of the next 97
frames**, and `animationstart` and `animationend` fired in the same
millisecond; with the clock fresh, 285ms and 42 frames. That is the whole
reason clicking "+" always animated and Ctrl+T often did not - reaching for the
mouse repaints the row and refreshes the clock, a keyboard shortcut on a page
that has finished loading does not.

The only lever CSS has is to keep that clock running, and only an animation
Gecko thinks is worth sampling will do it. Clock lag after five seconds of
complete quiet:

| keep-alive | lag |
|---|---|
| none | 58 191 ms |
| a custom property (`--x: 0 -> 1`) | 64 576 ms - throttled, it changes nothing |
| `opacity: .999 -> 1` | 5 590 ms - runs on the compositor, the main thread still sleeps |
| `background-color` on a 1px `::after` | 12 565 ms - XUL box, the pseudo never rendered |
| **`outline-color` on a real 1px outline** | **26 ms** |

That keep-alive is in the file, and it is **commented out**. What it costs is
not one style sample: it is a wake-up and a composite of the whole window on
every frame for as long as the window is focused, forever. This display runs at
165Hz, so it is 165 composites a second of a 2560x1440 window bought so that a
fade would not be skipped - the kind of always-on work that makes a browser
feel heavy without ever pointing at a cause. Since the menus and the switcher
no longer animate, the only entrance left to protect was the floating address
box, and a box that sometimes appears instantly is the better trade.

Uncomment the `ctab-clock` rule to get it back: the address box then fades
every time instead of most times, and the browser paints continuously.

### The Ctrl+Tab switcher

Only exists if `browser.ctrlTab.sortByRecentlyUsed` is on. Firefox lays it out
as **one screen-wide ribbon**, and that is structural rather than a style
choice - `browser-ctrlTab.js` writes an inline `panel.style.width` of
`canvasWidth * 1.25 * tabCount` (with `canvasWidth` always `availWidth * 0.85 / 7`)
and then positions the popup from that same number, so ~2530px on a 2560px
screen. Overriding the width from CSS would leave the popup anchored where a
2530px box was meant to start, i.e. against the left edge.

So the popup frame is made **invisible** and `#ctrlTab-previews` becomes the
visible card, centred inside it: a dark rounded panel in **one row**, with the
frame staying screen-wide behind it where nobody can see it. One row is
structural too - `ctrlTab.js` positions the popup vertically at
`(availHeight - (canvasHeight * 1.25 + 75)) / 2`, the height of a *single* row
of thumbnails, so a wrapped grid is taller than the estimate, grows downward
from a top computed for a short panel, and sits visibly below centre.

Three things were tried here and measured back out, and the panel is fast
because none of them survived:

| removed | why |
|---|---|
| `backdrop-filter: blur(28px)` | blurring a ~1800x640 region of a screen-wide transparent popup every frame, over seven scaled canvases, for a card that is 92% opaque anyway |
| `zoom: 1.12` | resamples every thumbnail at paint time and puts the subtree in a scaled coordinate space |
| the entrance | Firefox already waits 200ms before showing this panel; the fade then held the cards invisible for **another 325ms** after `popupshown`. Without it: **+0ms** |

Stepping through the cards with Ctrl held went from a **17.0ms** median frame
to **8.8ms** across those changes, and to **6.1ms** - a full 165Hz - in the
shipped file.

Rounding is worth a note of its own, because the old one here was wrong.
An inline `borderRadius = "44px"` on a `.ctrlTab-preview` reads back `0px`,
which looked like border-radius being unsupported on those buttons. It is not:
the **Better CtrlTab Panel** mod declares `border-radius: var(--psu-...)
!important` with an unresolvable var, and an author `!important` beats a plain
inline style. The same declaration made from `userChrome.css` wins, because a
USER-origin `!important` outranks an author one - measured, 44px, taken. That
matters for speed, not tidiness: `clip-path: inset(0 round Npx)` rounds these
elements too, and the file used to use it on four elements per card. A rounded
clip-path is a **mask** - the subtree is drawn to an intermediate surface and
composited back through it - and there were up to 28 of those, nested, over
seven ~310px thumbnails, rebuilt on every paint. `border-radius` takes the
rounded-rect fast path.

If the **Better CtrlTab Panel** mod is installed, most of what it declares is
dead: its palette and metrics sit in a commented-out block and it expects Zen
to inject the pref values, so `var(--psu-better_ctrltab-*)` resolves to nothing
- and an unresolvable var does not mean "ignored", it means the whole
declaration computes to the initial value. Its rules win on specificity and
then evaluate to zero, which is where the flat grey sheet, the missing padding
and the square corners came from. Every value here outranks those selectors and
passes through `var(--psu-..., fallback)`, so the mod still wins whenever it
does resolve.

Want the cards bigger? Put `zoom: 1.12` back on `#ctrlTab-previews` and accept
the resampling - but cap it there: the popup window is `canvasWidth * 1.25` per
tab (~389px) while a card plus its gap is ~341px, so past ~1.14 the row is
wider than the window it lives in and the ends are cut off.

## The bookmarks strip, and two icons

The strip shows on the new tab page only, which is Firefox's own
`browser.toolbars.bookmarks.visibility = "newtab"`. That pref was already set
in the profile and did nothing, because this file used to carry a flat
`#PersonalToolbar { display: none }` that overrode it - it had to, since Zen
does not keep the strip in `#navigator-toolbox` at all. It lives in
`#zen-appcontent-navbar-container`, which this file pins `position: fixed`
top-right **because the window buttons share that same box**, so the strip was
trapped in a 36px corner. It is now pulled out into a full-width bar of its own
under the toolbar row, and the page is moved down to meet it.

That move has to be a `margin` on `#tabbrowser-tabpanels`, not padding: the
panels inside the deck are `position: absolute; inset: 0`, and an absolute
child resolves `top: 0` against its containing block's **padding box**, so
padding moves nothing. Measured with padding: the page still began at y=42 with
the strip sitting on top of it. With margin: y=74, exactly the strip's height
below the row.

Two icons in the address bar behave differently and only one of them is stuck.
The prompts' anchors (save-password, camera, location) live in
`#notification-popup-box` and already come and go with their prompt.
`#identity-permission-box` is the **key** that stays for as long as a site
holds any permission you have ever granted it - say yes to notifications once
and it is on that site forever. That one is hidden here; what it stands for is
still listed behind the padlock beside it. It is not moved to the right-hand
side because every permission doorhanger anchors to it, and moving the anchor
moves the arrow of every popup that points at it. The downloads button is not a
CSS matter at all - `browser.download.autohideButton` in `user.js` is what
makes it appear on the first download and leave again.

## Private windows

Zen tints a private window with `--zen-primary-color: rgb(11, 10, 11)`
(`zen-theme.css`). On a dark theme that is the same black as a normal window,
so the two are indistinguishable. `--ctab-private` at the top of the CSS paints
the window background, the address pill, the tab chips and a hairline above the
page, and both `[zen-private-window="true"]` (Zen's) and
`[privatebrowsingmode="temporary"]` (Firefox's) are matched.

The **tabs** in a private window used to be missing entirely. A private window
builds its space during init, before `#tabbrowser-tabs` is stamped horizontal,
so `tabs.js` propagates `orient="horizontal"` down to `.workspace-arrowscrollbox`
- a normal window restores its space from the session store afterwards and keeps
the template's `orient="vertical"`. The sideways `writing-mode: vertical-lr`
that makes the vertical strip run horizontally then turned that already-horizontal
row into a column, and every tab landed one full row *below* the toolbar. The
rule is now scoped to `[orient="vertical"]`.

## Compact mode is off

Zen's compact mode is built around the vertical sidebar: it makes
`#navigator-toolbox` a full-height box, parks it off the **left** edge of the
window and slides it back in while the pointer is near that edge. Here the
toolbox *is* the top row, so the state leaves the window with no toolbar and a
page that jumps whenever the pointer reaches the edge. The toggle is taken out
of the row, the pref is forced off, and the CSS puts the state back to normal
in case the keyboard shortcut ever turns it on.

## Does a Zen update wipe this?

No. Both files live in the **profile** (`~/.zen/<profile>/`), and updates
replace the application in `/opt/zen`, not the profile. What an update *can*
do is rename an internal element or class, and then a piece of the layout stops
matching - that is a CSS tweak, not a reinstall. This repo is the backup: after
any update, if something looks off, compare with `chrome/userChrome.css` here.
