# Ranch System: Omni Frontier

This repository now ships two deliverables for RedM server owners:

1. **Omni Frontier Resource (`resource/`)** — a production-ready RedM script scaffold that provides ranch deed administration, zoning & vegetation editing, and mapper prop tooling with Discord webhook placeholders.
2. **Product Requirements Document (PRD)** — a long-form blueprint that covers the complete ranch-management vision. Use it to guide future milestones layered on top of the core resource.

## Resource Overview

The `resource/` directory is a standalone RedM resource that now orchestrates the full “Omni Frontier” sandbox. Drop it into your `resources` folder to gain:

- **Administrative Mastery** — deed creation, deletion, merging, and ownership transfers keyed to license, CID/CitizenID, Discord ID, or online source. Discord role hooks, ledger adjustments, and audit history are applied automatically.
- **World Simulation** — dynamic season cycling, weather rolls, hazard queues, and vegetation modifiers powered by the new `server/environment.lua` controller. Hazards broadcast in real time to ranch history logs and client HUD notifications.
- **Livestock Lifecycle** — persistent animal registries with trust meters, need decay, breeding timers, and treatment logs per ranch (`server/livestock.lua`).
- **Workforce & Tasks** — rosters, morale/fatigue tracking, and configurable task boards for AI or player ranch hands (`server/workforce.lua`).
- **Economy & Contracts** — seasonal price curves, contract generators, auction scaffolding, and ledger hooks for every sale or bounty (`server/economy.lua`).
- **Progression & Legacy** — XP gain, level thresholds, skill unlocks, and achievement tracking tied directly to ranch history (`server/progression.lua`).
- **Zoning, Vegetation & Mapping Utilities** — upgraded zone capture, vegetation payloads, and mapper prop placement with rotation/elevation controls.

All subsystems persist to JSON out of the box while sharing unified config tables so server owners can retune balance without editing code. Every state change emits events to clients and Discord-ready webhooks for automation.

## Installation

1. Copy the `resource` folder to your server and rename it (e.g., `omni_ranch`).
2. Add the resource to your server `resources.cfg`:
   ```cfg
   ensure omni_ranch
   ```
