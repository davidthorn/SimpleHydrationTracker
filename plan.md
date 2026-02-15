# SimpleHydrationTracker Sprint Plan

## Scope Guardrails (This Sprint)
- iOS app only.
- Watch app integration is out of scope.
- Shared models required by watch must live in `Models` framework.
- Persistence is file-system based JSON in app `Documents` directory.
- Persisted entities are `Codable`, `Identifiable`, `Hashable`.
- Data loads at launch before first feature render.
- Top-level scenes are only:
  - `TodayScene`
  - `HistoryScene`
  - `SettingsScene`

## Staging UX Acceptance Baseline (Mandatory)
- Permission-dependent features must request permission when needed.
- If permission is denied/restricted/not determined, show explicit in-app state components that explain:
  - what is unavailable
  - how to enable permission
  - next action path
- User-facing errors must be presented in UI (inline, banner, alert, or full-state component as appropriate).
- All destructive actions must show confirmation before delete.
- All editable persisted-model forms must implement `$swift` behavior:
  - save appears only when changes exist
  - reset appears only for persisted models with unsaved changes
  - delete appears only for persisted models
  - delete always requires confirmation and supports cancel

## Commit Policy For Every Task
- Stop each task at a working state (buildable and reviewable).
- Create one commit per task.
- Use the planned commit subject exactly.
- After task completion, fill the commit body with:
  - changed files
  - completed work
  - verification notes

### Commit Body Template (Post-Completion)
```text
Files changed:
- <path>
- <path>

Completed:
- <implemented behavior>
- <implemented behavior>

Verification:
- <build/run/manual check>
- <notes>
```

---

## Stage 1 - Foundation and App Skeleton
Goal: establish architecture, navigation roots, and design token baseline.

### Task 1.1 - Create folders and feature boundaries
Planned commit subject:
`chore: establish scene-feature-service-store-viewmodel folder structure`

Post-completion commit body:
```text
Files changed:
- <list created/moved files and folders>

Completed:
- Added project folder layout for Scenes, Features, Views, ViewModels, Services, Stores.
- Reserved structure for Today, History, Settings feature areas.

Verification:
- Project opens and compiles after file moves.
```

### Task 1.2 - Replace placeholder root with single TabView and scene roots
Planned commit subject:
`feat: wire ContentView TabView to TodayScene HistoryScene SettingsScene`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/ContentView.swift
- <scene files>

Completed:
- Added exactly one TabView in ContentView.
- Added TodayScene, HistoryScene, SettingsScene as tab roots.
- No additional TabView introduced elsewhere.

Verification:
- xcodebuild iOS target succeeds.
- Tab navigation renders all 3 root scenes.
```

### Task 1.3 - Add route enums and destination wiring per scene
Planned commit subject:
`feat: add scene-owned navigation routes and destinations`

Post-completion commit body:
```text
Files changed:
- <scene route files>
- <scene files>

Completed:
- Added Hashable route values per scene.
- Added NavigationLink(value:) + navigationDestination(for:) in owning scene only.
- Added placeholder route views for all declared routes.

Verification:
- In-flow navigation pushes expected destination views.
```

---

## Stage 2 - Shared Models in Models Framework
Goal: define all shared domain models as public and watch-ready.

### Task 2.1 - Create shared hydration domain models
Planned commit subject:
`feat(models): add public shared hydration model types`

Post-completion commit body:
```text
Files changed:
- Models/<model files>.swift

Completed:
- Added shared models in Models framework with one type per file.
- Ensured public structs, public properties, public initializers.
- Conformed persisted entities to Codable, Identifiable, Hashable, Sendable where valid.

Verification:
- Models target builds cleanly.
```

### Task 2.2 - Add route payload model identifiers
Planned commit subject:
`feat(models): add route-safe identifier and date payload structures`

Post-completion commit body:
```text
Files changed:
- Models/<identifier/payload files>.swift

Completed:
- Added route payload models for entry and day navigation.
- Standardized IDs and date payload usage across features.

