# Extinction Sanctuary — Master Game Development Plan

**Project:** Idle Animals  
**Working Title:** Extinction Sanctuary  
**Document:** Authoritative Product & Development Plan  
**Status:** Active Development  
**Last Updated:** 2026-09-15  

> This document is the source of truth for the game's direction, priorities, architecture, UX, economy, content progression, and completion criteria.

---

# 1. Game Vision

Build a polished mobile-first idle management game inspired by the satisfying progression loops of **Egg, Inc., Gold & Goblins, and Lumber Inc.**, but with a distinct extinct-animal conservation identity.

The player operates a growing network of wildlife sanctuaries. They recover genetic material, revive extinct species, build habitats, grow healthy populations, perform research, send expeditions, discover fossils, restore ecosystems, and eventually progress from recently extinct animals into Ice Age and prehistoric life.

### Core fantasy

> **Bring extinct animals back, build thriving sanctuaries, restore lost ecosystems, and rebuild the history of life.**

Animals are never commodities. The economy comes from conservation progress, research, discoveries, healthy populations, habitat development, expeditions, and ecosystem restoration.

---

# 2. Current Project Status

The repository has progressed well beyond the original prototype.

Current implementation already includes a substantial idle-game foundation with:

- Flutter/Dart application structure.
- Riverpod state management.
- Game state and simulation foundations.
- Habitats and active-habitat switching.
- Population, welfare, food, and water systems.
- DNA, credits, and research resources.
- Upgrades.
- Staff.
- Research.
- Expeditions.
- Missions/directives.
- World map.
- Archive.
- Ecosystem restoration/prestige.
- Offline-progress handling.
- Save/persistence foundations.
- Android build workflow.

The latest implementation added the exploration/species/world-map/prestige/mission layer. The architecture is therefore entering the **polish + validation + generalized-content** stage rather than needing another ground-up rewrite.

## Current visual state

The main sanctuary screen now has a strong mobile idle-game hierarchy:

1. Resource header.
2. Sanctuary title/status.
3. Large sanctuary viewport.
4. Population/welfare/needs panel.
5. Persistent bottom navigation.

The current UI direction is intentionally dark, clean, readable, and information-dense without becoming visually noisy.

## Immediate problem

The sanctuary viewport is still visually underdeveloped compared with the surrounding UI. It currently behaves more like a placeholder than the living centerpiece of the game.

**The next major milestone is therefore not another menu or currency. It is making the sanctuary itself feel alive.**

---

# 3. Development Philosophy

Follow these rules throughout development:

- **Do not rewrite working systems without a concrete reason.**
- **Do not add content faster than the engine can support it.**
- **Do not hard-code individual species into gameplay systems.**
- **Do not build every planned feature before validating the core loop.**
- **Gameplay correctness comes before visual complexity.**
- **The main sanctuary should remain the center of the experience.**
- **Automation should remove repetitive tapping.**
- **Every new system must work with deterministic offline progression where applicable.**
- **Numbers must be understandable and economically tunable.**
- **A new species should primarily require content/data, not new gameplay code.**

---

# 4. Priority Order

Development should proceed in this order:

1. **Stabilize the current build.**
2. **Finish the sanctuary viewport.**
3. **Validate active simulation.**
4. **Validate deterministic offline simulation.**
5. **Validate persistence and migration.**
6. **Generalize species/habitat/content definitions.**
7. **Balance the complete Dodo Island vertical slice.**
8. **Polish navigation and information architecture.**
9. **Expand staff/research/expeditions/missions.**
10. **Add additional recent-extinction species.**
11. **Expand regions and habitats.**
12. **Add restoration/prestige depth.**
13. **Add Ice Age and prehistoric tiers.**
14. **Add events, variants, achievements, and long-term retention systems.**
15. **Final optimization, accessibility, QA, and release preparation.**

---

# 5. Core Gameplay Loop

