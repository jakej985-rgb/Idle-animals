# Extinction Sanctuary — Updated Game Development Plan

**Project:** Idle Animals  
**Working Title:** Extinction Sanctuary  
**Document:** Authoritative Product & Development Plan  
**Status:** Active Development Blueprint  
**Last Updated:** 2026-09-15  

---

## 1. Vision

Build a polished mobile-first idle management game inspired by the satisfying progression of **Egg, Inc., Gold & Goblins, and Lumber Inc.**, but with a distinct conservation/restoration identity.

The player builds a sanctuary network that revives extinct species, raises healthy populations, restores habitats, researches ancient genetics, sends expeditions for discoveries, and eventually restores entire ecosystems.

**Core fantasy:**

> Bring extinct animals back, build a living sanctuary, restore lost ecosystems, and progress from recent extinctions to the prehistoric world.

Animals are never treated as products to sell. The economy is driven by healthy populations, research, discoveries, habitat development, and restoration.

---

# 2. Current Repository Direction

The existing project already contains a useful idle-game foundation including simulation, offline progress, persistence, game state, species, habitats, staff, research, upgrades, and Riverpod state management.

The immediate architectural goal is **not a rewrite**. Evolve the current prototype into a reusable, data-driven game engine.

### Current prototype problem to eliminate

The first playable area is heavily Dodo-specific. Logic such as `dodo_island`, `reviveDodo()`, and `petDodos()` must become generalized systems.

### Target

Adding a new species should primarily require **data/content**, not new gameplay code.

For example:

```text
SpeciesDefinition
    ↓
HabitatDefinition
    ↓
Simulation Rules
    ↓
Generic UI
    ↓
Dodo / Thylacine / Quagga / Mammoth / etc.
```

No species-specific gameplay logic unless a future species genuinely has a unique mechanic.

---

# 3. Development Priorities

Work in this order:

1. Stabilize the existing prototype.
2. Generalize the simulation engine.
3. Make all species/habitats data-driven.
4. Build the complete Dodo Island vertical slice.
5. Validate the idle economy and offline progression.
6. Add generalized staff, research, expeditions, and missions.
7. Add multiple species and regions.
8. Add restoration/prestige.
9. Add visual polish, audio, events, and long-term content.

**Do not build every planned feature at once.** Each phase must produce a playable improvement.

---

# 4. Core Gameplay Loop

```text
Discover / Recover DNA
        ↓
Revive Species
        ↓
Build / Upgrade Habitat
        ↓
Raise Population
        ↓
Provide Food + Water + Enrichment
        ↓
Healthy Population Produces Research + DNA
        ↓
Upgrade Habitat / Staff / Research
        ↓
Unlock Discoveries
        ↓
Send Expeditions
        ↓
Unlock New Species / Regions
        ↓
Restore Ecosystem
        ↓
Earn Permanent Restoration Bonuses
        ↓
Repeat at a larger scale
```

The loop must work both:

- actively while the player is present
- passively while the player is away

---

# 5. MVP Definition

The MVP is **Dodo Island as a complete vertical slice**, not the entire game.

A player must be able to:

- Start a sanctuary.
- Unlock/revive the Dodo.
- Build and upgrade its habitat.
- Maintain food and water.
- Grow a population.
- Generate DNA and research.
- Upgrade the habitat.
- Hire at least basic staff.
- Complete research.
- Leave the game.
- Return and receive deterministic offline progress.
- Complete a simple mission chain.
- Reach a meaningful island restoration milestone.
- Save and load without losing progress.

If this loop is fun and economically stable, expand it.

---

# 6. Economy

Keep the economy small and understandable.

## 6.1 Sanctuary Credits

Primary construction/upgrade currency.

Used for:

- Habitats
- Infrastructure
- Staff
- Food systems
- Water systems
- Automation

## 6.2 DNA

Genetic progression currency.

Used for:

- Species revival
- Genetic research
- Breeding improvements
- Advanced discoveries

## 6.3 Research

Technology progression currency.

Used for:

- Research tree
- Automation
- Habitat efficiency
- Expedition technology

## 6.4 Restoration Points

