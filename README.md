# Nudge

Nudge is a native SwiftUI focus companion for macOS. Start a session with a goal, and Nudge monitors the frontmost application, mouse-idle time, power state, and lock/sleep state. At scheduled intervals it uses a local Ollama model to determine whether the current app supports the goal, records the result locally, and can notify you when you are off track.

> **Status:** working early release. Automatic focus checks, adaptive scheduling, local history, notifications, and structured local-AI decisions are implemented. A settings screen, automated tests, a release pipeline, and vision/screenshot analysis are not yet implemented.

## How it works

1. Enter a goal in the main window or menu bar and start a session.
2. Nudge immediately creates a goal-specific focus policy with a local Ollama model. The policy lists likely on-task and distracting macOS apps and is cached locally for that normalized goal.
3. A timer triggers a check every five minutes by default. Known apps are evaluated locally from the policy; an unknown app gets one structured local-model classification and is then learned into the policy cache.
4. A focused result increases the next interval, up to 15 minutes. A distracted result resets it to five minutes, records history, and may send a rate-limited notification.
5. Ending a session saves its duration to local history, sends a completion notification when authorized, and clears the resumable-session state.

## Current features

### Sessions, state, and scheduling

- The app has a main window and a menu-bar extra. Both can start or end a session; the menu-bar icon reflects the current state.
- A running session persists its goal, start time, and running flag in `UserDefaults`, then restores on next launch.
- `Scheduler` runs a one-second timer that fires real checks at the configured interval. Default minimum and maximum intervals are 300 and 900 seconds.
- State precedence is: AI evaluation in progress (`checking`) → low non-charging battery (`standby`) → over five minutes mouse idle (`idle`) → most recent non-fallback AI verdict → `focused`.
- The active-session view displays the current goal, elapsed time, next check, latest verdict, and system state.

### Local AI focus decisions

- All AI traffic goes to the local Ollama API at `http://127.0.0.1:11434`; there is no cloud AI endpoint in the app.
- The default model is configurable in `UserDefaults` and currently defaults to `qwen3.5:4b`.
- Policy generation and unknown-app classification request JSON schema-conforming output, then map it to app models with confidence and reasoning.
- A known policy match is a 100%-confidence local decision. Unknown apps are classified once and then added to the allow or block set for that goal.
- If Ollama cannot be reached, the check is recorded as `unknown` with a fallback decision; Nudge does not treat it as either focused or distracted and leaves the interval unchanged.

### Device context, privacy, and notifications

- `ActivityMonitor` checks the frontmost app and mouse-idle time every five seconds.
- `BatteryMonitor` reads charging/percentage at startup, every 30 seconds during a session, and from IOKit power-source change notifications.
- Checks are skipped when the Mac is asleep or locked, or when battery is below 15%. Battery below 15% while not charging also puts the UI in standby.
- `DeviceStateMonitor` responds to screen lock/unlock and Mac sleep/wake notifications.
- Nudge requests macOS notification authorization at session start. It can post a distraction notification no more often than once a minute and a completion notification when a session ends.
- A manual test screen capture is available. There is also a JPEG capture helper for future vision-model work, but screenshots are not currently sent to Ollama.

### Local history

- Each non-skipped check is stored with its date, app, status, confidence, and reason.
- Completed-session count and total duration are stored alongside the checks in `~/Library/Application Support/Nudge/history.json`.
- The goal-entry screen calculates completed sessions, focus accuracy, and total focus time from that file. Up to 1,000 checks are retained.

## Requirements

- macOS 26.5 or later, matching the project’s deployment target.
- Xcode with Swift 5 support to build from source.
- A running Ollama server and the selected model (the default is `qwen3.5:4b`) for policy generation and unknown-app decisions.
- Screen Recording permission only when using the screenshot test or future JPEG capture.
- Notification permission for distraction and completion alerts.

## Run locally

1. Open [Nudge.xcodeproj](Nudge/Nudge.xcodeproj) in Xcode.
2. Select the **Nudge** scheme and a **My Mac** destination.
3. Build and run.
4. For AI checks, install/start Ollama and pull the configured model, for example: `ollama pull qwen3.5:4b`.
5. Start a session. The first local policy build may take a moment; subsequent checks avoid a model call for apps already in the policy.

## Current project tree

The tree lists project-owned text/source/resources and omits Finder metadata and per-user Xcode state (`xcuserdata`). The existing folder name `Componets` is preserved exactly as it appears in the project.