```text
Recover DNA / Discover Evidence
          ↓
Revive Species
          ↓
Build Habitat
          ↓
Grow Population
          ↓
Provide Food + Water + Enrichment
          ↓
Healthy Population Generates DNA + Research
          ↓
Upgrade Habitat / Staff / Research
          ↓
Unlock New Capabilities
          ↓
Send Expeditions
          ↓
Discover Fossils / Species / Regions
          ↓
Restore Ecosystem
          ↓
Earn Permanent Restoration Bonuses
          ↓
Expand to the Next Region / Era
          ↓
Repeat at Greater Scale
```

The loop must be satisfying both:

- while actively playing;
- while away from the game.

The player should always understand **what they are working toward next**.

---

# 6. MVP / Vertical Slice

The first truly complete milestone is **Dodo Island as a polished vertical slice**.

A player must be able to:

- Start a sanctuary.
- Revive the Dodo.
- Build and upgrade its habitat.
- Maintain food and water.
- Grow the population.
- See welfare affect performance.
- Generate DNA and research.
- Buy meaningful upgrades.
- Hire and improve basic staff.
- Complete initial research.
- Complete a short mission/directive chain.
- Send and complete a basic expedition.
- Leave the game.
- Return and receive deterministic offline progress.
- Save and reload without losing progress.
- Reach a meaningful Dodo Island restoration milestone.
- Perform restoration and retain permanent progression.

### MVP completion test

A new player should be able to play for a meaningful session, close the app, return later, immediately understand what happened, make a few meaningful decisions, and know what their next goal is.

---

# 7. Economy

Keep the core economy small.

## 7.1 Credits

Primary construction and management currency.

Used for:

- Habitat upgrades.
- Infrastructure.
- Staff.
- Food systems.
- Water systems.
- Automation.
- General sanctuary improvements.

## 7.2 DNA

Genetic progression resource.

Used for:

- Species revival.
- Genetic research.
- Breeding improvements.
- Advanced species/discovery systems.

## 7.3 Research

Technology/conservation progression resource.

Used for:

- Research tree.
- Automation.
- Habitat efficiency.
- Expedition technology.
- Advanced conservation systems.

## 7.4 Restoration Points

Permanent progression currency earned through ecosystem restoration.

Used for global bonuses that survive local restoration resets.

## 7.5 Premium currency

**Not part of the MVP.**

Do not design the core game around monetization until the gameplay loop is proven fun.

---

# 8. Data-Driven Architecture

Gameplay definitions must be separated from UI and simulation rules.

Target architecture:

```text
SpeciesDefinition
       ↓
HabitatDefinition
       ↓
Simulation Rules
       ↓
Game State
       ↓
Riverpod
       ↓
Generic UI
```

Adding a species such as Thylacine should not require copying Dodo gameplay code.

## SpeciesDefinition

Minimum fields:

- id
- name
- scientificName
- category
- era
- extinctionDateOrEra
- habitatId
- basePopulationCapacity
- baseBreedingSeconds
- baseFoodRequirement
- baseWaterRequirement
- baseHappiness
- baseDnaRate
- baseResearchRate
- unlockRequirements
- discoveryRequirements
- rarity/variant configuration
- art references
- audio references

## HabitatDefinition

Minimum fields:

- id
- name
- regionId
- biomeType
- habitatType
- baseCapacity
- foodCapacity
- waterCapacity
- climate
- enrichment
- upgradeDefinitions
- visualLevelReferences

## StaffDefinition

- id
- role
- baseBonus
- secondaryBonus
- upgradeCurve
- unlockRequirements

## ResearchDefinition

- id
- branch
- prerequisites
- cost
- effects
- unlocks

## ExpeditionDefinition

- id
- region
- duration
- cost
- guaranteedRewards
- discoveryPool
- rareRewards
- staffModifiers

## MissionDefinition

- id
- title
- description
- objectiveType
- objectiveValue
- prerequisites
- rewards
- nextMissionId

---

# 9. Simulation Engine

The simulation engine is the technical heart of the game.

It must be:

- deterministic;
- testable without Flutter widgets;
- independent of UI;
- safe across restarts;
- suitable for active simulation;
- suitable for offline simulation;
- resistant to time/clock exploits;
- tunable through data/configuration.

Conceptually:

```text
GameState + elapsedTime
        ↓
SimulationEngine
        ↓
Population / Welfare / Production / Breeding / Research / Expeditions
        ↓
New GameState
```