Permanent progression currency earned by restoring ecosystems.

Used for global bonuses.

## 6.5 Premium Currency

**Not part of MVP.** Do not allow monetization concerns to complicate the core economy during early development.

---

# 7. Data-Driven Game Model

All gameplay definitions should be externalized from UI and simulation logic.

### SpeciesDefinition

Minimum fields:

- id
- name
- scientificName
- category
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
- rarity/variant data
- art references
- audio references

### HabitatDefinition

Minimum fields:

- id
- name
- regionId
- habitatType
- baseCapacity
- foodCapacity
- waterCapacity
- climate
- enrichment
- upgradeDefinitions
- visualLevelReferences

### StaffDefinition

- id
- role
- baseBonus
- secondaryBonus
- upgradeCurve
- unlockRequirements

### ResearchDefinition

- id
- branch
- prerequisites
- cost
- effects
- unlocks

### ExpeditionDefinition

- id
- region
- duration
- cost
- guaranteedRewards
- discoveryPool
- rareRewards
- staffModifiers

---

# 8. Simulation Engine

The simulation engine is the most important technical system.

It must be:

- deterministic
- testable without Flutter UI
- independent from widgets
- safe across app restarts
- capable of active and offline simulation

Use elapsed time rather than frame counting for idle calculations.

Conceptually:

```text
GameState + elapsedTime
        ↓
SimulationEngine
        ↓
Production / breeding / research / expeditions
        ↓
New GameState
```

The UI should display state, not own the game rules.

---

# 9. Offline Progress

Offline progress must use the same rules as active simulation wherever practical.

On launch:

```text
Last Save Time
      ↓
Current Time
      ↓
Elapsed Duration
      ↓
Offline Simulation
      ↓
Welcome Back Summary
```

Initial cap:

- 2 hours base
- 4 hours upgrade
- 8 hours upgrade
- 12 hours upgrade
- 24 hours maximum early-game target

Offline simulation must prevent exploits caused by negative time, clock changes, overflow, or repeated collection.

---

# 10. Save System

Persistence must be reliable before major content expansion.

Requirements:

- Versioned save format.
- Migration support.
- Atomic writes where possible.
- Safe recovery from corrupted data.
- No factory data overwritten by player state.
- User progress remains local/offline-first.

The player must never lose meaningful progress because a new app version changed a model.

---

# 11. Animal Welfare

Animal welfare should modify production/growth rather than create harsh failure loops.

Track:

- Food
- Water
- Happiness
- Habitat suitability
- Enrichment
- Population capacity
- Breeding availability

Example:

```text
Food        96%
Water       91%
Happiness   94%
Habitat    100%

Population Growth  +18%
DNA Production     +12%
Research           +10%
```

Early gameplay should not kill animals because the player missed a collection window.

---

# 12. Breeding

Breeding is timer-based and predictable.

Example:

```text
Dodo
Breeding: 00:18
Offspring: 1
Population: 24 / 50
```

Research/staff can improve:

- Breeding speed
- Offspring count
- Population capacity
- Genetic quality
- DNA output

Do not turn breeding into paid gambling or loot-box mechanics.

---

# 13. Production

Animals generate progression resources through healthy sanctuary activity.

Core relationships:

```text
Healthy Animals → Research
Healthy Animals → DNA
Fossils → DNA / Discovery
Discoveries → Research
Habitat Quality → Production Efficiency
Staff → Efficiency
Research → Permanent/long-term improvements
```

Avoid a conventional factory chain where animals are consumed or sold.

---

# 14. Habitat Progression

Habitats should have visible progression.

### Level 1

Small enclosure, simple terrain, basic food/water.

### Mid Level

More terrain, enrichment, staff facilities, better infrastructure.

### High Level

Large natural-looking environment, larger visible population, advanced automation, environmental detail.

Upgrading should change both numbers **and the visual state** where practical.

---

# 15. Staff

Staff provide the management layer.

Initial roles:

- Keeper — animal growth/happiness
- Veterinarian — welfare/efficiency
- Geneticist — DNA
- Botanist — food
- Researcher — research
- Expedition Leader — expeditions
- Director — late-game global bonus

