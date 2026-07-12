# World of Friends

A private 2.5D pixel-style exploration game connecting handcrafted versions of Shanghai and Seattle.

The exported app now opens with a mode launcher. `Explore 2.5D Shanghai` enters the playable visual-overhaul slice; `Play 3D Prototype` opens the complete Shanghai–Seattle gameplay loop while its environments are migrated.

An isometric art-direction overhaul is now being developed alongside the stable 3D game. The Shanghai visual lab uses painted architectural surfaces, baked-looking shadows, detailed props, Y-sorted characters, and the existing keyboard controls. Its Wukang Mansion study now follows the real building's rounded bow, flat roof, wrapped stone arcade, and rooftop pavilion. Press `1`, `2`, or `3` in the lab to inspect the Wukang Mansion, Xuhui Riverside, and Oriental Pearl studies.

The current checkpoint is a playable procedural prototype. It includes:

- Fixed 45-degree orthographic camera rendered at 640×360.
- Keyboard-relative movement, interaction prompts, and zoom.
- Shanghai low-poly landmarks: Wukang Mansion, Xuhui Riverside, and Oriental Pearl Tower.
- Seattle low-poly landmarks: Pike Place Market, Seattle Aquarium, Great Wheel, Space Needle, and Elliott Bay.
- Ticket offices, party-aware two-way shuttle cutscene, and persistent city state.
- Kent and Joey, group invitation, companion following, face-to-face greeting waves with in-world speech, and selectable card trading.
- Interactive landmark plaques and animated pixel-water surfaces.
- Moving river boats, Seattle ferry traffic, bird flocks, pedestrians, and a rotating Great Wheel.
- Original city ambience, surface-aware alternating footsteps, interaction chimes, and shuttle audio synthesized at runtime, with a persistent sound preference.
- Persistent city guides with landmark hints and separate Shanghai/Seattle discovery progress.
- One-time Shanghai and Seattle souvenir cards awarded for completing each city guide.
- Original generated pixel artwork for every built-in creature and souvenir card, with private images still supported as overrides.
- Procedurally modeled landmark silhouettes, including Wukang's flatiron corner and the Space Needle's splayed legs.
- Local JSON save data, including per-world position, with `F8` available as a development reset.

## Run

Open `project.godot` in Godot 4.6 or newer and press **F6/F5**, or run:

```sh
godot --path .
```

Controls:

- `WASD` / arrow keys — move
- `E` / Space — interact
- `C` — view card collection
- `G` — open the current city guide
- `M` — toggle sound
- Mouse wheel — zoom
- Escape — close a conversation or open the pause menu
- `F8` — reset the development save

## Validate

```sh
HOME=/private/tmp/wof-godot-home godot --headless --path . --scene res://tests/smoke_test.tscn
```

Godot stores the personal game save in `user://world_of_friends_save.json`.

To launch the new isometric visual direction directly:

```sh
godot --path . --scene res://scenes/isometric_style_lab.tscn
```

Inside the 2.5D slice, use `1`, `2`, and `3` to switch among Wukang Mansion, Xuhui Riverside, and the Oriental Pearl Tower. Press Escape to return to the mode launcher.

Optional personal card images can be placed under ignored `private_assets/cards/` using the card ID as the filename—for example `spark_mouse.png`. PNG, JPEG, and WebP are supported. The same files can alternatively live under the Godot user-data `cards/` directory. Personal images replace the generated original fallback artwork.

See [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for the approved baseline and [docs/PROGRESS.md](docs/PROGRESS.md) for saved implementation checkpoints.
The art-reboot workflow and asset rules are documented in [docs/ISOMETRIC_ART_PIPELINE.md](docs/ISOMETRIC_ART_PIPELINE.md).
The real-world photographic research and the visual features derived from it are listed in [docs/SHANGHAI_VISUAL_REFERENCES.md](docs/SHANGHAI_VISUAL_REFERENCES.md).

## Build the Mac application

Godot's installed Universal template produces a native Apple Silicon and Intel application:

```sh
godot --headless --path . --export-release "macOS (Universal)" "builds/World of Friends.app"
```

The unsigned personal build is written to `builds/World of Friends.app`; `builds/` is intentionally ignored by Git. The release build is approximately 177 MB because it contains both processor architectures.

## Build the browser version

The single-threaded WebGL 2 build is generated with:

```sh
mkdir -p builds/web
godot --headless --path . --export-release "Web" "builds/web/index.html"
python3 -m http.server 8060 --bind 127.0.0.1 --directory builds/web
```

Open `http://127.0.0.1:8060/` while the temporary server is running. The browser package is approximately 36 MB and does not require cross-origin-isolation headers.
