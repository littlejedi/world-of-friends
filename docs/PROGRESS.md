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

## Checkpoint 7 — City guides and landmark discovery

- Persistent landmark discovery state shared across travel and future sessions.
- Separate Shanghai and Seattle guide entries with concise wayfinding hints.
- `G` guide overlay with discovered and not-yet-visited landmark cards.
- New-discovery treatment when a landmark plaque is inspected for the first time.
- HUD guide completion shown alongside the player's card count.
- City guide access added to the expanded pause menu.
- Automated coverage expanded to 52 checks for guide metadata, disk persistence, discovery deduplication, city-specific progress, and guide UI.
- Browser guide layout and full pause menu validated at the target resolution with no console warnings or errors.
- Universal macOS 0.7.0 build exported and launched successfully on Apple Silicon.

## Checkpoint 8 — City guide souvenir rewards

- Shanghai Skyline souvenir card awarded when all Shanghai landmarks are discovered.
- Seattle Sound souvenir card awarded when all Seattle landmarks are discovered.
- One-time reward claims persisted alongside discoveries and protected from duplicate awards.
- Guide-completion treatment added to landmark panels and completed guide overlays.
- Existing arrival chime reused as immediate completion feedback.
- Souvenir cards appear in the existing collection and participate in the data-driven card system.
- Older saves with already-completed guides can claim their newly introduced souvenir on the next landmark visit.
- Automated coverage expanded to 59 checks for incomplete guides, both rewards, persistence, duplicate prevention, and save migration.
- Web package exported successfully; interactive localhost QA was deferred because the current sandbox could not open its test port.
- Universal macOS 0.8.0 build exported and launched successfully on Apple Silicon.

## Checkpoint 9 — Surface-aware footsteps

- World-position classification for road, ground, Shanghai promenade, and Seattle pier surfaces.
- Eight original footstep samples synthesized at runtime: two alternating variants per surface.
- Softer ground steps, sharper road contact, bright promenade taps, and hollow Seattle pier knocks.
- Surface routing integrated with the existing player walking cadence and unified sound preference.
- Automated coverage expanded to 63 checks for generated profiles and surface selection in both cities.
- Browser movement, guide rendering, and console behavior revalidated with the expanded audio bank.
- Universal macOS 0.9.0 build exported and launched successfully on Apple Silicon.

## Checkpoint 10 — Landmark silhouette polish

- Reusable triangular-prism and angled-beam helpers added to the procedural art kit.
- Wukang Mansion upgraded with a wedge-shaped flatiron nose, point windows, canopy, and roof cap.
- Oriental Pearl Tower upgraded with tripod supports, a podium, deck rings, and upper beacon.
- Pike Place Market upgraded with its facade clock, hands, and flower-topped stalls.
- Space Needle upgraded with three splayed legs and a layered observation saucer.
- Automated coverage expanded to 67 checks for the new landmark-defining geometry.
- Browser visual QA confirmed the flatiron silhouette reads cleanly from the gameplay camera with no console warnings or errors.
- Universal macOS 0.10.0 build exported and launched successfully on Apple Silicon.

## Next checkpoint

- Replace procedural landmark models with authored Blender assets after the visual style kit is approved.
- Decide whether to publish the private browser build to an access-controlled host.
