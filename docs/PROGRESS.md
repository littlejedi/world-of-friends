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

## Checkpoint 11 — Traveling together

- Shuttle cutscene now receives and renders the current travel-party state.
- Solo trips show the player alone; invited-party trips show player, Kent, and Joey windows in their character colors.
- Travel-party label and cutscene subtitle explicitly confirm who is aboard.
- Ticket-office confirmation notes when Kent and Joey will board with the player.
- Arrival message confirms that the friends reached Shanghai together.
- Automated coverage expanded to 71 checks for solo travel, party tickets, companion cutscenes, and party arrival.
- Browser WebGL build loaded and accepted movement input with no console warnings or errors.
- Universal macOS 0.11.0 build exported and launched successfully on Apple Silicon.

## Checkpoint 12 — Original pixel-card artwork

- Deterministic 32×40 pixel-art generator added for data-driven card thumbnails.
- Individual creature silhouettes and colorways for all seven built-in trade cards.
- Shanghai Skyline and Seattle Sound souvenirs receive distinct city-scene artwork.
- Generated thumbnails appear automatically in collection tiles and trade pickers.
- Optional private PNG, JPEG, or WebP images continue to override generated art.
- Generated textures are cached for reuse during the session.
- Automated coverage expanded to 74 checks for dimensions, caching, and distinct souvenir artwork.
- Web package exported successfully; interactive localhost artwork QA was deferred because the current sandbox quota blocked its test port.
- Universal macOS 0.12.0 build exported and launched successfully on Apple Silicon.

## Checkpoint 13 — Mutual greeting animations

- Saying hello now makes the player visibly wave alongside Kent or Joey.
- Group greetings synchronize the player's wave with both friends.
- Repeated greetings safely restart each character's arm animation.
- Automated coverage expanded to 76 checks for player and group greeting reactions.
- Universal macOS and browser release packages updated to version 0.13.0.

## Checkpoint 14 — In-world greetings

- One-on-one greetings now close the conversation panel before the animation begins.
- Player and friend turn to face one another while waving.
- Pixel-style `HELLO!` and `HI!` speech appears above the characters, then fades away.
- Seattle's group greeting applies the same coordinated presentation to Kent and Joey.
- The visual-preview harness can reproduce Seattle greetings for future browser checks.
- Automated coverage expanded to 80 checks for visible panels, speech, and facing direction.
- Browser visual QA confirmed readable, separated greeting text at the target presentation scale.
- Universal macOS and browser release packages updated to version 0.14.0.

## Checkpoint 15 — Isometric art-direction foundation

- Parallel 2D isometric Shanghai visual slice added without replacing the stable 3D game.
- Locked 64×32 tile projection with deterministic cobblestone, sidewalk, and road variation.
- Wukang-inspired hero building study with brick courses, window bays, architectural bands, doors, gabled roofs, tower cap, chimneys, and baked-looking shadows.
- Reusable depth-sorted trees, lamps, crates, bench, and planter props.
- Controllable pixel character using the production WASD input actions.
- Separate environment, Y-sorted actor/prop, and HUD layers establish the migration architecture.
- Automated coverage expanded to 84 checks for projection, props, player presence, and layer structure.
- Reproducible art-production and migration workflow documented for the remaining city overhaul.
- Native M5 capture at 640×360 corrected hero-building crop, character scale, and roof texture density.
- Mac and browser package versions advanced to 0.15.0 while the existing main game remains the default entry point.

## Checkpoint 16 — Photo-informed Shanghai landmark studies

- Real-world image research completed for Wukang Mansion, Xuhui Riverside, and the Oriental Pearl Tower.
- Visual-reference document records sources and the architectural traits used for original game art.
- Isometric lab now switches among all three studies with the `1`, `2`, and `3` keys.
- Wukang Mansion study upgraded with a ship-like wedge, stone arcade treatment, balconies, façade bands, brick courses, and plane-tree streets.
- Xuhui Riverside study adds the Huangpu River, water traffic, broad promenade, red running track, railings, skyline, greenery, and preserved orange industrial cranes.
- Oriental Pearl study adds tripod supports, stacked pixel spheres, observation decks, antenna, river edge, plaza, and surrounding Pudong skyline.
- Per-study composition scales keep the landmark silhouettes readable at 640×360.
- Automated coverage expanded to 87 checks, including feature signatures for all three landmark studies.
- Native M5 captures at 640×360 corrected the Wukang arcade, Xuhui skyline height, and Oriental Pearl spire framing.
- Mac and browser package versions advanced to 0.16.0 while the existing 3D game remains the default entry point.

## Checkpoint 17 — Wukang Mansion silhouette correction

- Two user-supplied street photographs used to correct the Wukang study's overall massing and corner treatment.
- Sharp triangular tower and steep gabled cap removed.
- Five-segment rounded bow now joins the long residential body without a pointed tip.
- Flat roof, heavy projecting cornice, and pale rounded rooftop pavilion match the real horizontal roofline.
- Stone arcade wraps the curved base instead of ending at the straight façade.
- Five upper window tiers, straight and curved balcony rails, and exterior utility boxes reinforce the real façade rhythm.
- Wukang-specific composition scale keeps the taller building readable at 640×360.
- Automated coverage expanded to 88 checks with a rounded-bow and flat-roof regression signature.
- Native M5 capture verified the corrected silhouette at the target resolution.
- Mac and browser package versions advanced to 0.17.0 while the stable 3D game remains the default entry point.

## Next checkpoint

- Review the Shanghai isometric slice and lock its palette, texture density, and character scale.
- Convert one complete Shanghai gameplay block to the new renderer after visual approval.
- Replace deterministic study surfaces with approved painterly raster assets as they become available.
- Install Blender only if the pre-rendered hero-asset workflow is approved.
- Decide whether to publish the private browser build to an access-controlled host.
