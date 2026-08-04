# Nudge

Nudge is a native macOS focus-session companion. You enter a goal, start a timed session, and Nudge collects lightweight local context—such as the frontmost app, mouse-idle time, battery state, and device lock/sleep state. It can send that context to a local Ollama model to assess whether you are working toward the goal.

> **Project status:** early prototype. The user interface and most monitoring services are present, but automatic AI checks, notifications, session statistics, and several decision-model types are not yet connected into a complete focus-check workflow.

## What is implemented

### Focus sessions

- A goal-entry screen accepts a non-empty goal and starts a focus session.
- The active-session screen shows the goal, a live elapsed timer, the next scheduled check, and system/context status.
- Session state is saved in `UserDefaults` as the goal, start date, and running flag. A running session is restored when the app launches again.
- Ending a session stops the timer and scheduler, clears the active goal, and removes the saved session.
- The app provides both a standard window and a menu-bar extra whose icon follows the current app state.

### Activity and device context

- `ActivityMonitor` samples the frontmost macOS application and mouse-idle duration every five seconds.
- `BatteryMonitor` reads the current power-source capacity and charging state using IOKit.
- `DeviceStateMonitor` observes screen lock/unlock and Mac sleep/wake notifications.
- `CheckPermissionManager` reports whether a check may run. Checks are disallowed while the Mac is locked or sleeping, or when battery level is below 15%.
- `ContextManager` packages the active goal, current app, idle time, battery level, charging state, and timestamp as `FocusContext`.

### Scheduling and states

- Sessions initially schedule their next check for five minutes after start.
- The scheduler can gradually extend the interval to a maximum of 15 minutes after a focused result, or reset it to five minutes after a distracted result.
- The displayed app state becomes `standby` below 15% battery while not charging, `idle` after five minutes of mouse inactivity, and `focused` otherwise.
- The active screen and menu-bar view show battery, activity, device state, and the permission-check status.

### Local AI and screen capture

- `FocusAnalyzer` builds a prompt from `FocusContext` and sends it to a local Ollama server.
- `OllamaClient` calls `http://localhost:11434/api/generate` using the default model `qwen3:0.6b`, with streaming and model thinking disabled.
- The active-session UI includes a **Test AI** button that prints the model response to Xcode’s console.
- `ScreenCaptureService` uses ScreenCaptureKit to capture the first available display. The active-session UI includes a test button and previews the most recent screenshot.

## Current app flow

1. Launch Nudge and enter the outcome you want to focus on.
2. Start a session. Nudge begins the elapsed-time timer, activity monitoring, context creation, and five-minute schedule.
3. Review goal, timing, current app, activity, battery, device, and check-status information in the active session window or menu bar.
4. Optionally use **Test AI** after Ollama is running, or **Capture Test Screenshot** after granting macOS screen-recording permission.
5. End the session to clear its saved state.

## Requirements

- macOS 26.5 or later (the project’s current deployment target).
- Xcode with Swift 5 support.
- Ollama only if you plan to use local AI analysis. Install a model named `qwen3:0.6b` and make sure the Ollama service is available at `localhost:11434`.
- macOS Screen Recording permission to use screen capture. macOS may also request the relevant local-network/permission approvals for the app and Ollama setup.

## Run locally

1. Open [Nudge.xcodeproj](Nudge/Nudge.xcodeproj) in Xcode.
2. Choose the **Nudge** scheme and a My Mac destination.
3. Build and run the app.
4. For local AI testing, start Ollama and pull the configured model before selecting **Test AI**.

## Project structure

| Area | Responsibility |
| --- | --- |
| `Nudge/App` | App entry point and root view routing between goal entry and active session. |
| `Nudge/Views` | SwiftUI screens, menu-bar UI, and reusable visual components. |
| `Nudge/Managers` | Session lifecycle, local persistence, context assembly, and scheduling. |
| `Nudge/Services` | Activity, battery, lock/sleep, permission gating, notification, and screen-capture services. |
| `Nudge/AI` | Ollama client and focus-analysis prompt flow. |
| `Nudge/Models` | Goal, saved session, focus context/decision, and focus-state model types. |

## Current file tree

The tree below lists the project-owned source and resource files as of this README update. It intentionally omits per-user Xcode workspace state (`xcuserdata`) and Finder metadata (`.DS_Store`).