The UI displays state. It does not own game rules.

### Time handling

Use elapsed timestamps rather than frame counts.

Avoid making gameplay dependent on how frequently Flutter rebuilds widgets.

---

# 10. Offline Progress

Offline progress must use the same simulation rules as active play wherever practical.

```text
Last Save Time
      ↓
Current Time
      ↓
Validated Elapsed Duration
      ↓
Offline Simulation
      ↓
Welcome Back Report
      ↓
Updated Game State
```

Initial progression target:

- 2 hours base cap.
- 4 hours upgrade.
- 8 hours upgrade.
- 12 hours upgrade.
- 24 hours maximum early-game target.

### Security / correctness requirements

Protect against:

- negative elapsed time;
- extreme future timestamps;
- repeated offline collection;
- overflow;
- invalid save timestamps;
- device clock manipulation where practical;
- duplicate reward application.

Offline rewards should be calculated once and committed atomically.

---

# 11. Save System

Persistence must be considered a core feature, not a later convenience.

Requirements:

- Versioned save schema.
- Explicit migrations.
- Atomic writes where possible.
- Corruption recovery.
- Safe defaults for missing fields.
- No factory/content data overwritten by player state.
- Player changes stored independently from immutable definitions.
- Progress survives app updates.

### Save invariant

A new game version must never silently destroy meaningful player progress because a model changed.

---

# 12. Animal Welfare

Welfare should make sanctuary management meaningful without becoming a punishment simulator.

Track:

- Food.
- Water.
- Happiness.
- Habitat suitability.
- Enrichment.
- Population capacity.
- Breeding availability.

Example:

```text
Food          96%
Water         91%
Happiness     94%
Habitat      100%

Population Growth   +18%
DNA Production      +12%
Research            +10%
```

### Welfare rules

- Missing a short collection window should not kill animals.
- Low welfare should reduce efficiency/growth gradually.
- Good welfare should provide positive bonuses.
- Automation should protect welfare from repetitive maintenance.

Desired player feeling:

> "I am running a thriving sanctuary," not "I am desperately preventing my animals from dying."

---

# 13. Breeding

Breeding is a predictable timer-based progression system.

Example:

```text
Dodo
Breeding: 00:18
Offspring: 1
Population: 62 / 90
```

Research/staff/upgrades may improve:

- Breeding speed.
- Offspring count.
- Population capacity.
- Genetic quality.
- DNA output.

Do not use paid gambling, loot boxes, or predatory breeding mechanics.

---

# 14. Production

Healthy sanctuary activity generates progression.

Core relationships:

```text
Healthy Animals → DNA
Healthy Animals → Research
Fossils → DNA / Discoveries
Discoveries → Research
Habitat Quality → Efficiency
Staff → Efficiency
Research → Long-Term Improvements
```

Production should remain easy to understand.

Every resource should answer:

1. Where does it come from?
2. What does it buy?
3. Why do I want more of it?

---

# 15. Sanctuary Viewport — NEXT MAJOR MILESTONE

The sanctuary viewport must become the visual centerpiece of the game.

The surrounding UI is already strong enough that the viewport is now the largest visible gap.

## Required progression

### Level 1 habitat

Show:

- Basic terrain.
- Small enclosure.
- A few plants.
- Water source.
- Food/feeding area.
- Small visible animal population.

### Mid-level habitat

Add:

- More natural terrain.
- Additional vegetation.
- Enrichment objects.
- Shelter.
- Staff/infrastructure.
- More visible animals.

### High-level habitat

Add:

- Large natural environment.
- Multiple terrain layers.
- Richer vegetation.
- Water features.
- Advanced enrichment.
- Larger visible population.
- Environmental details reflecting progression.

## Animal behavior

Animals should visibly:

- walk;
- idle;
- eat;
- drink;
- rest;
- interact with the habitat;
- occasionally interact with one another;
- breed where appropriate.

Animation should be lightweight. Do not sacrifice performance for unnecessary visual effects.

## Tap interaction

Tapping the sanctuary should provide satisfying feedback and may grant a small active-care interaction where appropriate.

