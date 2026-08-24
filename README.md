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
  --ctab-t-panel: 200ms; /* the Ctrl+Tab switcher arriving */
  --ctab-switch-zoom: 1.3;  /* how big the Ctrl+Tab switcher is */
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

Menus and panels are **shaped** but not animated: rounded inset highlights on
the rows, hairline separators pulled in from the edges, a softer shadow and a
larger corner radius, all of it through `--panel-*` custom properties and
`currentColor` so Zen's theme keeps owning the actual colours. A popup's own
frame is **not** animated. On Linux each menu and panel is its
own OS-level window and both routes are closed from a user stylesheet:
`panel::part(content)` is not honoured from USER origin (verified - an
`outline` set that way never reached the element), and `-moz-window-transform`
/ `-moz-window-opacity` are not supported in this build. What a popup's
*contents* do is another matter, and they are the best case in the whole file:
Gecko throws away a popup's frames when it closes and builds them again when it
opens, so an animation on something inside one replays on every open rather
than only the first. That is how the Ctrl+Tab switcher's cards arrive.

### Why one pixel of `#nav-bar` is never still

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

So `#nav-bar` carries a 1px transparent inset outline whose colour cycles
between 0% and 0.4% black. It is invisible, it changes no layout, and it costs
one style sample per frame - which is a real cost, so it is off while the
window is not the one you are looking at, and off entirely under
`prefers-reduced-motion`. Delete the `ctab-clock` rule to be rid of it;
everything else keeps working, entrances just go back to being skipped
whenever the browser has been quiet for a moment.

### The Ctrl+Tab switcher

Only exists if `browser.ctrlTab.sortByRecentlyUsed` is on. Firefox lays it out
as **one screen-wide ribbon**, and that is structural rather than a style
choice - `browser-ctrlTab.js` writes an inline `panel.style.width` of
`canvasWidth * 1.25 * tabCount` (with `canvasWidth` always `availWidth * 0.85 / 7`)
and then positions the popup from that same number, so ~2530px on a 2560px
screen. Overriding the width from CSS would leave the popup anchored where a
2530px box was meant to start, i.e. against the left edge.

So the popup frame is made **invisible** and `#ctrlTab-previews` becomes the
visible card, centred inside it: a dark rounded panel laid out as a grid - two
across for four tabs, three for five or six, four for seven - with the frame
staying screen-wide behind it where nobody can see it. Columns are `max-content`
because the thumbnails are bitmaps `ctrlTab.js` has already sized; stretching
them to fractions would resample every one.

Two things worth knowing before editing that section:

- **`border-radius` is silently dropped on anything inside a `.ctrlTab-preview`
  button.** Verified by inline style in a driven profile: `44px` on the card,
  the inner box, the canvas wrapper and the `<canvas>` all read back `0px`,
  while `background`, `padding` and `display` set the same way all applied -
  and `#ctrlTab-previews`, one level up, takes `44px` happily. Rounding there
  is done with `clip-path: inset(0 round Npx)`, which is honoured everywhere.
- **A clip-path clips the box-shadow too**, so a ring on a rounded card has to
  be painted inside it. The selected card is a filled background plus an
  `inset` ring, not an outline.

If the **Better CtrlTab Panel** mod is installed, most of what it declares is
dead: its palette and metrics sit in a commented-out block and it expects Zen
to inject the pref values, so `var(--psu-better_ctrltab-*)` resolves to nothing
- and an unresolvable var does not mean "ignored", it means the whole
declaration computes to the initial value. Its rules win on specificity and
then evaluate to zero, which is where the flat grey sheet, the missing padding
and the square corners came from. Every value here outranks those selectors and
passes through `var(--psu-..., fallback)`, so the mod still wins whenever it
does resolve.

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
