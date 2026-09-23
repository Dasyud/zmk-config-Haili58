# Haili58 keyboard notes

Running record of what we've learned about this board, what's been decided, and
why. Read this before suggesting keymap changes.

## Owner and goals

- macOS user. Cmd is by far the most-used modifier; Ctrl is mostly for vim.
- New to LaTeX. Writes in Overleaf (vim mode helps with navigation) and
  sometimes VS Code. Long-term goal: effortless math typing.
- Frequent shortcuts: `Cmd+T`, `Cmd+W`, `Cmd+R`, `Cmd+C`, `Cmd+V`,
  `Option+Backspace` (delete word). Doesn't care about hold-to-repeat Backspace.
- Has not started using the board for real yet. Keeps falling back to the
  laptop keyboard and trackpad, mostly for navigation and switching spaces.
- Prefers editing the keymap here and flashing over using ZMK Studio.

## Hardware

- Split, 60 positions (12 per row, 6 per half), nice!nano v2 on each half.
  The left half is the central and holds the keymap.
- XDA keycaps: uniform height, wide flat tops, so there are no tactile
  landmarks. Blank/novelty caps on thumbs, shifts and the second Tab.
- Tall MX-style switches. Low profile would mean Choc, which is a new
  keyboard, not an upgrade.
- The inner-column top keys (positions 53, 54) are rotary encoder pushes, not
  buttons. They're bad to press, so don't put anything important on them.
- Has a display (`CONFIG_ZMK_DISPLAY=y`) showing the layer name.

## Thumb cluster geometry (the main ergonomic problem)

Left thumbs from outside in, from `haili58-layouts.dtsi`:

| Thumb | Position | x, y |
|---|---|---|
| 1 (outer) | 48 | 425, 462 |
| 2 | 49 | 525, 490 |
| 3 | 50 | 625, 500 |
| 4 (inner, rotated) | 51 | 650, 400 |

The right half mirrors this (positions 59, 58, 57, 56).

- The thumb moves in an arc and its pad faces sideways, but the cluster is flat
  and unangled. The owner finds thumbs 1 and 2 comfortable, and 3 and 4 far.
- Thumb 4 sits almost directly above thumb 3 (25 apart in x, 100 in y, keys
  are 100 wide). Reaching up for thumb 4 drags the thumb across thumb 3.
- A thumb pad (~20 mm) is wider than a 1u key (~19 mm), so adjacent thumb keys
  get pressed together. With XDA there's nothing to feel between them.
- Tenting helps a bit. Still to try: palm rests about level with the home row,
  and splaying each half outward a few degrees so the thumb's arc runs along
  the row.