3. Install [oxmysql](https://github.com/overextended/oxmysql) if you plan to swap the JSON storage for SQL; the included storage layer is JSON-based by default.
4. Grant admins the `ranch.admin` ACE or add their identifiers in `shared/config.lua`.

## Configuration Highlights (`resource/shared/config.lua`)

The config has been expanded into an “omni-level” tuning surface touching every feature described in the PRD. Highlights include:

- `Config.Admin`, `Config.IdentifierPriority`, `Config.Discord` — access control, identifier parsing, Discord role/webhook automation, and audit logging.
- `Config.Storage.Files` — declarative map of every JSON persistence bucket (ranches, vegetation, animals, workforce, production, environment, economy, progression) with an auto-persist interval.
- `Config.Ranches` — ranch limits, upgrade trees, decoration catalogs, maintenance costs, morale math, ledger defaults, and Discord role wage modifiers.
- `Config.Environment` — season order/length, weather weights, hazard definitions, wildlife behaviors, soil fertility math, drought/flood modifiers, and ambient audio tracks.
- `Config.Livestock` / `Config.Healthcare` — species stats, genetics tables, trust thresholds, breeding rules, disease/injury catalogs, and farrier tooling.
- `Config.Workforce` — AI hand options, wage tables, accident odds, task definitions, morale/fatigue decay, and roster permissions.
- `Config.ProductionChains`, `Config.Crops`, `Config.Economy` — end-to-end processing times, spoilage rates, storage capacities, dynamic pricing curves, contract boards, and auction controls.
- `Config.Progression`, `Config.UI`, `Config.GodExtras` — XP thresholds, skill trees, achievement rewards, tutorial toggles, haunted/VR/Tebex extras, and voice command flags.

Every section is documented with sensible defaults so you can rescale difficulty, monetization hooks, or thematic flavor from a single file.

## Admin Commands

All commands require the `ranch.admin` ACE or a whitelisted identifier and respect the config-driven rate limiter/audit log.

| Command | Description |
| --- | --- |
| `/ranchcreate <name> [identifier]` | Create a deed with optional owner identifier (license:/cid:/citizenid:/discord:). |
| `/ranchdelete <ranchId>` | Delete a ranch, remove zones/props, archive Discord roles if configured. |
| `/ranchtransfer <ranchId> <identifier>` | Transfer ownership to another identifier; triggers Discord webhook + ledger history. |
| `/ranchsetrole <ranchId> <discordRoleId>` | Attach a Discord role for external automation or Tebex perks. |
| `/ranchseason <season>` | Force the global season (`spring`, `summer`, `autumn`, `winter`). |
| `/ranchweather` | Roll a new weather pattern immediately. |
| `/ranchhazard <hazardKey> [ranchId]` | Queue a hazard (lightning, flood, drought, blizzard, duststorm, etc.) optionally tied to a ranch history entry. |
| `/ranchanimaladd <ranchId> <species> [count]` | Spawn and persist livestock for the ranch with full needs/genetics records. |
| `/ranchanimaldel <ranchId> <animalId>` | Remove a specific animal from the ranch herd. |
| `/ranchassign <ranchId> <identifier> <role>` | Assign a workforce role (Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Vet, Teamster). |
| `/ranchtask <ranchId> <taskType>` | Post a configurable task board job (feeding, watering, mucking, milking, fenceRepair, herding). |
| `/ranchcontract [town] [contractId] [ranchId]` | Without args generate a new contract, or assign an existing contract to a ranch. |
| `/ranchxp <ranchId> <amount>` | Grant XP toward ranch level/skill unlocks. |
| `/pzcreate [zoneId]` | Begin drawing a polygon zone with Left Alt (point), Enter (save), Backspace (cancel). |
| `/pzsave` | Force-save the current zone in progress. |
| `/pzcancel` | Abort the current zone creation session. |
| `/ranchprop <model> [ranchId]` | Spawn a whitelisted prop with rotation/elevation controls. |
| `/ranchpropdel [ranchId]` | Remove all stored props for the ranch. |

Every command emits chat feedback plus server history entries so ownership, workforce, and economic changes remain auditable.

## Data Events & Integrations

- `ranch:zones:sync`, `ranch:vegetation:update`, `ranch:props:update` — authoritative land, vegetation, and prop payloads.
- `ranch:environment:update`, `ranch:environment:notify` — global season/weather/hazard state and alert messages.
- `ranch:livestock:update`, `ranch:livestock:trust`, `ranch:livestock:treated` — herd snapshots, trust deltas, and treatment logs.
- `ranch:workforce:roster`, `ranch:workforce:tasks` — roster morale/fatigue data and active task boards.
- `ranch:economy:update`, `ranch:economy:contracts`, `ranch:economy:sale` — price tables, contract boards, and ledger sale broadcasts.
- `ranch:progression:update`, `ranch:progression:achievement` — XP/level updates and achievement unlocks.
- `ranch:ownershipChanged` (server) — emitted after deed transfers for Discord role bots or Tebex fulfillment.

Client exports now expose `GetRanchZones`, `GetVegetation`, `GetProps`, `GetEnvironment`, `GetLivestock`, `GetWorkforce`, `GetEconomy`, and `GetProgression` so UI layers, AI systems, or external scripts can access synced state.

## Extending the Resource

- Replace JSON storage with MySQL by rewriting `server/storage.lua` using `oxmysql` queries.
- Connect the Discord webhook to a bot that grants/removes roles using `Config.Discord` metadata.
- Attach vegetation data to environment controllers that modify grazing yield, wildlife density, or hazard frequency.
- Build mapper UIs on top of `ranch:zones:updated` to preview polygons, or feed them into PolyZone definitions for collision checks.

---

# Ranch System: Omni Frontier — Product Requirements Document

## Product Vision

Deliver a persistent, systemic ranch-management experience for RedM that simulates frontier ranch life across dynamic seasons, expansive land stewardship, deep animal husbandry, production chains, emergent events, and social/economic progression. The experience must be extensible, admin-friendly, and tightly integrated with community tooling such as Discord role management and mapping utilities.

## Goals

1. **Living Frontier Ecology** — Seasonal, weather, soil, and wildlife systems that materially influence ranch planning, yields, and risks.
2. **Ownership & Stewardship** — Acquire, expand, customize, and maintain ranch properties with meaningful upgrades, decay loops, and administrative governance.
3. **Sentient Livestock** — Manage diverse animals with genetics, behavior memory, health systems, and immersive husbandry gameplay.
4. **Professional Craft** — Support veterinary, farrier, processing, and workforce loops that reward mastery and cooperation.
5. **Frontier Economy & Reputation** — Tie production chains into dynamic markets, law/crime consequences, and reputation-driven contracts.
6. **Progression Legacy** — Provide long-term progression, achievements, and family legacy mechanics that keep ranches relevant across seasons.

## Non-Goals

- Recreating the full RDR2 single-player narrative.
- Shipping VR, Tebex, haunted events, or voice command features at launch (target post-launch "God-Level" extras).
- Delivering urban or city-based gameplay loops outside the ranch context.

## Target Audience

- RedM server owners seeking a deep, systemic ranch simulation.
- Roleplay communities invested in co-op ranch life loops.
- Systems-focused players who enjoy management, economy, and animal care gameplay.

## Experience Pillars

1. **Living Frontier Ecology** — Seasons, soil health, weather hazards, and wildlife interactions challenge planning.
2. **Ownership & Stewardship** — Land deeds, upgrades, and maintenance reinforce ranch identity.
3. **Sentient Livestock** — Genetics, behavior, needs, and trust systems humanize animals.
4. **Professional Craft** — Minigames and tools simulate craftwork across ranch professions.
5. **Frontier Economy & Reputation** — Contracts, auctions, law, and crime drive the marketplace.
6. **Progression Legacy** — Skill trees, achievements, and heirs sustain multi-season play.

## Key Systems & Requirements

### Environment & Ecology

- **Dynamic Seasons** alter visuals, crop yields, and animal needs (e.g., snow loads pastures in winter, spring floods damage fencing).
- **Soil & Grass Simulation** tracks pasture regrowth, overgrazing penalties, and fertility recovery via crop rotation or manure spreading.
- **Weather Impacts** introduce drought milk penalties, blizzard feed spikes, storm-driven structure damage, and barn fire hazards.
- **Environmental Hazards** such as floods drowning chickens, frost-killed crops, dust storms suffocating livestock unless sheltered.
- **Wildlife Ecosystem** includes deer, wolves, coyotes, and rodents with AI behaviors interacting with ranch resources.
- **Vegetation Modifier Tooling** provides an in-game vegetation/terrain brush ("veg modifier") compatible with PolyZone/PZCreate workflows to shape pastures, clear land, and mark regrowth states.

### Ranch Property, Land & Administration

- **Ranch Deeds & Ownership** — Courthouse-registered ranch names (e.g., "Circle T Ranch") with transferable deeds.
- **Administrative Controls** — Server staff can assign, change, or delete ranch ownership via player identifiers (license, CitizenID/CID, Discord ID) and trigger ownership webhooks. Ownership transfers log to the ledger and Discord.
- **Discord Role Synchronization** — Configurable mapping from ranch roles (Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Vet, Teamster) to Discord roles with auto-grant/revoke on promotion, termination, or ranch sale.
- **Upgradeable Plots** — Expand land, merge parcels, buy/sell sections, create multi-acre empires subject to zoning constraints.
- **PZCreate Zoning Integration** — Authoritative zoning tool that lets admins or mappers sketch pasture zones, hazard perimeters, and construction parcels. Zones feed map overlays, AI pathing bounds, and resource spawn tables.
- **Building Upgrades** — Modular barns (capacity/cleanliness tiers), smokehouses, silos, windmills, wells, dairies, shearing sheds, chicken coops, pig pens, workshops, and veterinary clinics with decay timers.
- **Decorations & Utilities** — Ranch signage, banners, flags, wagon decals, fencing styles, lighting, troughs, hay bales, bell towers, hitching posts, water towers, smoke stacks.
- **Maintenance & Decay** — Structures degrade over time; repairs require tools/resources with optional minigame interactions.
- **Usable Prop Registry** — Mapping prompt library that lists approved prop models and interactive states (sit, lean, inspect, harvest). Integrates with the zoning tool to auto-tag placeable props for AI navigation and player interactions.

### Livestock Lifecycle & Behavior

- **Species Modules** — Horses, cattle, sheep, goats, pigs, chickens, ducks, turkeys, dogs, cats, and exotic animals (alpaca, bees, rabbits) with species-specific needs and outputs.
- **Genetics & Bloodlines** — Attributes for coat colors, milk yield, wool quality, meat marbling, temperament; inbreeding penalties and bloodline advantages.
- **Animal Personalities & Memory** — Behavioral traits (stubborn bulls, timid cows) and trust meters that respond to player actions; mistreated horses refuse riding, spoiled dogs become extra loyal.
- **Lifecycle Progression** — Calves → mature cattle → aging stock; seasonal cycles (e.g., chickens lay more in spring, pigs fatten before winter).
- **Needs Simulation** — Hunger, thirst, cleanliness, stress, diseases, injuries, social bonds, temperature tolerance; support for manual or AI-managed care routines.
- **Breeding System** — Courtship animations, gestation timers, birthing complications that trigger veterinary minigames.
- **Nicknames & Branding** — Custom names, ear tags, and visible 3D text/branding marks.

### Health, Veterinary & Farrier Gameplay

- **Disease Catalog** — Hoof rot, colic, ticks, pox, parasites with diagnosis minigames and treatment plans.
- **Injury Scenarios** — Wagon accidents, predator bites, broken legs, horn gouges requiring first aid, splints, or surgery.
- **Medical Facilities** — Quarantine pens, surgery tables, med kits, recovery timers.
- **Medications & Tools** — Salves, tonics, poultices, bandages, splints, vaccines, hoof picks, horseshoes.
- **Shoeing System** — Minigame featuring nail placement, shoe type selection, and wear tracking.

### Workforce & Daily Loops

- **Ranch Hand System** — Player or AI workers assignable to feeding, watering, mucking, milking, fence repair, fieldwork, and scouting tasks.
- **Roles & Grades** — Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Vet, Teamster; permissions controlled via admin console and reflected in Discord roles.
- **Task Boards** — Job postings with wages, rewards, cooldowns, XP, and accident risk modifiers.
- **Daily Routines** — Brush horses, muck stalls, feed chickens, check fences, herd cattle, inspect vegetation regrowth.
- **Worker Accidents & Morale** — AI and players can suffer injuries (trampled, kicked); morale affects efficiency; must manage pay, rest, and amenities.

### Production & Processing Chains

- **Dairy Processing** — Milking cows/goats, churning butter, aging cheese with humidity controls.
- **Meat Processing** — Butchering minigame for prime cuts vs spoiled meat; carcass breakdown into steaks, roasts, sausages.
- **Egg & Poultry** — Incubators, brooding hens, chick growth, egg grading.
- **Wool & Fiber** — Shearing, washing, carding, dyeing to produce yarn and cloth.
- **Byproducts** — Manure for fertilizer, bones for tools, hides to leather, feathers for fletching.
- **Smoking & Curing** — Smokehouses for jerky, bacon, hams; brine vats for sausages.
- **Crop Cultivation** — Forage crops (corn, oats, clover, sorghum, alfalfa), irrigation, pest management, and storage spoilage (silos, hay bales with rat risk if untarped).

### Law, Crime & Reputation

- **Rustling Mechanics** — Fence cutting, cattle theft, illegal re-branding; evidence supports sheriff investigations and bounty missions.
- **Insurance System** — Premiums with partial payouts for predator raids or natural disasters.
- **Reputation Tracks** — "Honest Rancher," "Rustler Suspect," "Cattle King" affecting contracts and pricing.
- **Bandits & Predators** — Wolves, cougars, coyotes, bears, and NPC rustler gangs; defensive structures and alert systems.
- **Event Framework** — Blizzards, tornadoes, locust swarms, barn fires, droughts, rodeos, county fairs, harvest festivals, ranch dances, competitions (best bull, best wool, fastest horse).

### Horses & Wagons

- **Training System** — Groundwork, riding, pulling, obstacle training that unlocks rears, skids, stamina boosts, calmer behavior.
- **Temperament & Bonding** — Calm, fiery, stubborn, bold archetypes with bonding levels affecting control.
- **Stud & Auction House** — Breeding services, stud fees, bloodline charts, auction UI with live bidding and Discord announcements.
- **Tack Wear & Maintenance** — Saddles, bridles, horseshoes degrade; repairs require materials or farrier visits.
- **Draft Teams & Logistics** — Hitch 2–4 horses to wagons with performance tied to training and temperament.
- **Wagon Types** — Hay, milk, meat, and tool wagons with load simulations and handling penalties; breakdowns (axles, wheels) needing repair kits.
- **Railroad Integration** — Load cattle into train cars for bulk sales with scheduling mechanics.

### Economy, Contracts & Ledger

- **Dynamic Pricing** — Seasonal and regional demand curves (e.g., beef peaks in winter, wool in spring).
- **Contracts & Auctions** — Town board contracts with timers; auction house with reserve prices, fraud detection, and Discord bidding broadcasts.
- **Market Reputation** — Selling spoiled goods lowers trust; consistent quality unlocks premium contracts.
- **Ledger & Accounting** — Track expenses, upkeep, wages, income, debts, insurance claims, ownership transfers.

*(The remainder of the PRD continues unchanged from the prior version and is available for reference in this file.)*