The interaction must remain optional once automation is unlocked.

---

# 16. Main Screen UX

The sanctuary is the home screen.

Preferred hierarchy:

```text
┌─────────────────────────────────┐
│ Credits      DNA       Research  │
│ +/s          +/s          +/s    │
├─────────────────────────────────┤
│ 🏝️ Dodo Island Sanctuary  Lv 7 │
├─────────────────────────────────┤
│                                 │
│          LIVING HABITAT         │
│       🦤     🌿      🦤          │
│          💧      🦤              │
│     🌴       🌱       🪨         │
│                                 │
├─────────────────────────────────┤
│ Dodo Population   62 / 90       │
│ Welfare ████████████ 100%       │
│ Food AUTO       Water AUTO      │
├─────────────────────────────────┤
│ 🏝️       ⭐       🧑‍🌾       🔬  📜 │
│ Sanctuary Upgrades Staff Research│
│                    Archive       │
└─────────────────────────────────┘
```

## UX rules

- Mobile-first.
- Fast.
- Minimal taps.
- Large readable numbers.
- Clear production rates.
- Clear progress bars.
- Strong feedback for purchases.
- Avoid unnecessary confirmation dialogs.
- Avoid deep menu trees.
- Avoid excessive animation.
- Keep the sanctuary visible as much as possible.
- Do not make automation obsolete through additional chores.

---

# 17. Navigation Architecture

The current screen architecture contains separate sheets/screens for major secondary systems.

Keep that separation.

### Primary bottom navigation

- Sanctuary.
- Upgrades.
- Staff.
- Research.
- Archive.

### Secondary systems

- World Map.
- Expeditions.
- Missions/Directives.
- Ecosystem Restoration.
- Settings/audio.

Secondary systems should not all compete for permanent space on the home screen.

### UI principle

**The home screen should communicate the sanctuary. Secondary systems should support the sanctuary.**

Avoid turning the top of the screen into a row of tiny buttons.

---

# 18. Habitat Progression

Habitat upgrades must affect both numbers and, where practical, visuals.

Examples:

- Capacity increases.
- Welfare bonuses.
- Production efficiency.
- Breeding efficiency.
- Automation slots.
- Enrichment.
- New scenery.
- New environmental objects.

A player should be able to look at a high-level habitat and recognize that it has progressed.

---

# 19. Staff

Staff provide the management layer.

Initial roles:

- Keeper — animal growth/happiness.
- Veterinarian — welfare/efficiency.
- Geneticist — DNA.
- Botanist — food.
- Researcher — research.
- Expedition Leader — expeditions.
- Director — late-game global bonus.

Progression:

```text
Unlock → Hire → Level → Improve Bonus → Unlock Automation
```

Staff effects must come from definitions/configuration, not scattered role-specific widget logic.

---

# 20. Automation

Automation is a major progression reward.

```text
Manual Care
    ↓
Keeper
    ↓
Automated Feeder
    ↓
Automated Water
    ↓
Automated Habitat
    ↓
Smart Sanctuary
```

Automation should reduce repetitive interaction.

Do not make the player perform more chores just because they unlocked automation.

---

# 21. Research Tree

Initial branches:

- Genetics.
- Breeding.
- Nutrition.
- Habitat Engineering.
- Veterinary Science.
- Conservation Biology.
- Automation.
- Expedition Technology.
- Fossil Analysis.
- Climate Control.

Each research node must define:

- prerequisites;
- cost;
- effects;
- unlocks;
- display text.

Research should create meaningful strategic choices rather than simply being a list of mandatory purchases.

---

# 22. Expeditions & Fossils

Expeditions are the second major idle loop.

Players can discover:

- Fossil fragments.
- Bones.
- Teeth.
- DNA fragments.
- Research artifacts.
- Rare specimens.
- Regional discoveries.

Example:

```text
ROCKY MOUNTAINS EXPEDITION
Duration: 2h

Guaranteed:
Fossil Fragment

Possible:
Mammoth Bone
Ancient Tooth
DNA Fragment
Rare Fossil
```

Every expedition must have:

