# ShinyApps Store — brand assets

The mark is a **hex sticker turned into a shopping bag**: a flat-top hexagon whose top
edge is the bag opening, with the handle rising out of it, a bold **R** inside, and a gold
four-point spark on the shoulder for "Shiny / just published".

- **Silhouette** = store (bag) + R ecosystem (hexagon), fused into one shape.
- **Content** = R, the language base.
- **Accent** = the gold spark, reserved for "featured / new".

Rule of thumb: **one silhouette + one content + one spark per mark.** Do not add a second
silhouette (no bag *plus* grid *plus* cube in the same lockup).

## Files

| File | Use |
|---|---|
| `shinyapps-mark.svg` | Symbol only, transparent. Dark and light backgrounds. |
| `shinyapps-lockup-dark.svg` | Horizontal lockup for dark UI (launcher, About, dark docs). |
| `shinyapps-lockup-light.svg` | Horizontal lockup for light UI (GitHub README, catalog page). |
| `shinyapps-appicon.svg` | 1024×1024 rounded-square app icon master. Export to PNG/ICO/ICNS. |
| `brand.css` | Tokens as CSS variables + `.sa-hero` component for Shiny/web UI. |
| `tokens.json` | Same tokens for build tooling / the Electron launcher. |

## Palette

| Token | Hex | Role |
|---|---|---|
| Ink | `#0B1626` | Base surface, primary text on light |
| R Blue | `#2F6BFF` | Brand primary, interactive states |
| Shiny Cyan | `#4FD1FF` | Gradient light end, hover / focus glow |
| Spark Gold | `#FFC85C` | **Only** "featured / new"; ≤ 5 % of any layout |
| Paper | `#F4F8FF` | Light surfaces |
| Text muted | `#8FB0D8` | Secondary text on dark |

The mark gradient is `#79DCFF → #2F6BFF → #1A3BB4` at 135°. Do not add a second gradient
family, rainbow fills, or a bevel on top of the existing facet shading.

### App icon tile (SKY TINT)

The app icon uses a light tile, not the dark UI canvas:

- Tile: `#EEF6FF → #D2E4FF` at 135°, with an 8 px inner border at 12 % ink.
- Mark: the brand gradient above; R in paper white.
- Spark: `#FFC65C → #D17A0A` — the gold is deepened so it survives on a light tile.
- No glow and no drop shadow: at 16–48 px they read as dirt.

Keep the 8–12 % ink border. Without it the light tile dissolves on a white
taskbar, a white browser tab, or a printed page.

## Type

- Wordmark: `Shiny` italic + `Apps` upright, weight 700/600, tracking ≈ −2.5 %.
- UI: Segoe UI / Inter fallback stack.
- Numbers, versions, hashes: mono (Cascadia Mono / Consolas).
- The `i` dot becomes the gold spark **only in custom display type**, not in body text.
- Convert the wordmark to outlines before shipping print or installer artwork.

## Clear space and sizes

- Clear space on every side = the height of the bag handle.
- Full lockup ≥ 24 px tall. Below 24 px use the simplified mark (no handle, no R).
- Favicon / tray target: 16 px. At that size the handle stroke is < 1 px — drop it.
- Monochrome: silhouette + R only, single ink or single paper. No gradient, no spark.

## Do / don't

**Do** keep the flat-top hexagon (its top edge is the bag rim), keep the gold spark at ≤ 5 %
of the composition, and let the italic `Shiny` carry the motion.

**Don't** copy the official R logo letterform (R Foundation trademark), put the bag inside
another badge, add a grid and a cube to the same lockup, or thin the handle below 8 % of
the mark width.

## Installer icons (Windows / macOS)

`build-suite.R` reads the **first** `.ico` in `icons/ico/` and the **first** `.icns` in
`icons/mac/`. Export the master, then replace those binaries after visual sign-off:

```bash
# 1) SVG -> 1024 PNG
rsvg-convert -w 1024 -h 1024 brand/shinyapps-appicon.svg -o /tmp/sa-1024.png

# 2) Windows .ico (ImageMagick 7; use `convert` on ImageMagick 6)
magick /tmp/sa-1024.png -define icon:auto-resize=256,128,64,48,32,16 icons/ico/shinyapps.ico

# 3) macOS .icns
mkdir -p /tmp/sa.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s /tmp/sa-1024.png --out /tmp/sa.iconset/icon_${s}x${s}.png
  sips -z $((s*2)) $((s*2)) /tmp/sa-1024.png --out /tmp/sa.iconset/icon_${s}x${s}@2x.png
done
iconutil -c icns /tmp/sa.iconset -o icons/mac/shinyapps.icns
```

Keep one `.ico` and one `.icns` per directory so the build never picks a stale file.

## Where this is applied

- `README.md` / `README.zh-CN.md` — lockup, theme-aware (`<picture>` + `prefers-color-scheme`).
- `catalog/render_readme.py` — header on the published catalog page; `brand/` is copied to
  `gh-pages` by `.github/workflows/publish-catalog.yml`.
- `apps/about/` — branded About screen (mark from `www/logo.svg`, tokens inlined).