Staff progression:

```text
Unlock → Hire → Level → Improve Bonus → Unlock Automation
```

Staff must use generic definitions rather than hard-coded role logic scattered through widgets.

---

# 16. Automation

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

Automation should remove repetitive tapping, not simply add another currency.

---

# 17. Research Tree

Initial branches:

- Genetics
- Breeding
- Nutrition
- Habitat Engineering
- Veterinary Science
- Conservation Biology
- Automation
- Expedition Technology
- Fossil Analysis
- Climate Control

Research nodes must be data-driven and have explicit prerequisites/effects.

---

# 18. Fossils & Expeditions

Expeditions provide the second major idle loop.

Players discover:

- Bones
- Teeth
- Fossil fragments
- DNA fragments
- Rare specimens
- Research artifacts

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

Expeditions need:

- duration
- region
- cost
- guaranteed reward
- discovery pool
- rare reward
- staff modifiers
- completion state

---

# 19. Missions

Missions teach progression naturally.

Example:

```text
1. Build your first habitat
2. Revive the Dodo
3. Reach population 25
4. Upgrade habitat 3 times
5. Complete first research node
6. Hire a Keeper
7. Complete first expedition
8. Restore Dodo Island
```

Missions should never become mandatory repetitive chores.

---

# 20. Species Roadmap

Content should expand by progression tier.

### Tier 1 — Recent Extinctions

Initial examples:

- Dodo
- Thylacine
- Great Auk
- Quagga
- Aurochs
- Pyrenean Ibex

### Tier 2 — Ice Age

Examples:

- Woolly Mammoth
- Woolly Rhinoceros
- Steppe Bison
- Cave Lion
- Cave Bear
- Irish Elk

### Tier 3 — Prehistoric

Examples:

- Triceratops
- Tyrannosaurus rex
- Sauropods
- Prehistoric birds
- Ancient crocodilians

Scientific facts, extinction dates, habitats, and species claims must be validated during content production.

---

# 21. World / Region Progression

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

- multiple habitats
- multiple species
- unique resources
- expeditions
- research
- restoration milestones

Do not build the entire map before the first region is proven fun.

---

# 22. Extinction Archive

Create a collection system that makes every species feel meaningful.

Each entry should contain:

- Name
- Scientific name
- Extinction information
- Habitat
- Restoration status
- Population
- Research progress
- Discovery progress
- Art

Locked species should show enough information to create curiosity without revealing everything.

---

# 23. Ecosystem Restoration / Prestige

Prestige is called **Restoration**.

Example:

```text
RESTORE DODO ISLAND

Population: 10,284
Restoration Score: ★★★★☆

Reward:
+18 Restoration Points
```

Restoring a region resets appropriate local progression while preserving permanent global progress.

Permanent bonuses can include:

- Animal growth
- Research
- DNA
- Offline earnings
- Expedition speed
- Discovery rates
- Habitat efficiency

The reset must feel like rebuilding a stronger ecosystem, not deleting progress.

---

# 24. Rare Variants

Future system only.

Possible variants:

- Standard
- Rare
- Golden
- Ancient
- Perfect

Variants should come from gameplay, discoveries, achievements, research, or restoration—not paid random gambling.

---

# 25. Events

Future content layer.

Examples:

- Dodo Migration
- Fossil Rush
- Ice Age Week
- Breeding Festival
- Ancient Discovery

Events should be optional and rewarding, not exhausting daily chores.

---

# 26. Daily Tasks

Future system.

Keep them short and optional.

Examples:

- Produce research
- Upgrade habitats
- Complete an expedition
- Collect offline earnings

Rewards should supplement progression rather than gate the game.

---

# 27. Main Screen UX

The sanctuary itself is the home screen.

```text
┌───────────────────────────────┐
│ Credits      DNA      Research│
├───────────────────────────────┤
│                               │
│          SANCTUARY            │
│                               │
│      🦤     🦤      🦤        │
│             💧                │
│       🌱          🏡          │
│                               │
│ Population  24 / 50           │
│ DNA         +12/min            │
│                               │
├───────────────────────────────┤
│ 🏡  🐾  🧬  🦴  🗺️  ⚙️       │
└───────────────────────────────┘
```