```text
Nudge/
├── Nudge-README.md
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
    │   ├── ContextManager.swift
    │   ├── HistoryStore.swift
    │   ├── Scheduler.swift
    │   ├── SessionManager.swift
    │   └── SettingsManager.swift
    ├── Models/
    │   ├── FocusCheck.swift
    │   ├── FocusContext.swift
    │   ├── FocusDecision.swift
    │   ├── FocusPolicy.swift
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
    │   ├── NotificationService.swift
    │   └── ScreenCaptureService.swift
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

### Root, app resources, and project configuration

| Path | Purpose |
| --- | --- |
| `Nudge-README.md` | This project overview, setup guide, feature inventory, and file map. |
| `Nudge/readme.md` | Older minimal project README retained inside the Xcode project folder. |
| `Nudge/Nudge.xcodeproj` | Xcode project container. |
| `Nudge/Nudge.xcodeproj/project.pbxproj` | Target membership, build settings, automatic signing configuration, version `1.0`/build `1`, deployment target, and source build phases. Hardened Runtime is enabled and App Sandbox is disabled. |
| `Nudge/Nudge.xcodeproj/project.xcworkspace/contents.xcworkspacedata` | Workspace descriptor used by Xcode. |
| `Nudge/Nudge` | Files copied/compiled into the app bundle. |
| `Nudge/Nudge/Info.plist` | Explicit App Transport Security configuration. |
| `Nudge/Nudge/Assets.xcassets` | Xcode asset catalog. |
| `Nudge/Nudge/Assets.xcassets/Contents.json` | Asset-catalog metadata. |
| `Nudge/Nudge/Assets.xcassets/AccentColor.colorset/Contents.json` | Accent-color asset definition. |
| `Nudge/Nudge/Assets.xcassets/AppIcon.appiconset/Contents.json` | Declares macOS icon slots; no image files are currently included in the repository. |

### `AI` — policy building and local Ollama integration

| File | Purpose |
| --- | --- |
| `AIManager.swift` | Main actor coordinator. Builds/caches per-goal policies, evaluates current apps, learns unknown apps, and produces safe fallback decisions if Ollama is unavailable. |
| `DecisionParser.swift` | Defines structured-output schemas/payloads, maps them to domain models, normalizes app names, and has defensive free-text fallback parsing. |
| `FocusAnalyzer.swift` | Issues the two model jobs: policy expansion and one-app classification. |
| `ModelRouter.swift` | Centralizes job-to-model selection; both current jobs use the user-configured model. |
| `OllamaClient.swift` | Typed local HTTP client for Ollama `/api/generate`, with a 30-second timeout, JSON-schema output, error mapping, and 30-minute model keep-alive. |
| `PromptBuilder.swift` | Constructs detailed prompts for goal policy expansion and conservative unknown-app classification. |

### `App` — application entry and root navigation

| File | Purpose |
| --- | --- |
| `NudgeApp.swift` | `@main` SwiftUI app. Creates the shared session manager and exposes the main window plus menu-bar extra. |
| `ContentView.swift` | Routes between goal entry and active session based on session state. |

### `Managers` — lifecycle, persistence, and orchestration

| File | Purpose |
| --- | --- |
| `ContextManager.swift` | Owns monitor services and assembles their latest values into a `FocusContext`. |
| `HistoryStore.swift` | Main-actor singleton that persists checks, completed-session count, and focus time to Application Support; calculates focus accuracy and retains 1,000 checks. |
| `Scheduler.swift` | Owns the repeating timer, next-check date, callback, and adaptive minimum/maximum check interval. |
| `SessionManager.swift` | Central session state machine. Starts/stops services, persists the resumable session, invokes AI checks, applies results, schedules future checks, records history, and triggers notifications. |
| `SettingsManager.swift` | Main-actor `UserDefaults` settings store for model, notification flag, screenshot flag, and min/max check intervals. No settings UI consumes it yet. |

### `Models` — domain data types

| File | Purpose |
| --- | --- |
| `FocusCheck.swift` | Codable/identifiable local history record: status, confidence, app, reason, date, and ID. Also supplies `FocusStatus` Codable/Equatable conformances. |
| `FocusContext.swift` | Snapshot of a goal, frontmost app, idle/battery/charging values, and timestamp. |
| `FocusDecision.swift` | Codable AI/policy/fallback decision with `focused`, confidence, reason, and source. |
| `FocusPolicy.swift` | Codable per-goal normalized allow/block app sets; classifies an app and learns a new decision. |
| `FocusStatus.swift` | Three history statuses: `onTask`, `distracted`, and `unknown`. |
| `Goal.swift` | Active goal with UUID, title, and creation date. |
| `NudgeState.swift` | UI states (`idle`, `focused`, `checking`, `distracted`, `standby`) and their SF Symbol icons. |
| `SavedSession.swift` | Codable `UserDefaults` representation of a resumable session. |

### `Services` — macOS integration points

| File | Purpose |
| --- | --- |
| `ActivityMonitor.swift` | Periodically reads the frontmost `NSWorkspace` app and mouse-idle duration. |
| `BatteryMonitor.swift` | Reads IOKit power sources and monitors battery changes during a session. |
| `CheckPermissionManager.swift` | Makes the check gate decision and explains why it is allowed or blocked. |
| `DeviceStateMonitor.swift` | Observes lock/unlock and sleep/wake notifications, and removes its observers on deinitialization. |
| `NotificationService.swift` | Requests notification permission and delivers distraction/completion notifications; distraction delivery is rate limited to one minute. |
| `ScreenCaptureService.swift` | Captures the first display for test preview and can return a downscaled, compressed JPEG for future vision analysis. |

### `Views` — SwiftUI screens and reusable presentation

| File | Purpose |
| --- | --- |
| `ActiveSessionView.swift` | Main running-session dashboard: timing, system context, latest focus decision, manual screenshot test/preview, and stop action. |
| `GoalEntryView.swift` | Goal input/start screen and local-history statistics display. |
| `MenuBarView.swift` | Menu-bar wrapper displaying status, battery, and activity. |
| `Views/Componets/InfoRow.swift` | Reusable title/value detail row. |
| `Views/Componets/MenuBarStatusView.swift` | Menu-bar controls: start/end session, current goal/state/timer/next check, open app, disabled settings placeholder, and quit. |
| `Views/Componets/PrimaryButton.swift` | Reusable primary/destructive `ButtonStyle`. |
| `Views/Componets/SectionHeader.swift` | Reusable semibold section title. |
| `Views/Componets/StatusBadge.swift` | Label with a colored circular status indicator. |
| `Views/Componets/TimerView.swift` | Displays a duration as `MM:SS` or `HH:MM:SS`. |

## Known limitations

- There is no settings screen, even though `SettingsManager` persists configuration values.
- `useScreenshots` is stored but not read; screen capture remains manual/test-only and no screenshot is sent to a model.
- The raw context contains idle time and battery values, but current model prompts evaluate the goal and frontmost app only.
- AI policy/decision cache uses `UserDefaults` and does not expire or expose a way to clear individual policies.
- The project currently has no test target, release automation, packaged `.dmg`, or populated app-icon images.
- Direct GitHub distribution should use a Developer ID-signed and notarized build; a locally built unsigned `.app` is appropriate only for development/testing.

## Privacy and local data

Nudge’s AI client targets only local Ollama. Policy-generation requests send the goal; unknown-app classification requests send the goal and frontmost application name. The current app does not send screenshots, idle time, battery values, history, or session data to the model. Session/policy settings are stored in `UserDefaults`; history is stored in the user’s Application Support folder; test screenshots remain in memory as `latestScreenshot` during the process.

## Releasing a `.dmg` on GitHub

Before publishing, create a **Developer ID Application** certificate in the Apple Developer account used by this project. The project already enables Hardened Runtime, which notarization needs; set the release signing identity to that Developer ID certificate and make sure the bundle ID and version/build numbers are final.

The friendliest first release workflow is Xcode’s **Product → Archive**, then **Window → Organizer → Distribute App → Developer ID → Upload**. Let Xcode sign and notarize the archive, then export the notarized app. Create a drag-and-drop DMG containing that exported `.app`, validate it on another Mac, and attach it to a GitHub Release using a version tag such as `v1.0.0`.

For automation, the equivalent stages are: archive the Release build; export it with Developer ID signing; create the DMG with `hdiutil`; submit it using `xcrun notarytool submit ... --wait`; staple the result with `xcrun stapler staple`; verify it with `spctl --assess`; then upload the DMG and a SHA-256 checksum as GitHub Release assets. Do not publish the DMG until notarization and verification pass.