Verification:
- Scene route enums compile using model payloads.
```

---

## Stage 3 - File-Based Persistence and Streams
Goal: actor-backed stores with JSON in Documents and launch-time loading.

### Task 3.1 - Build file path and JSON codec helpers
Planned commit subject:
`feat(store): add documents directory file path and json codec utilities`

Post-completion commit body:
```text
Files changed:
- <store/support files>

Completed:
- Added reusable Documents file resolution helpers.
- Added reusable JSONEncoder/JSONDecoder setup at owner scope.

Verification:
- Helper usage validated in a local store integration path.
```

### Task 3.2 - Implement hydration store protocol + actor
Planned commit subject:
`feat(store): implement actor-backed hydration store with asyncstream updates`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Protocols/HydrationStoreProtocol.swift
- SimpleHydrationTracker/Protocols/StoreFilePathResolving.swift
- SimpleHydrationTracker/Stores/HydrationStore.swift
- SimpleHydrationTracker/Stores/StoreFilePathResolver.swift

Completed:
- Added protocol-backed hydration store.
- Implemented read/write to Documents JSON.
- Added AsyncStream publication for updates.
- Moved protocol contracts to dedicated `Protocols` folder.
- Injected path resolution via protocol instead of concrete resolver type.
- Applied Swift 6 isolation-safe async path-resolution calls inside actor methods.

Verification:
- Add/update/delete flows persist and reload correctly.
- iOS scheme build succeeds after protocol-folder and DI refactor.
```

### Task 3.3 - Implement goal store protocol + actor and app launch load
Planned commit subject:
`feat(store): add goal persistence and load persisted state on app launch`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Protocols/GoalStoreProtocol.swift
- SimpleHydrationTracker/Stores/GoalStore.swift
- SimpleHydrationTracker/SimpleHydrationTrackerApp.swift
- SimpleHydrationTracker/AppLaunchState.swift
- SimpleHydrationTracker/Views/LaunchLoadingView.swift
- SimpleHydrationTracker/Views/LaunchErrorView.swift

Completed:
- Added protocol-backed goal store with actor implementation.
- Wired startup loading before first feature render.
- Added JSON persistence for hydration goal in Documents directory.
- Added AsyncStream goal publication for observers.
- Added app launch loading/ready/failed state handling.
- Added launch loading and launch error placeholder views.
- Updated app-level store dependencies to protocol-typed properties.

Verification:
- Relaunch restores goal and hydration entries from Documents files.
- iOS scheme build succeeds after app launch preload and protocol DI changes.
```

---

## Stage 4 - Today Feature (Primary Experience)
Goal: working today flow with quick logging, custom logging, and goal setup route.

### Task 4.1 - Today view model and stream subscription
Planned commit subject:
`feat(today): add TodayViewModel with store stream subscription`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewState.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Scenes/Today/TodayScene.swift
- SimpleHydrationTracker/ContentView.swift
- SimpleHydrationTracker/SimpleHydrationTrackerApp.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift

Completed:
- Added TodayViewModel and state projection for today summary.
- Subscribed to store AsyncStream updates.
- Ensured UI-facing mutations are MainActor safe.
- Updated Today view wiring to initialize the view model from protocol-backed stores.
- Enforced app ownership of concrete `ServiceContainer` creation (`SimpleHydrationTrackerApp` owns construction).
- Removed concrete `ServiceContainer` creation from view/scene paths and switched previews to debug-only `PreviewServiceContainer`.

Verification:
- Today state updates immediately after store changes.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 4.2 - Today main view and progress UI
Planned commit subject:
`feat(today): build progress-first today view with quick add actions`

Post-completion commit body:
```text
Files changed:
- Models/QuickAddAmount.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayProgressCardView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayQuickAddSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayRouteLinksSectionView.swift
- SimpleHydrationTracker/Components/TodayRouteRowComponent.swift

Completed:
- Added custom-styled Today UI with progress hero and quick-add actions.
- Replaced raw `Int` quick-add options with shared `QuickAddAmount` enum in `Models`.
- Added Task-based button actions with cancellation guard checks.
- Added user-visible error presentation for Today logging failures.
- Extracted reusable Today route row into a dedicated component.