- The inner-thumb rotation (`r: 30` in the README's wizard data) didn't make it
  into `haili58-layouts.dtsi`. It's cosmetic: it only changes how ZMK Studio
  draws the board.

## Current keymap (as of 2026-09-23)

Base layer, both halves mirrored:

| Key | Tap | Hold |
|---|---|---|
| Row-1 outer pinky (L) | Tab | Hyper (⇧⌃⌥⌘) |
| Row-2 outer pinky (L) | Esc | Layer 1 (Nav) |
| Row-2 outer pinky (R) | `'` | Layer 1 (Nav) |
| Row-3 outer pinky | Shift | double-tap = Caps Word |
| Inner column, lower (52, 55) | one-shot Shift | none |
| Inner column, upper (53, 54) | Mute / Play-Pause (encoder push) | none |
| Thumb 1 | Backspace | Cmd |
| Thumb 2 | Space | Option |
| Thumb 3 | Enter | Ctrl |
| Thumb 4 | none | Layer 2 |

Encoders: left = volume, right = up/down.

Thumb mod-taps use `&tml` / `&tmr`, which have a positional guard: the
modifier only fires if the next key is on the other half. Same-thumb rolls
stay plain taps. Use the opposite hand's modifier (right thumb Cmd + left `T`).

Layer 1 (Nav): right-hand `H J K L` = arrows, `U`/`I` = PgDn/PgUp,
`Y`/`O` = previous/next space (`Ctrl+Cmd+←/→`, used by the owner's space
switching app). F1–F15 and brackets `[ ] { } \` on the bottom row.

Layer 2: brightness, media, Bluetooth, bootloader, soft off. The owner never
uses it. Leave the contents alone but don't design around it.

## History of problems and fixes

- **Spotlight and deleted words while typing.** `&mt` defaults to
  `hold-preferred`, so any overlap made the thumb key a modifier. Rolling Space
  into Backspace gave `Option+Backspace` (delete word), and Backspace into Space
  gave `Cmd+Space` (Spotlight). Fixed on 2026-09-23 with the positional guard
  plus `tap-preferred`. This does not stop the thumb physically pressing two
  keys at once; that part is geometry.
- **Couldn't hold Tab** (Monkeytype restart). Both Tabs were hold-taps. The
  duplicate is gone now. Setting Monkeytype's quick restart to Esc or Tab is
  the easy fix.
- **Esc sat above Enter** on thumb 4. Moved Esc and Layer 1 to the row-2
  pinkies on 2026-09-13, and swapped Cmd to thumb 1 and Ctrl to thumb 3.

## Decisions and reasoning

- **Keep all thumb keys** for now (the owner's call, partly for Esc access in
  vim, though Esc is on the pinky now).
- **Home row mods deferred.** Debated, and they take months to get used to. If
  added later, use CAGS order for macOS (Ctrl/Option/Cmd/Shift from pinky to
  index), base the config on urob's "Timeless Home Row Mods" (ZMK), and reuse
  the same positional guard. precondition's guide is good for concepts but
  covers QMK only.
- **Shift is the priority comfort problem.** The pinky Shift is a far 1u reach.
  One-shot Shift on the inner-column keys is being trialled alongside it. Keep
  whichever wins and remove the other.
- **`quick-tap-ms` not wanted.** The owner doesn't need Backspace repeat.
- **Use vim motions for text navigation.** Layer 1 is for everything else.
- **No `\frac` style macros in firmware.** Characters belong in firmware,
  structures in an editor snippet engine (HyperSnips in VS Code; not Neovim
  yet while still learning LaTeX).
- **Math/symbol layer deferred.** Design it only after snippets are set up and
  it's clear which symbols still get typed raw. The draft idea was right-hand
  `\ { } [ ]` on the home row and `| _ ^ $ &` below.

## Backlog (not applied)

- Row-1 pinky as plain `&kp TAB`. Hyper is unused, so this would make Tab
  holdable.
- Parens on Nav: `[ ] ( ) \` instead of `[ ] { } \`. `{ }` come from Shift, and
  `( )` are missing from the layer.
- F6–F10 appear twice on Nav.
- Delete isn't bound anywhere.
- `require-prior-idle-ms` if modifiers still misfire during fast typing.
- Keycap and hardware ideas: a taller cap (SA/MT3) on the live thumb keys for
  a landmark, heavier springs on thumb switches if hot-swap, and pulling caps
  off any thumb key set to `&none`.

## Practice plan

1. Flash the current firmware first. Practising on a board that misfires
   teaches you to distrust it.
2. Go mostly cold turkey, except for time-critical work. Make the laptop
   keyboard hard to reach.
3. Week by week: letters on Monkeytype, then the five shortcuts using the
   opposite hand, then vim motions and Nav, then move all LaTeX writing to the
   split.
4. Settle key positions within about the first week. Changes after that undo
   muscle memory.
5. Consider keymap-drawer to render a reference sheet while the caps are blank.

## Workflow

1. Edit `config/haili58.keymap`, then commit and push. Pushing triggers the
   GitHub Actions build.
2. `./scripts/get-firmware.sh` waits for the build and puts the `.uf2` files in
   `firmware/`.
3. For keymap changes, flash only the left half: plug in via USB, double-tap
   reset, then `cp firmware/haili58_left-nice_nano_v2-zmk.uf2 /Volumes/NICENANO/`.
   Flash both halves only if `.conf` or the firmware version changes.
4. Leave `settings_reset` alone unless something breaks; it wipes Bluetooth
   pairings.

To check which firmware is on the board, tap the key left of `A`: Esc means the
2026-09-13 change or later, Tab means older.