Primary navigation should expose:

- Sanctuary
- Animals
- Research
- Expeditions
- World/Map
- Settings

Important actions should be reachable with minimal taps.

---

# 28. UX Principles

- Mobile-first.
- Fast.
- Minimal taps.
- Large readable numbers.
- Clear resource feedback.
- Progress always visible.
- Avoid unnecessary confirmation dialogs.
- Avoid excessive animation.
- Avoid menu depth.
- Main screen should feel alive.
- Never make the player repeatedly perform a task that automation has already unlocked.

---

# 29. Art Direction

Target:

- Stylized 3D or lightweight 2.5D.
- Friendly but not overly childish.
- Strong silhouettes.
- Distinct environments.
- Readable UI.
- Lightweight animation.

Animals should visibly:

- walk
- eat
- drink
- rest
- interact
- breed
- move through the habitat

The visual quality should increase gradually; gameplay correctness comes first.

---

# 30. Audio

Future systems:

- Habitat ambience
- Animal sounds
- UI feedback
- Upgrade sounds
- Discovery sounds
- Fossil reveals
- Level-up sounds
- Reward collection

Audio should support progression without becoming repetitive.

---

# 31. Technical Architecture

Preferred stack:

- Flutter / Dart
- Riverpod
- Drift / SQLite or the existing persistence approach where appropriate
- Flame only where it materially improves game-world rendering/animation

Recommended conceptual structure:

```text
lib/
├── core/
│   ├── economy/
│   ├── time/
│   ├── simulation/
│   ├── persistence/
│   ├── definitions/
│   └── utilities/
│
├── data/
│   ├── species/
│   ├── habitats/
│   ├── research/
│   ├── staff/
│   ├── expeditions/
│   └── missions/
│
├── features/
│   ├── sanctuary/
│   ├── animals/
│   ├── research/
│   ├── expeditions/
│   ├── map/
│   ├── restoration/
│   └── settings/
│
└── app/
```

The exact folders can evolve; the key rule is separation between **definitions, simulation, persistence, state, and presentation**.

---

# 32. Testing Strategy

The idle engine must be testable without rendering the application.

Required tests:

### Economy

- Production rates
- Upgrade costs
- Scaling
- Currency conservation

### Time

- Active elapsed time
- Offline elapsed time
- Maximum offline cap
- Negative/invalid elapsed time
- Clock manipulation protection

### Breeding

- Timers
- Capacity
- Offspring
- Production modifiers

### Research

- Prerequisites
- Costs
- Effects
- Unlocks

### Expeditions

- Start
- Completion
- Rewards
- Duration
- Staff modifiers

### Save/Load

- Round-trip serialization
- Version migrations
- Corruption recovery

### Regression

Every generalized system must preserve the existing Dodo gameplay behavior unless the change intentionally modifies balance.

---

# 33. Balancing Rules

The game should use formulas rather than hundreds of hard-coded values.

Typical idle scaling should be predictable:

```text
Cost(n) = BaseCost × GrowthRate^n

Production = BaseProduction
           × HabitatMultiplier
           × WelfareMultiplier
           × StaffMultiplier
           × ResearchMultiplier
           × RestorationMultiplier
```

Balance goals:

- Frequent early upgrades.
- Increasing but understandable upgrade costs.
- Meaningful choices.
- No single upgrade invalidates every other system.
- Offline progress should feel valuable but not replace active play.

Balance should be measured with simulation tests rather than guessed solely from UI play.

---

# 34. Anti-Exploit / Reliability Requirements

Protect against:

- Negative elapsed time.
- Impossible timestamps.
- Duplicate reward collection.
- Repeated expedition completion.
- Integer/float overflow.
- Save corruption.
- Reset exploits.
- Unlocking content without requirements.

The simulation should clamp or reject invalid states safely.

---

# 35. Development Phases

## Phase 0 — Baseline Audit

- Run tests.
- Run the application.
- Identify current architecture.
- Identify Dodo-specific logic.
- Record current functionality.
- Do not remove working systems without a reason.