- duration;
- cost;
- region;
- guaranteed reward;
- discovery pool;
- rare reward;
- staff modifiers;
- completion state.

Expeditions must support offline completion.

---

# 23. Missions / Directives

Missions teach the game naturally.

Example progression:

```text
1. Build your first habitat
2. Revive the Dodo
3. Reach population 25
4. Upgrade the habitat
5. Complete research
6. Hire a Keeper
7. Complete an expedition
8. Restore Dodo Island
```

Missions should:

- teach systems;
- reward meaningful progress;
- avoid repetitive chores;
- avoid becoming mandatory daily checklists.

Mission objectives should use generic game-state conditions rather than species-specific code.

---

# 24. World / Region Progression

Long-term map:

```text
Dodo Island
      ↓
Australian Forest
      ↓
Northern Coast
      ↓
African Grasslands
      ↓
Fossil Basin
      ↓
Ice Age Valley
      ↓
Ancient Plains
      ↓
Cretaceous Valley
      ↓
Ancient Ocean
```

Each region can contain:

- multiple habitats;
- multiple species;
- unique resources;
- expeditions;
- research;
- missions;
- restoration milestones.

Do not build the entire world before the first regions are proven fun.

---

# 25. Species Roadmap

## Tier 1 — Recent Extinctions

Initial target species:

- Dodo.
- Thylacine.
- Great Auk.
- Quagga.
- Aurochs.
- Pyrenean Ibex.

## Tier 2 — Ice Age

Examples:

- Woolly Mammoth.
- Woolly Rhinoceros.
- Steppe Bison.
- Cave Lion.
- Cave Bear.
- Irish Elk.

## Tier 3 — Prehistoric

Examples:

- Triceratops.
- Tyrannosaurus rex.
- Sauropods.
- Prehistoric birds.
- Ancient crocodilians.

Scientific facts, extinction dates, habitats, and taxonomy must be validated during content production.

---

# 26. Extinction Archive

The Archive is the collection and knowledge system.

Each species entry should contain:

- Name.
- Scientific name.
- Extinction information.
- Habitat.
- Era.
- Restoration status.
- Population.
- Research progress.
- Discovery progress.
- Artwork.

Locked species should create curiosity without revealing every future reward.

Archive completion should eventually become a long-term collection goal.

---

# 27. Ecosystem Restoration / Prestige

Prestige is called **Restoration**.

Example:

```text
RESTORE DODO ISLAND

Population: 10,284
Restoration Score: ★★★★☆

Reward:
+18 Restoration Points
```

Restoration resets appropriate local progression while preserving permanent global progress.

Permanent bonuses can include:

- Animal growth.
- Research.
- DNA.
- Offline earnings.
- Expedition speed.
- Discovery rate.
- Habitat efficiency.

The reset should feel like rebuilding a stronger ecosystem, not deleting progress.

---

# 28. Rare Variants

Future system only.

Possible variants:

- Standard.
- Rare.
- Golden.
- Ancient.
- Perfect.

Variants must come from gameplay systems such as:

- research;
- discoveries;
- achievements;
- restoration;
- special events.

Do not use paid random gambling mechanics.

---

# 29. Events

Future content layer.

Examples:

- Dodo Migration.
- Fossil Rush.
- Ice Age Week.
- Breeding Festival.
- Ancient Discovery.

Events should be optional, rewarding, and lightweight.

Avoid exhausting daily participation requirements.

---

# 30. Daily Tasks

Future system.

Keep tasks short and optional.

Examples:

- Produce research.
- Upgrade a habitat.
- Complete an expedition.
- Collect offline earnings.

Rewards should supplement progression rather than gate the game.

---

# 31. Art Direction

Target:

- Stylized 3D or lightweight 2.5D.
- Friendly but not childish.
- Strong silhouettes.
- Distinct environments.
- Natural-looking habitats.
- Readable UI.
- Lightweight animation.

The sanctuary should visually communicate that the player is restoring nature.

### Visual progression

The environment should improve as the sanctuary improves.

Low level:

> sparse, developing, protected enclosure

Mid level:

> healthy, richer, active habitat

High level:

> expansive, natural, thriving ecosystem

---

# 32. Audio

