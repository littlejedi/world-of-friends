# World of Friends — Approved Baseline

This is the implementation baseline approved on 2026-07-10.

## Product

- Private, single-player 2.5D exploration game.
- True low-poly 3D presented with a fixed diagonal pixel-art camera.
- Native Apple Silicon Mac build first; browser export is secondary.
- Compact, geographically compressed Shanghai and Seattle worlds.

## Required loop

1. Start in Shanghai.
2. Explore Wukang Mansion, Xuhui Riverside, and the Oriental Pearl skyline.
3. Use the Shanghai ticket office and watch a shuttle cutscene.
4. Arrive in Seattle and meet Kent and Joey on the first visit.
5. Say hello, talk, invite them to travel, and trade cards.
6. Explore Pike Place Market, the Aquarium, Great Wheel, waterfront, and Space Needle.
7. Use the Seattle ticket office to return to Shanghai, with companions if invited.

## Technical decisions

- Godot 4.x with GDScript and the Compatibility renderer.
- 640×360 internal viewport, integer-scaled in a 16:9 window.
- Fixed 45-degree orthographic camera; zoom is allowed, rotation is deferred.
- Low-poly 3D characters; sprites reserved for lightweight ambience.
- One city is loaded at a time.
- Personal card images live under ignored `private_assets/`.

## MVP exclusions

- Multiplayer, combat, crafting, building, destructible terrain, card battles.
- 1:1 city maps, broad interiors, dynamic time of day, or full weather simulation.
- Public distribution infrastructure and notarization.
