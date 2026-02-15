---
name: swift
description: Use for any Swift-related request. Enforce only confirmed, widely available Swift APIs; never invent types, functions, or frameworks.
---

# Swift Guardrails

## Core rule
- No task is complete until a documented rule-by-rule compliance check is passed.
- Read the instruction to the end, and if this instruction contains any questions, with or without the use of a ? symbol, no work is permitted until this question is answer from the user, you can not infer the answer.
- No inference, if in doubt ask, else don't do what you infer is better in your mind. Its the users decision not yours.
- Only use confirmed, widely available Swift APIs that exist in the user’s toolchain.
- Always use Swift 6.* compliant code.
- All data structures must be defined in their own file.
- Any new Swift file must include an Xcode-style header comment with "Created by David Thorn" and standard Swift comment format at the top of the file.
- When running `xcodebuild`, use the simulator device name `iPhone 17 Pro` if available; otherwise ask which simulator to use.
- All Model structs must be public by default, with public init's, and all properties public unless otherwise asked.
- The data in the used in the comment should be DD.MM.YYYY
- Type-Erasure is only used when explicitly asked for. Never use it unless told to.
- Do not recreate deterministic dependencies inside hot or repeated code paths. Instantiate and configure reusable collaborators once at the owning scope (type/actor/service), then reuse them. Recreate only when behavior must vary per call. This applies to encoders/decoders, formatters, regexes, calendars, date formatters, file managers/wrappers, HTTP clients, etc.

## If uncertain
- Say you’re unsure about the API’s availability.
- Ask the user to confirm their Swift/Xcode version, or propose a known, compatible alternative.

## Prohibited
- Do not invent or assume APIs.
- Do not reference speculative or unreleased Swift features.
- Only Apple Frameworks should be used.
- No deprecated code is allowed, unless explicitly asked for.
- The projects minimum version must always be respected when implementing code. If iOS 17.* then all code should be compatible for these devices.

## Output style
- Prefer minimal, production-safe code.
- Prefer compatibility over novelty when multiple options exist.

## Protocol Typing Policy (Strict)

- Do not use existential types.
- Do not use the `any` keyword anywhere. Unless explicitly requested directly from the user, and never infered, or implied.
- Do not use generics for dependency abstraction unless explicitly requested by the user.
- Do not use `associatedtype`-based protocol abstractions or generic type parameters as a workaround unless the user explicitly asks for generics.
- Required default: protocol-oriented APIs + concrete stored/runtime types.
- Default style: protocol-typed APIs (without `any`) and protocol-backed concrete implementations.

# TabView
- Exactly one `TabView` is allowed in the app.
- That single `TabView` must be declared directly in `ContentView.body`, or directly in the View declared in `WindowGroup` in `App.body`.
- No other `TabView` is allowed anywhere else in the project.
- All in-flow tab navigation destinations must be handled in `Scene` views.

## Scenes
- In this skill, a `Scene` means a SwiftUI `View` whose type name ends with `Scene`.
- `Scene` views are top-level navigation owners.
- A `Scene` must not declare `TabView`, return `TabView`, or contain `TabView` anywhere in its body tree.
- A `Scene` must not present, render, or contain child `Scene` views.
- A `Scene` may own a `NavigationStack`.
- A `Scene` owns and controls all `.navigationDestination(for:)` handlers for its `NavigationStack`.
- If a `NavigationLink(value:)` is triggered from a View owned by a `Scene`, the matching destination must be declared in that same `Scene`.

## Views
- A View does not contain any business logic! If a View has business logic, it must have a ViewModel.
- If a View has a ViewModel, the View own's the ViewModel and creates it.
- All Views must have a Preview and this preview must be wrapped in #if DEBUG so that this code never reaches production/release.
- If a View is requested to be generated. Also check if there is a Views framework in the project, and if so this View should be created in this framework. Also if there is a Views folder then the views lives here. If neither of these exist, then the Views folder should be created in the project root where the App is located to keep files organised.
- All Views that contain form data where model can be edited, should have a save, reset and delete button. The save button must only be displayed when changes to the model have occurred, and if changes have occurred then the reset button should be made visible, so that the changes can be rolled back. The reset button should only appear on models that have already been peristed, and changes have been made. The delete button should only appear if this model has been persisted. When the delete button is tapped/pressed a confirmation window should always be presented with a Are you sure you want to delete this? and the user must have a chance to cancel or confirm. Then the model can be deleted. The view should then call dismiss() to tell the parent view that this view can be removed.
- Views actions that call view models methods should always take the responsibility of creating the concurrent isolated environment using Task, rather than the ViewModel.

