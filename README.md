# World of Friends

A private 2.5D pixel-style exploration game connecting handcrafted versions of Shanghai and Seattle.

The current checkpoint is a playable procedural prototype. It includes:

- Fixed 45-degree orthographic camera rendered at 640×360.
- Keyboard-relative movement, interaction prompts, and zoom.
- Shanghai greybox landmarks: Wukang Mansion, Xuhui Riverside, and Oriental Pearl Tower.
- Seattle greybox landmarks: Pike Place Market, Seattle Aquarium, Great Wheel, Space Needle, and Elliott Bay.
- Ticket offices, two-way shuttle cutscene, and persistent city state.
- Kent and Joey, group invitation, companion following, wave reactions, and selectable card trading.
- Interactive landmark plaques and animated pixel-water surfaces.
- Moving river boats, Seattle ferry traffic, bird flocks, pedestrians, and a rotating Great Wheel.
- Original looping city ambience synthesized at runtime, with a persistent sound preference.
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
- `M` — toggle ambient sound
- Mouse wheel — zoom
- Escape — close a conversation or open the pause menu
- `F8` — reset the development save

## Validate

```sh
HOME=/private/tmp/wof-godot-home godot --headless --path . --scene res://tests/smoke_test.tscn
```

Godot stores the personal game save in `user://world_of_friends_save.json`.

Optional personal card images can be placed under ignored `private_assets/cards/` using the card ID as the filename—for example `spark_mouse.png`. PNG, JPEG, and WebP are supported. The same files can alternatively live under the Godot user-data `cards/` directory.

See [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for the approved baseline and [docs/PROGRESS.md](docs/PROGRESS.md) for saved implementation checkpoints.

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