Verification:
- Quick-add updates progress and persists entries.
- Logging failures are surfaced to user with actionable messaging.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 4.3 - Today child routes implementation
Planned commit subject:
`feat(today): implement addCustomAmount editTodayEntry dayDetail goalSetup routes`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Scenes/Today/TodayScene.swift
- SimpleHydrationTracker/Features/Today/Views/AddCustomAmountView.swift
- SimpleHydrationTracker/Features/Today/Views/EditTodayEntryView.swift
- SimpleHydrationTracker/Features/Today/Views/DayDetailView.swift
- SimpleHydrationTracker/Features/Today/Views/GoalSetupView.swift
- SimpleHydrationTracker/Features/Today/ViewModels/AddCustomAmountViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/EditTodayEntryViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/DayDetailViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/GoalSetupViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Protocols/HydrationServiceProtocol.swift
- SimpleHydrationTracker/Protocols/GoalServiceProtocol.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Services/HydrationService.swift
- SimpleHydrationTracker/Services/GoalService.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift
- SimpleHydrationTracker/SimpleHydrationTrackerApp.swift

Completed:
- Implemented all TodayScene child route views.
- Added save/reset/delete behavior where editable persisted models are used.
- Added delete confirmation dialogs for all Today delete flows.
- Wired route views to service dependencies from the owning scene.
- Added route-level view models for loading, persistence actions, and error state.
- Enforced architecture rule that ViewModels depend on Services only (no direct Store usage).
- Added hydration/goal service protocols and concrete service implementations over stores.
- Updated service container and app preload flow to use services as the dependency surface.

Verification:
- Navigation to all Today routes works and returns correctly.
- Form button visibility follows `$swift` save/reset/delete rules.
- Delete flows require confirm and support cancel.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

---

## Stage 5 - History Feature
Goal: browse prior days and inspect entries.

### Task 5.1 - History view model and day list
Planned commit subject:
`feat(history): add history list projection and grouping by day`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDaySummary.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryViewModel.swift
- SimpleHydrationTracker/Features/History/Views/HistoryView.swift
- SimpleHydrationTracker/Scenes/History/HistoryScene.swift
- SimpleHydrationTracker/ContentView.swift

Completed:
- Added history projection by day from persisted entries.
- Added list UI optimized for fast scanning.
- Added empty and error states for history loading/render failures.
- Wired HistoryScene/HistoryView to service-container dependency injection.
- Added route navigation from day rows to History day detail route.

Verification:
- History shows correct day groups from stored data.
- History error states are presented in UI and recover on retry/reopen.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 5.2 - History child routes implementation
Planned commit subject:
`feat(history): implement dayDetail entryDetail historyFilter routes`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Scenes/History/HistoryScene.swift
- SimpleHydrationTracker/Features/History/Routes/HistoryRoute.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDayDetailViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/EntryDetailViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryFilterViewModel.swift
- SimpleHydrationTracker/Features/History/Views/HistoryDayDetailView.swift
- SimpleHydrationTracker/Features/History/Views/EntryDetailView.swift
- SimpleHydrationTracker/Features/History/Views/HistoryFilterView.swift
- SimpleHydrationTracker/Features/History/Routes/HistoryDayDetailView.swift (deleted)
- SimpleHydrationTracker/Features/History/Routes/EntryDetailView.swift (deleted)
- SimpleHydrationTracker/Features/History/Routes/HistoryFilterView.swift (deleted)
- Models/HistoryFilterSelection.swift
- Models/HistoryDaySummary.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDaySummary.swift (deleted)

Completed:
- Implemented day detail, entry detail, and filter route views.
- Added scene-owned destination registration for all history routes.
- Added error presentation for route-level data load failures.
- Added persisted-entry edit flow in entry detail with save/reset/delete behavior.
- Added delete confirmation dialog with cancel path before entry deletion.
- Kept route hashables in `Routes` and moved route destination UI types into `Views`.
- Kept view models dependent on services (no direct store dependencies).
- Moved shared history model/value types used by this flow into `Models`.
- Updated History filter flow imports after model relocation (`HistoryFilterView` / `HistoryFilterViewModel`).

