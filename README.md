## Folder Structure

```
res://
├── assets/
│   ├── 3d/
│   │   ├── characters/
│   │   │   ├── lumina/
│   │   │   ├── virtue_resonators/
│   │   │   │   ├── deer_benignity/
│   │   │   │   ├── bear_temperance/
│   │   │   │   └── owl_cognition/
│   │   │   ├── virtue_sprites/
│   │   │   │   ├── pink/
│   │   │   │   ├── blue/
│   │   │   │   ├── green/
│   │   │   │   └── white/
│   │   │   └── void_hushed/
│   │   ├── environments/
│   │   │   ├── sanctuary_spines/
│   │   │   ├── worlds_heart/
│   │   │   └── corrupted_areas/
│   │   ├── props/
│   │   └── effects/
│   ├── 2d/
│   │   ├── ui/
│   │   ├── icons/
│   │   └── textures/
│   └── audio/
│       ├── bgm/
│       └── sfx/
├── scripts/
|   |── camera/
│   ├── characters/
│   │   ├── player/
│   │   │   ├── lumina.gd
│   │   │   ├── lumina_movement.gd
│   │   │   └── lumina_abilities.gd
│   │   ├── enemies/
│   │   │   └── void_hushed.gd
│   │   ├── npcs/
│   │   │   ├── virtue_resonator.gd
│   │   │   └── virtue_sprite.gd
│   │   └── base/
│   │       └── character_base.gd
│   ├── mechanics/
│   │   ├── divergence/
│   │   │   ├── divergence_system.gd
│   │   │   ├── attack_mode.gd
│   │   │   ├── defense_mode.gd
│   │   │   └── introspection_mode.gd
│   │   ├── self_frequency.gd
│   │   ├── buoyancy.gd
│   │   ├── glowing.gd
│   │   └── corruption_system.gd
│   ├── world/
│   │   ├── world_heart.gd
│   │   ├── sanctuary_spine.gd
│   │   └── environment_interactions.gd
│   │   └── test_environment.gd
│   ├── ui/
│   │   ├── hud.gd
│   │   ├── self_frequency_display.gd
│   │   └── menu_system.gd
│   ├── managers/
│   │   ├── game_manager.gd
│   │   ├── audio_manager.gd
│   │   ├── save_manager.gd
│   │   └── scene_manager.gd
│   └── utilities/
│       ├── constants.gd
│       ├── helpers.gd
│       └── state_machine.gd
├── scenes/
│   ├── characters/
│   │   ├── player/
│   │   │   └── lumina.tscn
│   │   ├── enemies/
│   │   ├── npcs/
│   │   └── prefabs/
│   ├── world/
│   │   ├── levels/
│   │   ├── interactive_elements/
│   │   └── environment/
│   │   └── test_environment.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   ├── menus/
│   │   └── overlays/
│   └── system/
│       ├── game_manager.tscn
│       └── audio_manager.tscn
├── shaders/
│   ├── corruption_shader.gdshader
│   ├── black_white_world.gdshader
│   ├── lumina_glow.gdshader
│   └── frequency_waves.gdshader
├── docs/
│   ├── game_design.md
│   ├── mechanics_spec.md
│   └── asset_list.md
└── config/
    ├── input_map.cfg
    ├── project_settings.gd
    └── tags_and_layers.gd
```

## Key Script Structure Overview:

### Core Player Scripts:
- `lumina.gd` - Main player controller
- `lumina_movement.gd` - Platformer movement, jumping, buoyancy
- `lumina_abilities.gd` - Glowing, frequency powers

### Divergence Combat System:
- `divergence_system.gd` - Main combat manager
- `attack_mode.gd` - Benignity pink wave attacks
- `defense_mode.gd` - Temperance blue shield
- `introspection_mode.gd` - Cognition time slowdown

### Core Systems:
- `self_frequency.gd` - Health/life bar system
- `corruption_system.gd` - World corruption mechanics
- `game_manager.gd` - Main game state management

### World & Progression:
- `world_heart.gd` - Main objective system
- `virtue_resonator.gd` - Boss/guardian characters
- `sanctuary_spine.gd` - Level/dungeon management