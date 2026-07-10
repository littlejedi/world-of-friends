# Progress Log

## Checkpoint 0 — Approved plan

- 2.5D true-3D presentation approved.
- Mac-first private project approved.
- Compact Shanghai and Seattle postcard worlds approved.
- Kent and Joey group invitation and simple card trade approved.

## Checkpoint 1 — Playable procedural prototype

- Godot 4.6 project foundation with 640×360 viewport and Compatibility renderer.
- Procedural greybox art kit, landmark builders, lighting, and compact city boundaries.
- Fixed diagonal orthographic camera, WASD-relative movement, interaction, and zoom.
- Shanghai: Wukang Mansion, Oriental Pearl Tower, Xuhui Riverside, and ticket office.
- Seattle: Pike Place Market, Space Needle, Aquarium, Great Wheel, Elliott Bay, and ticket office.
- Two-way shuttle cutscene with destination loading.
- Kent and Joey introduction, group invitation, following, and cross-world travel.
- Placeholder one-card exchange and persistent JSON save.
- Automated smoke test covering both worlds, companions, trade, and return travel.
- Native M5 visual QA at 640×360; boundary, lighting, composition, and UI issues corrected.

## Checkpoint 2 — Richer exploration and personal collections

- Interactive plaques and information panels for all requested landmarks.
- Animated pixel-water shaders for the Huangpu River and Elliott Bay.
- Selectable player/friend card exchange instead of automatic first-card trading.
- Optional private card art from ignored project assets or the Godot user-data directory.
- Per-world player-position persistence with periodic and on-travel saves.
- Kent and Joey wave reactions when greeted.
- Unified high-contrast modal, button, and card-picker styling.
- Expanded automated coverage for disk persistence, landmarks, selected trades, water, and reactions.
- Native M5 visual QA for the trade panel and Seattle waterfront shader.

## Checkpoint 3 — Companion polish, collection, and Mac build

- Breadcrumb-based party following so Kent and Joey retrace the player's route around corners.
- Subtle companion idle head motion in addition to greeting waves.
- In-game collection viewer available with `C` and from the pause menu.
- Pause menu with resume, collection, explicit save, and quit actions.
- Collection count added to the exploration HUD.
- Original pixel-globe and shuttle application icon.
- Reproducible Universal macOS release export preset with tests and build output excluded.
- Successful 177 MB release app export containing native ARM64 and Intel executables.
- Exported binary launched headlessly without project/runtime errors.
- Automated suite expanded to 29 checks for breadcrumb following, collection, and pause actions.

## Checkpoint 4 — Living waterfronts and browser validation

- Moving Huangpu river boat and Elliott Bay ferry.
- Ambient Shanghai birds and Seattle gulls.
- Continuously rotating Great Wheel with a stationary base and label.
- Single-threaded WebGL 2 export preset using the Compatibility renderer.
- Successful 36 MB browser build with tests/build output excluded.
- Local in-app browser validation of WebAssembly loading and 2.5D rendering.
- `C` collection and Escape close interactions verified in the browser build.
- Browser console checked with no warnings or errors.
- Automated coverage expanded for boats, birds, ferry, and wheel rotation.

## Checkpoint 5 — City ambience and street life

- Seamless, original Shanghai and Seattle ambience synthesized into browser-safe stereo WAV loops at runtime.
- Persistent ambient-sound preference controlled by `M` or the pause menu.
- Non-interactive pedestrians following neighborhood-specific sidewalk routes in both cities.
- Explicit audio teardown during world changes and application exit.
- Headless-aware playback so automated validation remains resource-clean.
- Automated coverage expanded for pedestrians, generated audio, persistence, and pause-menu controls.

## Checkpoint 6 — Gameplay sound feedback

- Alternating synthesized footsteps tied to the player's walking cadence.
- Original interaction and arrival chimes for landmarks, friends, ticket offices, and shuttle landings.
- Seamless synthesized shuttle-engine loop during the space-travel cutscene.
- The existing `M` preference now controls ambience and gameplay effects together.
- Device-neutral pause copy and an expanded on-screen controls reminder.
- Automated coverage expanded to 46 checks for generated effects, player-step wiring, shuttle audio state, and unified muting.
- Browser rendering, unified mute UI, and console behavior revalidated after the HUD overlap fix.
- Universal macOS 0.6.0 build exported and launched successfully on Apple Silicon.

## Next checkpoint

- Replace key greybox landmarks with authored Blender models after the visual style kit is approved.
- Add surface-specific footstep variations after the final terrain materials are chosen.
- Decide whether to publish the private browser build to an access-controlled host.