Verification:
- Route transitions and filters function as expected.
- Day/entry detail failures are shown to user with clear fallback actions.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 5.3 - History UI/UX and design implementation (staging-ready)
Planned commit subject:
`feat(history-ui): complete history ux and visual design for staging readiness`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/History/ViewModels/HistoryViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDayDetailViewModel.swift
- SimpleHydrationTracker/Features/History/Views/HistoryView.swift
- SimpleHydrationTracker/Features/History/Views/HistoryDayDetailView.swift
- SimpleHydrationTracker/Features/History/Views/EntryDetailView.swift
- SimpleHydrationTracker/Features/History/Views/HistoryFilterView.swift
- SimpleHydrationTracker/Theme/AppTheme.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayRowComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistoryEntryRowComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistorySummaryCardComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistoryStatusCardComponent.swift
- plan.md

Completed:
- Applied History feature UI/UX and visual design rules to all Stage 5 screens.
- Ensured non-default, clean-cut, intuitive visual hierarchy across History root and child routes.
- Added/updated reusable Components for complex body sections to keep views maintainable.
- Ensured editable forms in History routes follow `$swift` save/reset/delete + delete confirmation behavior.
- Ensured loading, empty, and error states are explicit, actionable, and visually consistent.
- Ensured all async UI actions are Task-driven in Views with cancellation guards where side effects can occur.
- Completed rule-by-rule `$swift` compliance check for Stage 5 deliverables:
- [pass] single TabView remains owned by app root.
- [pass] Scene-owned navigation destinations retained in HistoryScene.
- [pass] ViewModels remain owned by Views using StateObject init pattern.
- [pass] Async side-effect actions use Task from View with Task.isCancelled guards.
- [pass] Form edit/delete UX in EntryDetailView preserves save/reset/delete + confirmation flow.
- [pass] Data structures/components follow one-type-per-file organization with previews.