Future systems:

- Habitat ambience.
- Animal sounds.
- UI feedback.
- Upgrade sounds.
- Discovery sounds.
- Fossil reveals.
- Level-up sounds.
- Reward collection.
- Restoration soundscape.

Audio should support progression without becoming repetitive.

---

# 33. Technical Architecture

Preferred stack:

- Flutter / Dart.
- Riverpod.
- Drift / SQLite or the existing persistence approach where appropriate.
- Flame only where it materially improves game-world rendering/animation.

Recommended conceptual structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── economy/
│   ├── simulation/
│   ├── time/
│   ├── persistence/
│   └── utilities/
│
├── models/
│   ├── game_state.dart
│   ├── species_definition.dart
│   ├── habitat_definition.dart
│   ├── staff_definition.dart
│   ├── research_definition.dart
│   ├── expedition_definition.dart
│   └── mission_definition.dart
│
├── data/
│   ├── species/
│   ├── habitats/
│   ├── staff/
│   ├── research/
│   ├── expeditions/
│   └── missions/
│
├── providers/
│
├── screens/
│
├── widgets/
│
└── main.dart
```

Do not reorganize files merely for aesthetics. Refactor when the change improves maintainability or enables generalized systems.

---

# 34. State Management

Riverpod should expose game state and actions cleanly.

Widgets should not directly implement game rules.

Preferred pattern:

```text
Widget
  ↓
Provider / Notifier
  ↓
Game Service / Simulation Engine
  ↓
Game State
```

All major gameplay actions should be testable independently of UI.

---

# 35. Testing Strategy

Every major gameplay system requires automated tests.

## Simulation tests

Test:

- Production over time.
- Breeding.
- Welfare modifiers.
- Capacity limits.
- Automation.
- Staff bonuses.
- Research effects.
- Expedition completion.
- Restoration.

## Offline tests

Test:

- Zero elapsed time.
- Normal elapsed time.
- Maximum offline cap.
- Negative elapsed time.
- Huge elapsed time.
- Repeated collection.
- Restart behavior.
- Clock changes.

## Persistence tests

Test:

- Save/load.
- Version migrations.
- Missing fields.
- Corrupt data.
- New content added to an old save.

## UI tests

Test critical actions:

- Revive.
- Feed.
- Water.
- Upgrade.
- Hire staff.
- Research.
- Start expedition.
- Claim expedition.
- Claim mission.
- Restore.

---

# 36. Economy Balancing

Balancing should be data-driven rather than hard-coded throughout widgets.

Track:

- Cost curves.
- Production curves.
- Upgrade multipliers.
- Breeding time.
- Population growth.
- Offline income.
- Restoration rewards.
- Research costs.
- Expedition rewards.

### Desired progression feel

Early game:

- Frequent purchases.
- Fast feedback.
- Rapid unlocks.

Mid game:

- Meaningful choices.
- Longer timers.
- Multiple systems interacting.

Late game:

- Large numbers.
- Strategic optimization.
- Restoration cycles.
- Long-term collection.

Avoid exponential inflation that makes earlier systems instantly irrelevant.

---

# 37. Idle-Game Feel

The game should capture the best qualities of successful idle games:

- Constant visible progress.
- Clear next milestone.
- Short satisfying interactions.
- Strong upgrade feedback.
- Meaningful automation.
- Offline rewards.
- Multiple interacting progression systems.
- Prestige that accelerates future runs.

But it should avoid:

- endless clicking;
- confusing currencies;
- artificial waiting everywhere;
- predatory monetization;
- forced daily chores;
- punishment for inactivity.

---

# 38. Performance

Target smooth operation on mid-range Android hardware.

Priorities:

- Keep rebuilds localized.
- Avoid expensive per-frame Flutter widget work.
- Avoid unnecessary particle effects.
- Use efficient animal rendering.
- Limit simultaneous animated entities where necessary.
- Avoid running high-frequency simulation when the game is backgrounded.
- Use elapsed-time simulation instead.

The sanctuary should look alive without requiring a full game-engine rendering pipeline unless profiling proves it necessary.

---

# 39. Accessibility

Eventually support:

- Scalable text.
- Good contrast.
- Touch targets large enough for mobile.
- Reduced motion option.
- Clear non-color-only status indicators.
- Readable resource formatting.
- Optional sound effects.

The game should remain playable without relying entirely on animation or color.

---

# 40. Content Pipeline

Species and habitat content should be easy to add.

Preferred workflow:

```text
Research / Validate Facts
        ↓