## Navigation /Destination
- Any in-flow navigation action must use `NavigationLink(value:)` with a `Hashable` route value.
- Bubbling tap actions to parent views to mutate a bound navigation path is not allowed.
- Destinations must be controlled only in `Scene` views, via `.navigationDestination(for:)`.
- A `Scene` may define `NavigationStack` only when it is the navigation root for that flow (tab root, app root, or modal root).
- A destination pushed from a `Scene` must not create another `NavigationStack` in the same flow.
- Never nest `NavigationStack` inside another `NavigationStack` in the same runtime flow.

## Component
- All rules of Views should be followed first.
- If a Component is requested to be generated. Also check if there is a Components framework in the project, and if so this Component should be created in this framework. Also if there is a Components folder then the components lives here. If neither of these exist, then the Components folder should be created in the project root where the App is located to keep files organised.

## View Models
- If a View requires a ViewModel, the ViewModel is created and initialise in the View's init, and then set to a StateObject.
- If a ViewModel requires a service, or any dependencies. The View is responsible for having these dependencies pass to it, that then can be passed onto the ViewModel open creation.
- All ViewModels being created, should be created in their own line with `let vm = ViewModel()`and then assigned to the StateObject(wrapped: vm) rather than initialised in the StateObject.
- Methods requiring asynchronous work should be defined with async and or throws to pass the Task call onto the View to handle.
- Any context isolation questions that could cause static methods being created, should ask the question first can this pure function be extract to an extension on a data model, or must this code be a static method in this ViewModel.

## ObservableObject usage
- Since Xcode 26, Combine is not a part of the SwiftUI framework, which means all Combine declarations required the importing of Combine.

## Services / Stores
- All service / repo / stores that publish data must use AsyncStream as the public asynchronous stream.
- All services /repos /stores must be backed by a protocol and should attempt to always be Sendable. If this data structure as mutable state it must be an actor.
- If a Service is requested to be generated. Also check if there is a Services framework in the project, and if so this Service should be created in this framework. Also if there is a Services folder then the services lives here. If neither of these exist, then the Services folder should be created in the project root where the App is located to keep files organised.
- If a Store is requested to be generated. Also check if there is a Stores framework in the project, and if so this Store should be created in this framework. Also if there is a Stores folder then the stores lives here. If neither of these exist, then the Stores folder should be created in the project root where the App is located to keep files organised.

## Tasks
- All usage of Tasks should always include a Task.isCancelled if there is a chance that the code being executed within the Task body will cause negative side affects.

## SwiftUI
- All body contents should outsource components to their own files as soon as the complexity of the body property increases.
- See rule about one data structure one file for sub components.
- All navigation destinations should be handled in a View with the Suffix Scene. A Scene does not contain any View logic apart from the usage of a NavigationStack. Its body should use the View name without the Scene suffix as the View content that does the work. A Scene does not require a ViewModel, unless totally required.

## Models
- If a Model is requested to be generated. Also check if there is a Models framework in the project, and if so this Model should be created in this framework. Also if there is a Models folder then the models lives here. If neither of these exist, then the Models folder should be created in the project root where the App is located to keep files organised.

## High Level
- Tests should only be generated when explicitly requested. When requested, focus tests on service and view model logic.
- No force unwraps or force casts in production code unless explicitly justified.
- Explicit access control is required for all types and members.
- Concurrency safety by default. Cross-task types should conform to Sendable, or use @unchecked Sendable only with justification.
- MainActor isolation policy. UI-facing state mutations must be @MainActor and non-UI work should stay off the main thread.
- Dependency injection over singletons. Services should be passed by initializer through protocols.
- If a project has more than 3 services, a ServiceContainer protocol and implementation is required, and this container should be passed through initializers to reduce parameter count.
- Service dependencies must always be referenced via protocols.
- ServiceContainer usage is required in Scenes and the Views owned by those Scenes; Components should not receive the ServiceContainer directly.
- If a Component requires more than 3 parameters, define and pass a dedicated ComponentContainer protocol for that Component.
- Deterministic formatting and linting gate in CI.
- No warning policy. Compiler warnings should fail CI.
- Documentation required for all public APIs.
- Feature-level module boundaries should be respected.
- Availability and deprecation checks should run in CI and fail when deprecated APIs are introduced for supported targets.
- Performance budget checks for hot paths with regression thresholds enforced in CI.

## Summary
- No task is complete until a documented rule-by-rule compliance check is passed.

## Final Summary
- No task is complete until a documented rule-by-rule compliance check is passed.