Verification:
- Manual QA pass for History flows: list, day detail, entry detail, filter, edit, delete confirm/cancel.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
- Stage 5 marked staging-ready only after design + UX + behavior checks all pass.
```

---

## Stage 6 - Settings and Reminder Services
Goal: settings flows and service-level reminder behavior.

### Task 6.1 - Settings view model and settings root UI
Planned commit subject:
`feat(settings): add settings root flow and editable preference state`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/Settings/ViewModels/SettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift

Completed:
- Added settings root view model/state.
- Added route links for goal, reminder, permissions, units, and data management.
- Added settings-level error presentation pattern for failed preference writes.
- Wired SettingsView to own its ViewModel via StateObject init pattern.
- Added loading indicator state for settings root initialization.
- Added inline + alert error presentation bindings and dismiss flow for settings-level failures.

Verification:
- Settings routes present correctly.
- Preference write failures are shown in UI and do not silently fail.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 6.2 - Reminder service protocol and implementation
Planned commit subject:
`feat(reminders): implement notification scheduling service abstraction`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Protocols/ReminderServiceProtocol.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Features/Settings/Models/ReminderAuthorizationStatus.swift
- SimpleHydrationTracker/Features/Settings/Models/ReminderSchedule.swift
- SimpleHydrationTracker/Features/Settings/Models/ReminderServiceError.swift
- SimpleHydrationTracker/Services/ReminderService.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift

Completed:
- Added protocol-backed reminder service using Apple notification APIs.
- Added cadence logic for gentle reminder spacing and rescheduling.
- Added permission status mapping for notDetermined/denied/authorized/provisional states.
- Added actor-backed service implementation with schedule update/clear operations.
- Added authorization status AsyncStream observation for UI consumers.
- Added service container integration and preview reminder service implementation.

Verification:
- Reminder schedule requests can be created and refreshed from settings changes.
- Permission request path works, and denied/restricted states can be surfaced to UI components.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 6.3 - Settings child routes + supporting preference/reminder wiring
Planned commit subject:
`feat(settings): implement settings routes with supporting preference and reminder service wiring`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/ContentView.swift
- SimpleHydrationTracker/Scenes/Settings/SettingsScene.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift
- SimpleHydrationTracker/Features/Settings/Routes/GoalSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Routes/ReminderSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Routes/NotificationPermissionsView.swift
- SimpleHydrationTracker/Features/Settings/Routes/UnitsSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Routes/DataManagementView.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/GoalSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/ReminderSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/NotificationPermissionsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/UnitsSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/DataManagementViewModel.swift
- SimpleHydrationTracker/Features/Settings/Models/SettingsVolumeUnit.swift
- SimpleHydrationTracker/Features/Settings/Models/ReminderSchedule.swift
- SimpleHydrationTracker/Protocols/ReminderServiceProtocol.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Protocols/UnitsPreferenceServiceProtocol.swift
- SimpleHydrationTracker/Services/ReminderService.swift
- SimpleHydrationTracker/Services/UnitsPreferenceService.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift

Completed:
- Implemented all SettingsScene child routes.
- Added required save/reset/delete + confirmation behavior where persisted models are edited.
- Added explicit permission-state components for notification settings when access is unavailable.
- Added actionable error components/messages for settings route failures.
- Wired SettingsScene and SettingsView to service-container dependency injection for route-level view model creation.
- Added units preference service and protocol-backed persistence flow for units route save/reset/delete behavior.
- Extended reminder service protocol and implementation to support schedule fetch/observe needed for route form handling.

Verification:
- All settings routes save and reload persisted changes.
- Permission-missing UI appears correctly and guides user to resolution path.
- Form button visibility and delete confirmation strictly match `$swift` rules.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 6.4 - App-wide preferences observation and application
Planned commit subject:
`feat(preferences): apply settings preferences across app features with live observation`

Post-completion commit body:
```text
Files changed:
- Models/HistoryDaySummary.swift
- Models/HistoryFilterPreferences.swift
- Models/HistoryFilterSelection.swift
- SimpleHydrationTracker/Features/Settings/Models/SettingsVolumeUnit+Display.swift
- SimpleHydrationTracker/Features/Settings/Routes/GoalSettingsView.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/GoalSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/SettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift
- SimpleHydrationTracker/Features/Today/ViewModels/AddCustomAmountViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/DayDetailViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/EditTodayEntryViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/GoalSetupViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/AddCustomAmountView.swift
- SimpleHydrationTracker/Features/Today/Views/EditTodayEntryView.swift
- SimpleHydrationTracker/Features/Today/Views/GoalSetupView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayProgressCardView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayQuickAddSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/DayDetailView.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryFilterViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDayDetailViewModel.swift
- SimpleHydrationTracker/Features/History/ViewModels/EntryDetailViewModel.swift
- SimpleHydrationTracker/Features/History/Views/HistoryFilterView.swift
- SimpleHydrationTracker/Features/History/Views/HistoryView.swift
- SimpleHydrationTracker/Features/History/Views/HistoryDayDetailView.swift
- SimpleHydrationTracker/Features/History/Views/EntryDetailView.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayRowComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistorySummaryCardComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistoryEntryRowComponent.swift
- SimpleHydrationTracker/Protocols/HistoryFilterPreferenceServiceProtocol.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Scenes/History/HistoryScene.swift
- SimpleHydrationTracker/Services/HistoryFilterPreferenceService.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- plan.md

Completed:
- Added shared `SettingsVolumeUnit` display/format extension for consistent ml/oz value rendering.
- Expanded unit conversion helpers to support form parsing/edit formatting for both ml and oz inputs.
- Wired Settings, Today, and History route view models to observe units preference streams via `UnitsPreferenceServiceProtocol`.
- Updated Today and History views/components to render hydration amounts and form labels using the selected unit.
- Added unit-aware keyboard/input behavior for amount and goal forms (`decimalPad` for oz, parsing to persisted ml values).
- Implemented persisted history filter preferences (`HistoryFilterPreferences`) with async observation and UserDefaults backing.
- Wired History filter route toggles/range to persistence so changes are remembered across navigation and app relaunch.
- Applied persisted filter settings in both History list and Day Detail projections, including source filtering.
- Added Filter access from Day Detail toolbar.
- Wired Today to observe goal stream updates so progress/remaining summary reacts immediately when goals change.
- Wired History to observe goal stream updates and project goal status metadata per day.
- Added goal-status UI in History day rows (reached/missed/no-goal) with visual icon + highlight treatment.
- Kept default fallback behavior at `.milliliters` when preference values are missing/invalid.

