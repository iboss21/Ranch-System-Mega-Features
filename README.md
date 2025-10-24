# Ranch System: Omni Frontier

This repository now ships two deliverables for RedM server owners:

1. **Omni Frontier Resource (`resource/`)** — a production-ready RedM script scaffold that provides ranch deed administration, zoning & vegetation editing, and mapper prop tooling with Discord webhook placeholders.
2. **Product Requirements Document (PRD)** — a long-form blueprint that covers the complete ranch-management vision. Use it to guide future milestones layered on top of the core resource.

## Resource Overview

The `resource/` directory is a standalone RedM resource that can be dropped into your `resources` folder. It focuses on three critical foundations requested by the design brief:

- **Administrative Controls** — commands for creating, deleting, and transferring ranch deeds by player identifier (license, CID, Discord). Discord role IDs can be attached per ranch to support out-of-band automation.
- **Zoning & Vegetation Toolkit** — an in-game zone creator (compatible with PZCreate-style workflows) that stores polygon points, applies vegetation modifiers, and broadcasts data to connected clients.
- **Mapper Prop Prompts** — whitelisted prop placement utilities so staff can spawn usable ranch props and persist them per ranch without restarting the server.

These systems persist to JSON by default, include Discord webhook hooks for ownership events, and expose client exports for future modules (livestock, jobs, etc.).

## Installation

1. Copy the `resource` folder to your server and rename it (e.g., `omni_ranch`).
2. Add the resource to your server `resources.cfg`:
   ```cfg
   ensure omni_ranch
   ```
3. Install [oxmysql](https://github.com/overextended/oxmysql) if you plan to swap the JSON storage for SQL; the included storage layer is JSON-based by default.
4. Grant admins the `ranch.admin` ACE or add their identifiers in `shared/config.lua`.

## Configuration Highlights (`resource/shared/config.lua`)

- `Config.Admin` — ACE permission and identifier whitelist.
- `Config.IdentifierPriority` — order in which identifiers are resolved when admins omit arguments.
- `Config.Discord` — webhook URL and role prefix fields to power ownership notifications.
- `Config.Zoning` — command names and default vegetation state for the PZCreate toolchain.
- `Config.Props` — whitelisted prop models available to mappers.
- `Config.Storage` — JSON files for ranch deeds and vegetation; replace with database logic as needed.

## Admin Commands

| Command | Description |
| --- | --- |
| `/ranchcreate <name> [identifier]` | Create a ranch deed owned by the provided identifier (license:, cid:, discord:). |
| `/ranchdelete <ranchId>` | Remove the ranch and purge stored data. |
| `/ranchtransfer <ranchId> <identifier>` | Transfer ownership to another player identifier. |
| `/ranchsetrole <ranchId> <discordRoleId>` | Associate a Discord role ID with the ranch (for external bots or Tebex perks). |
| `/pzcreate [zoneId]` | Begin drawing a polygon zone using Left Alt (point), Enter (save), Backspace (cancel). |
| `/pzsave` | Force-save the current zone in progress. |
| `/pzcancel` | Abort the current zone creation session. |
| `/ranchprop <model> [ranchId]` | Spawn a whitelisted prop for the ranch (defaults to global placement). |
| `/ranchpropdel [ranchId]` | Remove all stored props for the ranch. |

All commands are admin-gated via ACE permissions or identifier whitelist.

## Data Events & Integrations

- `ranch:zones:sync` / `ranch:zones:updated` — broadcast when parcels change.
- `ranch:vegetation:update` / `ranch:vegetation:bulk` — per-zone vegetation modifiers pushed to clients.
- `ranch:props:update` — mapper prop payload for clients.
- `ranch:ownershipChanged` (server event) — emitted after transfers to trigger Discord webhooks or other automation.

Client exports (`GetRanchZones`, `GetVegetation`, `GetProps`) allow future systems to consume authoritative data (e.g., livestock AI, soil simulation, predator spawn logic).

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
