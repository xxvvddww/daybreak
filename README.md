# Daybreak

**Your money, by the second.**

Daybreak is a native iPhone app that shows Australian workers what they earn —
and what the taxman takes — in real time, second by second. It turns a salary
into a live, tactile picture: today's earnings ticking up, the moment each day
you stop working for the ATO, your superannuation compounding over a career,
and where your income sits nationally.

It is built entirely with SwiftUI, stores everything on-device, and uses no
backend, accounts, analytics, or third-party dependencies.

> **Disclaimer:** All figures are indicative only and **not financial advice**.
> Tax rates are AU resident 2025–26 and exclude offsets, HECS-HELP, and other
> adjustments.

---

## Getting started

The Xcode project is generated from [`project.yml`](project.yml) with
[XcodeGen](https://github.com/yonaskolb/XcodeGen), so the repository stays clean
and the project file never drifts.

```bash
# 1. Generate Daybreak.xcodeproj (installs XcodeGen via Homebrew if needed)
make                # or: ./Scripts/bootstrap.sh   or:  xcodegen generate

# 2. Open it
open Daybreak.xcodeproj

# 3. In Xcode, select the Daybreak target → Signing & Capabilities → choose your Team.
#    Then build & run (⌘R).
```

Requires **Xcode 16+** and **iOS 17+** (SwiftData).

---

## Configuration

Everything below has a sensible default and is easy to change:

| Setting | Default | Where |
| --- | --- | --- |
| App bundle id | `au.com.tsagroup.daybreak` | `project.yml` |
| Widget bundle id | `au.com.tsagroup.daybreak.widget` | `project.yml` |
| App Group | `group.au.com.tsagroup.daybreak` | both `*.entitlements` files and `SharedStore.appGroupID` |
| Development Team | _(empty — set yours)_ | `project.yml` → `DEVELOPMENT_TEAM` |
| Deployment target | iOS 17.0 | `project.yml` |
| Version / build | 1.0 / 1 | `project.yml` |

**App Group:** the home-screen and lock-screen widgets read a small snapshot
the app writes to a shared App Group container. If you change the bundle prefix,
update the App Group id in both `*.entitlements` files and `SharedStore.appGroupID`
so they match. The app
degrades gracefully if the group isn't configured (it falls back to standard
`UserDefaults`; the widget just won't get cross-process updates until the group
is set up). App Groups work in the Simulator with only the entitlement; on a
device you must enable the **App Groups** capability for your team.

---

## Architecture

Code is organised by feature, with all business logic kept out of the views.

```
Shared/            Pure, dependency-free engine — shared by the app and widget
  Engine/          Tax, earnings, super, pay rates, distribution, damage, day clock
  Formatting/      Currency / time formatters
  SharedStore/     Codable snapshot + App Group read/write
  UI/              Color(hex:) and brand palette (needed by both targets)

Daybreak/          The app
  App/             Entry point, root view, scaffold, tab routing
  Persistence/     SwiftData `Profile` model + observable `ProfileStore`
  Theme/           Light/dark token system + Dynamic-Type typography
  Components/      Reusable views (cards, charts, controls, tab bar)
  Features/        Today · Pay · Super · Damage · Stats · Setup · Onboarding

DaybreakWidget/    WidgetKit extension (home + lock-screen widgets)
DaybreakTests/     Unit tests for the engine
DaybreakUITests/   UI tests for core journeys
```

**Data flow.** The pure engine (`EarningsCalculator`, `TaxCalculator`,
`SuperProjection`, …) operates only on the value type `ProfileInputs`, so it is
trivially testable and identical in the app and the widget. The app persists
`ProfileInputs` as a SwiftData `Profile` and, on every change, writes a
`SharedSnapshot` to the App Group and reloads the widget timelines.

**Persistence split** (per the project constraints):

- **SwiftData** — the user's structured financial profile (`Profile`).
- **AppStorage** — lightweight prefs: appearance and onboarding state.
- **App Group `UserDefaults`** — the snapshot bridged to the widget.

**Live vs. demo.** `DayClock` computes how far through the working day you are:
in **Live** mode from the real clock (with rest-day handling), in **Demo** mode
from a sped-up 80-second loop (great for screenshots and exploring). The Today
and Damage screens tick via `TimelineView`.

---

## Meeting the brief

- ✅ Native SwiftUI only · no login · no backend · no external DB
- ✅ All data on-device · no analytics/ads · no CloudKit/iCloud
- ✅ SwiftData for structured data · AppStorage for light settings
- ✅ Apple frameworks only — no third-party runtime dependencies
- ✅ Light & dark mode · Dynamic Type (`@ScaledMetric`) · VoiceOver labels
- ✅ Modern concurrency (`@Observable`, `@MainActor`, `async`-friendly)
- ✅ Feature-organised, small composable views, logic outside view bodies
- ✅ Unit tests for the engine · UI tests for core journeys

> _FileManager for images/large files:_ the app has no user-supplied images, so
> there are no large files to manage. The hook is the App Group container, which
> is used for the widget snapshot.

---

## Testing

- **Unit tests** (`DaybreakTests`) verify the tax brackets, Medicare levy,
  marginal rate, super projections, percentiles, pay rates and formatters
  against hand-computed values from the original design.
- **UI tests** (`DaybreakUITests`) cover onboarding → home and tab navigation.

Run everything with **⌘U** in Xcode, or:

```bash
xcodebuild test -scheme Daybreak -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Notes

Tax, super and cost-of-living constants live in `CountryConfig.australia`
(`Shared/Engine/CountryConfig.swift`) — the rest of the engine is
jurisdiction-agnostic, so updating rates each financial year is a one-file edit.

The app icon (`Daybreak/Resources/Assets.xcassets/AppIcon.appiconset`) is a
generated placeholder; drop in your final 1024×1024 artwork before shipping.