Verification:
- Manual QA pass confirms units and goal updates react immediately across Today/History routes.
- History filter choices persist, reload on launch, and are applied in both list and day-detail routes.
- Goal status indicators in History rows update when goal settings change.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 6.5 - Settings UI/UX and design implementation (staging-ready)
Planned commit subject:
`feat(settings-ui): complete settings ux and visual design for staging readiness`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Theme/AppTheme.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift
- SimpleHydrationTracker/Features/Settings/Models/SettingsRow.swift
- SimpleHydrationTracker/Features/Settings/Views/GoalSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Views/ReminderSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Views/NotificationPermissionsView.swift
- SimpleHydrationTracker/Features/Settings/Views/UnitsSettingsView.swift
- SimpleHydrationTracker/Features/Settings/Views/DataManagementView.swift
- SimpleHydrationTracker/Features/Settings/Components/SettingsHeroCardComponent.swift
- SimpleHydrationTracker/Features/Settings/Components/SettingsRouteSectionComponent.swift
- SimpleHydrationTracker/Features/Settings/Components/SettingsRouteRowComponent.swift
- SimpleHydrationTracker/Features/Settings/Components/SettingsStatusCardComponent.swift
- plan.md

Completed:
- Added app-level theme tokens (`success`, `warning`) used by Settings status and result states.
- Reworked Settings root into a non-default, clean-cut layout with grouped sections, hero header, and route row components.
- Introduced reusable Settings components for hero, route-row, and status-card patterns to standardize visual language.
- Upgraded all Settings child routes to use consistent hero sections and explicit status/error messaging cards.
- Applied gradient-backed backgrounds and hidden scroll/form backgrounds for cohesive app-level styling.
- Preserved route-level behavior while improving permission-denied, not-determined, and error feedback clarity.
- Kept form/task behavior aligned with existing Stage 6 logic while raising staging UI/UX quality.
- Completed compiler verification for the full app scheme after Settings design updates.

Verification:
- Manual QA pass for Settings flows: goal, reminders, permissions, units, data management.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
- Stage 6 marked staging-ready only after design + UX + behavior checks all pass.
```

---

## Stage 7 - TodayScene Polishing
Goal: deliver staging-ready Today UI/UX with clean-cut, non-default design and complete interaction clarity.

### Task 7.1 - Today UI/UX and design implementation (staging-ready)
Planned commit subject:
`feat(today-ui): complete today scene ux and visual design for staging readiness`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayProgressCardView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayQuickAddSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayRouteLinksSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/AddCustomAmountView.swift
- SimpleHydrationTracker/Features/Today/Views/EditTodayEntryView.swift
- SimpleHydrationTracker/Features/Today/Views/GoalSetupView.swift
- SimpleHydrationTracker/Features/Today/Views/DayDetailView.swift
- SimpleHydrationTracker/Features/Today/Models/TodayIntakeChartPoint.swift
- SimpleHydrationTracker/Features/Today/Models/TodayIntakeChartScale.swift
- SimpleHydrationTracker/Features/Today/Models/TodayIntakeChartData.swift
- SimpleHydrationTracker/Features/Today/Components/TodayHeroCardComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayStatusCardComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayDayEntryRowComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayRouteRowComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayIntakeChartCardComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayToastComponent.swift
- SimpleHydrationTracker/Components/TodayRouteRowComponent.swift (deleted)
- plan.md

Completed:
- Applied app-level design constraints to all TodayScene surfaces and routes.
- Ensured non-default, inspiring, intuitive visual hierarchy for progress, quick-add, and navigation actions.
- Added/updated reusable Components for hero, status, route-row, and day-entry patterns to keep Today views maintainable.
- Added a dedicated bar chart card below Quick Add to visualize hydration intake for the current day.
- Implemented adaptive chart bucket sizing from first-to-last entry span (5m / 15m / 30m / 60m scales).
- Tuned X-axis label stride so short windows remain readable while preserving detailed bar granularity.
- Converted Today root and day-detail surfaces to gradient-backed card layouts with explicit empty/error feedback.
- Upgraded form routes (Add Amount, Edit Entry, Goal Setup) with consistent hero/status cards and hidden form backgrounds.
- Wired route links to use real current-day and latest-entry context; edit route now shows a disabled guidance row until an entry exists.
- Enabled Day Detail rows to navigate directly to the entry detail/editor route for the tapped entry.
- Added animated Quick Add success toast confirmation with auto-dismiss.
- Kept form interactions aligned with $swift save/reset/delete visibility rules and delete confirmations.
- Moved Today-specific route row component out of the app-level `Components` folder into `Features/Today/Components`.

Verification:
- Manual QA for Today flows and route navigation.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 7.2 - Today accessibility and interaction pass + History day overview enrichment
Planned commit subject:
`feat(today-history): improve accessibility feedback and enrich history day overviews`

Post-completion commit body:
```text
Files changed:
- SimpleHydrationTracker/Features/Today/Views/TodayQuickAddSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayProgressCardView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayRouteLinksSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/EditTodayEntryView.swift
- SimpleHydrationTracker/Features/Today/Views/GoalSetupView.swift
- SimpleHydrationTracker/Features/Today/Components/TodayIntakeChartCardComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayRouteRowComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayDayEntryRowComponent.swift
- SimpleHydrationTracker/Features/Today/Components/TodayToastComponent.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryViewModel.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayRowComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayMiniChartComponent.swift
- SimpleHydrationTracker/Features/Settings/Routes/SettingsRoute.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift
- SimpleHydrationTracker/Features/Settings/Views/SipSizeSettingsView.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/SettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/SipSizeSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/Models/SipSizeOption+Display.swift
- SimpleHydrationTracker/Protocols/SipSizePreferenceServiceProtocol.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Scenes/Settings/SettingsScene.swift
- SimpleHydrationTracker/Services/SipSizePreferenceService.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift
- Models/HistoryDaySummary.swift
- Models/HistoryDayIntakeBucket.swift
- Models/QuickAddAmount.swift
- Models/SipSizeOption.swift
- plan.md

