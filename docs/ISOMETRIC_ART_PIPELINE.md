# Isometric Art Pipeline

This document defines the visual-overhaul workflow begun in checkpoint 15. The stable 3D game remains the production entry point until a playable isometric block is approved.

## Locked composition rules

- 64×32 pixel 2:1 isometric ground tiles.
- 640×360 internal viewport with nearest-neighbor presentation.
- Bottom-center anchors for characters and props.
- Light falls from the upper left; shadows travel down and right.
- Environment, Y-sorted actors/props, and interface remain separate layers.
- Ground texture uses clustered value changes and deliberate cracks rather than uniform noise.
- Architecture uses warm masonry, cool roofs, deep blue-green windows, and selective golden light.
- Landmark silhouettes stay recognizable even when geographically compressed.

## Vertical-slice workflow

1. Build one small city block in `isometric_style_lab.tscn`.
2. Validate scale, walkability, occlusion, texture density, and readability at 640×360.
3. Lock the palette and camera rules before producing a large asset library.
4. Rebuild the block as production `Node2D`, `CharacterBody2D`, `Area2D`, and collision components.
5. Connect the existing dialogue, guide, card, save, audio, and travel systems.
6. Replace the stable 3D world only after the entire required gameplay loop works in the new renderer.

## Asset-production workflow

The current style lab is deterministic Godot drawing code so perspective and scale can be judged before external tooling is added.

For production hero assets:

1. Collect reference photography for the landmark.
2. Build a simplified original model in Blender with a locked orthographic camera.
3. Render color, shadow, and optional normal passes from the same light rig.
4. Downsample to the target pixel footprint.
5. Paint over the render in Aseprite or Krita to simplify texture, strengthen edges, and add selective detail.
6. Export transparent PNG sprites with bottom-center anchors.
7. Keep collision independent from the painted sprite.

AI-generated imagery is used for mood, palette, material, and composition exploration. It is not used as an uncorrected tile set because independent generations do not guarantee seamless edges, consistent projection, or stable lighting.

## Initial reusable kit

- Cobblestone, sidewalk, and road surfaces.
- Brick wall, band, window, door, roof, chimney, and tower modules.
- Tree, lamp, crates, bench, and planter props.
- Player movement silhouette.
- Wukang-inspired hero-building study.

## Approval gate

Before converting gameplay, review:

- Whether the building texture is rich enough without becoming noisy.
- Whether the 64×32 grid feels detailed enough at the target viewport.
- Whether the player should be larger relative to doors and props.
- Whether outlines should be stronger or remain material-colored.
- Whether future hero buildings should use Blender renders or fully painted sprites.
