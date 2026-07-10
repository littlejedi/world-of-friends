# World of Friends

A private 2.5D pixel-style exploration game connecting handcrafted versions of Shanghai and Seattle.

The current checkpoint is a playable procedural prototype. It includes:

- Fixed 45-degree orthographic camera rendered at 640×360.
- Keyboard-relative movement, interaction prompts, and zoom.
- Shanghai greybox landmarks: Wukang Mansion, Xuhui Riverside, and Oriental Pearl Tower.
- Seattle greybox landmarks: Pike Place Market, Seattle Aquarium, Great Wheel, Space Needle, and Elliott Bay.
- Ticket offices, two-way shuttle cutscene, and persistent city state.
- Kent and Joey, group invitation, companion following, hello dialogue, and placeholder card trading.
- Local JSON save data with `F8` available as a development reset.

## Run

Open `project.godot` in Godot 4.6 or newer and press **F6/F5**, or run:

```sh
godot --path .
```

Controls:

- `WASD` / arrow keys — move
- `E` / Space — interact
- Mouse wheel — zoom
- Escape — close a conversation
- `F8` — reset the development save

## Validate

```sh
HOME=/private/tmp/wof-godot-home godot --headless --path . --scene res://tests/smoke_test.tscn
```

Godot stores the personal game save in `user://world_of_friends_save.json`. Personal card images should be placed under ignored `private_assets/cards/` when that loader is added.

See [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for the approved baseline and [docs/PROGRESS.md](docs/PROGRESS.md) for saved implementation checkpoints.