Completed:
- Added explicit accessibility labels, values, and hints for quick-add controls, progress summary, day rows, route rows, and intake chart bars.
- Added accessibility identifiers for Today route links to improve UI-test targeting and disabled-state validation.
- Improved confirmation semantics for destructive Today actions with clearer delete titles/messages and explicit button hints.
- Kept quick-add success feedback accessible through the toast component while maintaining iOS 17.6-compatible modifiers.
- Enriched History day rows with a compact intake chart and inline summary stats before day-detail navigation.
- Added day analytics projection in history state (average per hour, average per entry, peak intake bucket, and chart bucket series).
- Extended shared `HistoryDaySummary` model to carry chart + analytics metadata for richer cross-surface day summaries.
- Added shared `SipSizeOption` and protocol-backed sip-size preference service with AsyncStream observation.
- Added Settings route + screen to configure sip size with save/reset/delete behavior and preference preview.
- Updated Today quick-add generation to use realistic sip-based increments (small intervals) while preserving larger one-tap amounts.
- Converted `QuickAddAmount` to a dynamic value model so quick-add options can adapt to user preference.

Verification:
- Manual VoiceOver-oriented pass for key Today interactions (quick add, route links, day entry rows, progress summary, chart).
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

### Task 7.3 - TodayScene and Day Detail consolidation + realistic quick-add refinements
Planned commit subject:
`feat(today-history-settings): consolidate day detail and finalize realistic quick-add workflow`