Species Definition
        ↓
Habitat Definition
        ↓
Art / Audio References
        ↓
Unlock Requirements
        ↓
Balance Values
        ↓
Automated Tests
        ↓
Archive Entry
        ↓
Playable Species
```

A new species should not require modifying multiple unrelated gameplay systems.

---

# 41. Development Phases

## Phase 1 — Foundation

**Status: Largely complete**

- Flutter project.
- Core state.
- Riverpod.
- Basic persistence.
- Basic simulation.
- Initial UI.

### Exit criteria

The game launches, saves, loads, and runs a basic idle loop.

---

## Phase 2 — Dodo Core Loop

**Status: Implemented; needs validation/polish**

- Dodo revival.
- Population.
- Food.
- Water.
- Welfare.
- Breeding.
- DNA.
- Research.
- Habitat upgrades.

### Exit criteria

The Dodo loop can run indefinitely without breaking or requiring manual resets.

---

## Phase 3 — Offline & Persistence

**Status: Implemented; requires deeper QA**

- Offline report.
- Offline simulation.
- Save/load.
- Time validation.
- Persistence recovery.

### Exit criteria

Closing and reopening the game produces deterministic, correct progress.

---

## Phase 4 — Generalized Engine

**Status: In progress**

- Remove species-specific simulation logic.
- Generalize definitions.
- Generic habitat logic.
- Generic production.
- Generic breeding.
- Generic welfare.

### Exit criteria

A second species can be added primarily through data/content.

---

## Phase 5 — Sanctuary Visual Upgrade

**Status: NEXT MAJOR PRIORITY**

- Replace placeholder viewport.
- Add terrain.
- Add vegetation.
- Add water.
- Add habitat objects.
- Add visible Dodos.
- Add lightweight movement.
- Add visual habitat progression.
- Add care interaction feedback.

### Exit criteria

The sanctuary is visually recognizable as a living Dodo habitat and feels like the game's centerpiece.

---

## Phase 6 — Dodo Island Vertical Slice

**Status: Partially implemented**

Complete:

- Core loop.
- Staff.
- Research.
- Upgrades.
- Expeditions.
- Missions.
- Archive.
- Restoration.
- Offline progress.
- Save/load.
- Sanctuary visuals.

### Exit criteria

Dodo Island is fun without needing future regions to carry the experience.

---

## Phase 7 — Exploration

**Status: Implemented; needs balancing/polish**

- Expedition system.
- Fossils.
- Discoveries.
- Expedition staff.
- Expedition rewards.
- Offline completion.

---

## Phase 8 — Multi-Species

**Status: Foundation exists; content expansion pending**

Add:

- Thylacine.
- Great Auk.
- Quagga.
- Aurochs.
- Pyrenean Ibex.

Each must use the generalized engine.

### Exit criteria

No copy/paste Dodo-specific game logic exists for the new species.

---

## Phase 9 — World Expansion

Add:

- Australian Forest.
- Northern Coast.
- African Grasslands.
- Fossil Basin.

Each region receives unique habitat characteristics and discovery pools.

---

## Phase 10 — Restoration / Prestige Depth

Expand:

- Restoration tiers.
- Permanent perks.
- Region mastery.
- Restoration milestones.
- Long-term bonuses.

### Exit criteria

Resetting a region is desirable because the permanent rewards are meaningful and the rebuilt run is faster/better.

---

## Phase 11 — Ice Age

Add:

- Ice Age Valley.
- Woolly Mammoth.
- Woolly Rhinoceros.
- Steppe Bison.
- Cave Lion.
- Cave Bear.
- Irish Elk.

Introduce climate-specific mechanics only where they improve gameplay.

---

## Phase 12 — Prehistoric Era

Add:

- Ancient Plains.
- Cretaceous Valley.
- Prehistoric species.
- Ancient ecosystems.

Do not allow prehistoric content to overwhelm the original conservation identity.

---

## Phase 13 — Long-Term Systems

Future:

- Rare variants.
- Achievements.
- Events.
- Optional daily tasks.
- Collection completion.
- Advanced restoration.
- Additional expedition regions.

---

## Phase 14 — Release Polish

Final pass:

- UI polish.
- Art polish.
- Audio.
- Performance.
- Accessibility.
- Save migration QA.
- Offline QA.
- Device testing.
- Crash/error handling.
- Tutorial.
- First-session experience.
- Store assets.
- Release build.

---

# 42. Current Immediate Sprint

The next implementation sprint should focus narrowly on the following:

### A. Sanctuary viewport

- Remove the large empty/gray placeholder appearance.
- Create a Dodo Island visual scene.
- Add Dodo entities.
- Add terrain/environment objects.
- Add basic animation.
- Make habitat level visibly affect the scene.

### B. Home-screen simplification

Keep the sanctuary screen focused.

Preferred persistent information:

- Resources.
- Sanctuary title/status.
- Living habitat.
- Population/welfare.
- Core needs.
- Bottom navigation.

Avoid filling the top of the screen with too many small secondary-system buttons.

### C. Economy verification

Verify:

- Credits/sec.
- DNA/sec.
- Research/sec.
- Population growth.
- Breeding timing.
- Welfare bonuses.
- Upgrade costs.
- Offline rewards.

The screenshot's values should be treated as a balance-testing state, not hard-coded final numbers.

### D. Offline/persistence QA

Perform automated and manual tests for:

- 1 minute.
- 10 minutes.
- 1 hour.
- Maximum offline cap.
- App kill/restart.
- Repeated launch.
- Invalid clock movement.
- Save migration.

### E. Generalization audit

Search for and remove remaining concepts such as:

- `dodo_island` used as gameplay logic.
- `reviveDodo`.
- `petDodos`.
- Other species-specific actions that should be generic.

Species-specific content is acceptable. Species-specific engine logic is not unless the species genuinely has a unique mechanic.

---

# 43. Definition of Done

A feature is **DONE** only when:

- It works in the UI.
- It works in the underlying state model.
- It works after save/load.
- It behaves correctly after offline time where applicable.
- It has automated tests for important rules.
- It does not introduce species-specific duplication.
- It has readable UI feedback.
- It does not create unnecessary tapping.
- It does not break existing progression.

A feature that merely renders a button is not complete.

---

# 44. Release Quality Bar

Before calling the game release-ready:

### Gameplay

- Core loop is fun.
- Progression is understandable.
- Economy is stable.
- Offline progression is reliable.
- Restoration feels rewarding.

### UX

- New player understands the sanctuary quickly.
- Important actions require few taps.
- No major navigation confusion.
- Resource rates are obvious.
- Upgrade impact is understandable.

### Visuals

- Sanctuary is alive.
- Animals are recognizable.
- Habitat progression is visible.
- UI is consistent.
- No placeholder graphics remain in core gameplay.

### Technical

- No known critical crashes.
- Saves are reliable.
- Migrations are tested.
- Offline calculations are deterministic.
- Performance is acceptable on target Android hardware.

---

# 45. Non-Goals

Do not prioritize these before the core game is proven:

- Multiplayer.
- Online trading.
- Complex social systems.
- Competitive PvP.
- Premium currency.
- Loot boxes.
- Excessive cosmetics.
- Massive open-world rendering.
- Complex physics.
- Dozens of simultaneous currencies.

The game succeeds by making **one sanctuary feel great**, then expanding that proven formula.

---

# 46. Final Product Identity

Extinction Sanctuary should feel like:

> **An addictive idle management game where every number represents a living ecosystem getting healthier.**

The player should open the game and immediately see:

- animals moving;
- habitat improving;
- population growing;
- resources accumulating;
- research advancing;
- expeditions discovering the past;
- restoration getting closer.

The ultimate goal is not simply to make bigger numbers.

It is to make the player feel that they are **bringing a lost world back to life.**