```text
Nudge/
├── readme.md
└── Nudge/
    ├── AI/
    │   ├── AIManager.swift
    │   ├── DecisionParser.swift
    │   ├── FocusAnalyzer.swift
    │   ├── ModelRouter.swift
    │   ├── OllamaClient.swift
    │   └── PromptBuilder.swift
    ├── App/
    │   ├── ContentView.swift
    │   └── NudgeApp.swift
    ├── Managers/
    │   ├── ActivityManager.swift
    │   ├── ContextManager.swift
    │   ├── Scheduler.swift
    │   ├── SessionManager.swift
    │   └── SettingsManager.swift
    ├── Models/
    │   ├── FocusCheck.swift
    │   ├── FocusContext.swift
    │   ├── FocusDecision.swift
    │   ├── FocusStatus.swift
    │   ├── Goal.swift
    │   ├── NudgeState.swift
    │   └── SavedSession.swift
    ├── Nudge/
    │   ├── Assets.xcassets/
    │   │   ├── AccentColor.colorset/Contents.json
    │   │   ├── AppIcon.appiconset/Contents.json
    │   │   └── Contents.json
    │   └── Info.plist
    ├── Nudge.xcodeproj/
    │   ├── project.pbxproj
    │   └── project.xcworkspace/contents.xcworkspacedata
    ├── Services/
    │   ├── ActivityMonitor.swift
    │   ├── BatteryMonitor.swift
    │   ├── CheckPermissionManager.swift
    │   ├── DeviceStateMonitor.swift
    │   ├── FocusScheduler.swift
    │   ├── NotificationService.swift
    │   ├── ScreenCaptureService.swift
    │   ├── SleepMonitor.swift
    │   └── Untitled.swift
    └── Views/
        ├── Componets/
        │   ├── InfoRow.swift
        │   ├── MenuBarStatusView.swift
        │   ├── PrimaryButton.swift
        │   ├── SectionHeader.swift
        │   ├── StatusBadge.swift
        │   └── TimerView.swift
        ├── ActiveSessionView.swift
        ├── GoalEntryView.swift
        └── MenuBarView.swift
```

### Root, app resources, and Xcode project

| Path | What it holds / does |
| --- | --- |
| `readme.md` | Project overview, setup notes, implementation status, and this file guide. |
| `Nudge/Nudge.xcodeproj` | Xcode project container: build configuration, target membership, and workspace metadata. |
| `Nudge/Nudge.xcodeproj/project.pbxproj` | The project’s primary Xcode configuration, including build phases, source-file membership, bundle identifier, and deployment target. |
| `Nudge/Nudge.xcodeproj/project.xcworkspace/contents.xcworkspacedata` | Minimal workspace descriptor Xcode uses to open the project context. |
| `Nudge/Nudge` | App-bundle resources: configuration and compiled asset-catalog inputs. |
| `Nudge/Nudge/Info.plist` | App property-list configuration, including App Transport Security settings. |
| `Nudge/Nudge/Assets.xcassets` | Asset catalog supplied to the app at build time. |
| `Nudge/Nudge/Assets.xcassets/Contents.json` | Asset catalog manifest. |
| `Nudge/Nudge/Assets.xcassets/AccentColor.colorset/Contents.json` | Accent-color asset definition. |
| `Nudge/Nudge/Assets.xcassets/AppIcon.appiconset/Contents.json` | App-icon set definition and image-slot metadata. |

### `AI` — local model integration

This folder is intended to contain the AI abstraction, prompts, routing, response parsing, and local-model client.

| File | What it does now |
| --- | --- |
| `AIManager.swift` | Empty scaffold reserved for a high-level AI coordinator. |
| `DecisionParser.swift` | Empty scaffold intended to parse model output into a `FocusDecision`. |
| `FocusAnalyzer.swift` | Builds a focus-assessment prompt from `FocusContext` and sends it to `OllamaClient`. |
| `ModelRouter.swift` | Empty scaffold reserved for selecting an AI model/provider. |
| `OllamaClient.swift` | Sends a non-streaming request to local Ollama (`localhost:11434`) using `qwen3:0.6b` by default, then returns the raw response text. |
| `PromptBuilder.swift` | Empty scaffold reserved for reusable prompt construction. |

### `App` — app composition and navigation

This folder contains the SwiftUI application entry point and root-level screen selection.

| File | What it does now |
| --- | --- |
| `NudgeApp.swift` | Defines the `@main` app, creates the shared `SessionManager`, injects it into the main window, and creates the menu-bar extra. |
| `ContentView.swift` | Switches between the goal-entry and active-session screens based on whether a session is running. |

### `Managers` — application state and orchestration

This folder is intended to own app-level lifecycles and coordinate services/models without putting that work directly in SwiftUI views.

| File | What it does now |
| --- | --- |
| `ActivityManager.swift` | Empty scaffold reserved for higher-level activity orchestration. |
| `ContextManager.swift` | Owns the monitor services and creates `FocusContext` from the active goal and current device/activity values. |
| `Scheduler.swift` | Stores and adjusts the next-check time: five minutes initially or after distraction, up to 15 minutes after focused results. |
| `SessionManager.swift` | Owns active-session state, elapsed-time timer, persistence to `UserDefaults`, start/stop behavior, scheduling, and current app state. |
| `SettingsManager.swift` | Empty scaffold reserved for user preferences. |