Post-completion commit body:
```text
Files changed:
- Models/HistoryDaySummary.swift
- Models/HistoryDayIntakeBucket.swift
- Models/QuickAddAmount.swift
- Models/SipSizeOption.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayRowComponent.swift
- SimpleHydrationTracker/Features/History/Components/HistoryDayMiniChartComponent.swift
- SimpleHydrationTracker/Features/History/ViewModels/HistoryViewModel.swift
- SimpleHydrationTracker/Features/History/Views/HistoryDayDetailView.swift (deleted)
- SimpleHydrationTracker/Features/History/ViewModels/HistoryDayDetailViewModel.swift (deleted)
- SimpleHydrationTracker/Features/Settings/Routes/SettingsRoute.swift
- SimpleHydrationTracker/Features/Settings/Models/SipSizeOption+Display.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/SettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/ViewModels/SipSizeSettingsViewModel.swift
- SimpleHydrationTracker/Features/Settings/Views/SettingsView.swift
- SimpleHydrationTracker/Features/Settings/Views/SipSizeSettingsView.swift
- SimpleHydrationTracker/Features/Today/Components/TodayDayEntryRowComponent.swift
- SimpleHydrationTracker/Features/Today/ViewModels/TodayViewModel.swift
- SimpleHydrationTracker/Features/Today/ViewModels/AddCustomAmountViewModel.swift
- SimpleHydrationTracker/Features/Today/Views/TodayView.swift
- SimpleHydrationTracker/Features/Today/Views/TodayQuickAddSectionView.swift
- SimpleHydrationTracker/Features/Today/Views/AddCustomAmountView.swift
- SimpleHydrationTracker/Protocols/ServiceContainerProtocol.swift
- SimpleHydrationTracker/Protocols/SipSizePreferenceServiceProtocol.swift
- SimpleHydrationTracker/Scenes/History/HistoryScene.swift
- SimpleHydrationTracker/Scenes/Settings/SettingsScene.swift
- SimpleHydrationTracker/Services/ServiceContainer.swift
- SimpleHydrationTracker/Services/SipSizePreferenceService.swift
- SimpleHydrationTracker/Services/PreviewServiceContainer.swift
- plan.md

Completed:
- Implemented configurable sip-size preference in Settings and persisted it through a protocol-backed AsyncStream service.
- Updated Today quick-add behavior to generate realistic small sip intervals while keeping larger one-tap amounts.
- Added size descriptors and SF Symbol size icons to Today quick-add controls for better contextual guidance.
- Embedded quick-add controls in Add Amount form to prefill the amount text while preserving manual editing.
- Enhanced Day Detail entry rows with size-based icons and intake descriptors for each entry.
- Enriched History day rows with mini intake chart + summary stats before opening day detail.
- Consolidated duplicate day-detail flows by removing History-specific day detail/view model and routing History to shared Day Detail.
- Added Today route destination support in HistoryScene so shared Day Detail navigation remains consistent across scenes.

Verification:
- Manual regression pass complete for Today/History/Settings interactions related to quick add, add amount, and day detail navigation.
- `xcodebuild -project SimpleHydrationTracker.xcodeproj -scheme SimpleHydrationTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds.
```

## Stage 8 - Polish, Validation, and Handoff
Goal: production-readiness checks and review handoff quality.

### Task 8.1 - Theme pass and UX polish
Planned commit subject:
`feat(ui): apply custom clean-cut design system across all scenes`

Post-completion commit body:
```text
Files changed:
- <theme files>
- <updated view files>

Completed:
- Applied non-default visual system (tokens, spacing, typography hierarchy, component styles).
- Ensured intuitive action hierarchy and strong readability.

Verification:
- Manual QA on common flows across Today, History, Settings.
```

### Task 8.2 - Build and warning gate pass
Planned commit subject:
`chore: complete build validation and remove compiler warnings`

Post-completion commit body:
```text
Files changed:
- <files adjusted to fix warnings/build issues>

Completed:
- Resolved compiler warnings.
- Confirmed iOS build success for review handoff.

Verification:
- xcodebuild with iPhone 17 Pro simulator passes for iOS app target.
```

### Task 8.3 - Sprint closeout documentation
Planned commit subject:
`docs: add sprint implementation summary and pending watch integration notes`

Post-completion commit body:
```text
Files changed:
- <docs files>

Completed:
- Documented implemented behavior, known limitations, and explicit watch integration follow-ups.
- Captured service-level extension points for future WatchConnectivity.

Verification:
- Documentation reflects shipped sprint behavior and next sprint entry points.
```

---

## Future Sprint Placeholder (Not In Scope Now)
- Add service-level WatchConnectivity sync for phone-to-watch update propagation.
- Keep UI unchanged while wiring WC in service layer.