**Exit:** documented baseline and passing test suite.

## Phase 1 — Generalize Core Models

- Generalize Species.
- Generalize Habitat.
- Generalize production.
- Generalize breeding.
- Generalize unlocks.
- Remove Dodo-only assumptions from core systems.

**Exit:** a second dummy species can be added without new simulation code.

## Phase 2 — Harden Simulation + Persistence

- Deterministic simulation.
- Offline calculations.
- Save versioning.
- Migration path.
- Error handling.
- Regression tests.

**Exit:** closing/reopening cannot corrupt or duplicate progression.

## Phase 3 — Complete Dodo Island Vertical Slice

- Habitat progression.
- Welfare.
- Breeding.
- DNA.
- Research.
- Staff.
- Missions.
- Offline welcome-back.
- Restoration milestone.

**Exit:** Dodo Island is a complete fun idle loop.

## Phase 4 — First Expansion Species

Add a small set of species, for example:

- Thylacine
- Quagga
- Great Auk

No new hard-coded gameplay systems should be necessary.

**Exit:** multiple species coexist using the same engine.

## Phase 5 — Expeditions + Discovery

- World regions.
- Expedition timers.
- Fossils.
- Discovery pools.
- Unlock requirements.
- Expedition Leader.

**Exit:** exploration becomes a second meaningful idle loop.

## Phase 6 — Research + Automation Expansion

- Full research branches.
- Automation progression.
- Staff upgrades.
- Habitat specialization.

**Exit:** active play becomes less repetitive as the sanctuary matures.

## Phase 7 — World Map + Restoration

- Multiple regions.
- Region progression.
- Restoration milestones.
- Permanent global bonuses.

**Exit:** the player has a complete long-term progression loop.

## Phase 8 — Collection + Content

- Extinction Archive.
- More species.
- More habitats.
- Scientific information.
- Art assets.

**Exit:** collection becomes a major retention system.

## Phase 9 — Polish

- Visual improvements.
- Animations.
- Sound.
- Feedback.
- Performance.
- Accessibility.

**Exit:** game feels like a polished product rather than a prototype.

## Phase 10 — Optional Live Content

Only after the core game is stable:

- Events.
- Daily tasks.
- Rare variants.
- Optional monetization.

---

# 36. Definition of Done

A feature is not complete merely because its screen exists.

A feature is complete when:

- The underlying state exists.
- Simulation logic works.
- Persistence works.
- Offline behavior works where applicable.
- UI reflects the actual state.
- Invalid states are handled.
- Tests cover important behavior.
- It works after app restart.
- It does not depend on hard-coded Dodo assumptions.

---

# 37. Immediate Next Work

After this plan is committed, perform another repository audit against it.

### Specifically inspect:

1. Dodo-specific code paths.
2. Current Species model.
3. Current Habitat model.
4. SimulationEngine.
5. OfflineManager.
6. SaveService.
7. GameState.
8. Staff implementation.
9. Research implementation.
10. Upgrade implementation.
11. Navigation/UI architecture.
12. Tests and coverage.
13. Data files/assets.
14. Any duplicated state or business logic.
15. Any systems already implemented that can be retained.

Then produce a **Plan Compliance Report**:

```text
PLAN COMPLIANCE

🟢 Complete
🟡 Partial
🔴 Missing

Architecture:       __%
Simulation:         __%
Persistence:        __%
Offline Progress:   __%
Animal System:      __%
Habitat System:     __%
Staff:              __%
Research:           __%
Expeditions:        __%
Missions:           __%
UX:                 __%
Content:             __%
Testing:            __%

Overall MVP Readiness: __%
```

For every 🟡 or 🔴 item, identify the exact files/classes that need work and the smallest logical implementation step.

---

# 38. Guiding Rule

**Build the engine before the content.**

If adding the next extinct animal requires writing a new gameplay class, the architecture is not finished.

If adding the next extinct animal requires adding a data definition, art, balance values, and scientific metadata, the architecture is working.

The goal is not to make one excellent Dodo game.

The goal is to build the reusable system that can support an entire **Extinction Sanctuary**.