### `Models` — small, shareable data types

This folder holds the value types and enums exchanged by views, managers, services, and future AI logic.

| File | What it does now |
| --- | --- |
| `FocusCheck.swift` | Defines one potential focus-check record: date, `FocusStatus`, and confidence. It is not yet persisted or displayed. |
| `FocusContext.swift` | Defines the prompt context: goal, active application, idle time, battery level, charging state, and timestamp. |
| `FocusDecision.swift` | Codable model for a parsed AI decision: focused/not focused, integer confidence, and reason. |
| `FocusStatus.swift` | Defines `onTask`, `distracted`, and `unknown` focus-check statuses. |
| `Goal.swift` | Identifiable active goal with title and creation date. |
| `NudgeState.swift` | Defines app states (`idle`, `focused`, `checking`, `distracted`, `standby`) and their SF Symbol names. |
| `SavedSession.swift` | Codable subset of a session persisted across launches: goal title, start date, and running flag. |

### `Services` — macOS and system integrations

This folder is for focused integrations with macOS frameworks and background monitoring work.

| File | What it does now |
| --- | --- |
| `ActivityMonitor.swift` | Every five seconds reads the frontmost app and mouse-idle duration. |
| `BatteryMonitor.swift` | Reads power-source charge percentage and charging state through IOKit when initialized or explicitly updated. |
| `CheckPermissionManager.swift` | Determines whether a focus check is allowed and exposes a human-readable reason; blocks checks while locked, sleeping, or below 15% battery. |
| `DeviceStateMonitor.swift` | Observes screen lock/unlock and Mac sleep/wake notifications; exposes current lock and sleep state. |
| `FocusScheduler.swift` | Unused duplicate scheduling scaffold with the same five-to-fifteen-minute interval logic as `Managers/Scheduler.swift`. |
| `NotificationService.swift` | Empty scaffold reserved for macOS notification delivery. |
| `ScreenCaptureService.swift` | Captures the first available display with ScreenCaptureKit and retains the latest screenshot for the UI preview. |
| `SleepMonitor.swift` | Empty scaffold reserved for sleep-state monitoring. |
| `Untitled.swift` | Empty placeholder file with no current behavior. |

### `Views` — SwiftUI interface

This folder holds the main screens and reusable SwiftUI presentation components. The existing subfolder is named `Componets` in the project (the spelling is preserved in the tree and imports).

| File | What it does now |
| --- | --- |
| `ActiveSessionView.swift` | Shows the current goal, timer, next check, system/context rows, test-AI action, screenshot test/preview, and end-session button. |
| `GoalEntryView.swift` | Presents goal input and start-session action; its summary statistics are currently placeholders. |
| `MenuBarView.swift` | Top-level menu-bar content showing status, battery, and activity. |
| `Views/Componets/InfoRow.swift` | Reusable two-line label/value row for system information. |
| `Views/Componets/MenuBarStatusView.swift` | Menu-bar detail block showing current goal, session status/timer/next check, plus Open, Settings placeholder, and Quit actions. |
| `Views/Componets/PrimaryButton.swift` | Empty scaffold reserved for a shared button style/component. |
| `Views/Componets/SectionHeader.swift` | Reusable semibold section-title view. |
| `Views/Componets/StatusBadge.swift` | Reusable text label with a colored circular status indicator. |
| `Views/Componets/TimerView.swift` | Formats and displays elapsed session time as `MM:SS` or `HH:MM:SS`. |

## Known limitations and next work

- Scheduled checks currently only calculate and display the next-check time; they do not fire a capture, AI request, or notification automatically.
- The AI response is returned as raw text and is not yet parsed into `FocusDecision`, reflected in app state, or used to adapt the scheduler.
- Screen capture is manual/test-only and is not included in the AI prompt.
- The menu bar is status-only; it does not currently expose session controls.
- The goal-entry statistics are placeholders (`0` sessions and `--` for accuracy/time).
- Battery state is read when `BatteryMonitor` is initialized, rather than continuously refreshed.
- `NotificationService`, `SleepMonitor`, `AIManager`, `ModelRouter`, `PromptBuilder`, `SettingsManager`, and `FocusScheduler` are currently scaffolds or not connected to the active flow.
- No automated tests or release/packaging workflow are currently included.

## Privacy

Nudge is designed around local context and a local Ollama endpoint. The current implementation sends only the textual goal, app name, idle time, and battery percentage included in the prompt to `localhost`; it does not transmit captured screenshots through the AI client. Screen captures remain in memory as the latest preview during the running app session.
