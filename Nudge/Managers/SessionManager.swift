import Foundation
import Combine


@MainActor
class SessionManager: ObservableObject {

    let scheduler = Scheduler()
    @Published var contextManager = ContextManager()
    let aiManager = AIManager()
    @Published var currentGoal: Goal?
    @Published var isRunning = false
    @Published var appState: NudgeState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var lastDecision: FocusDecision?


    private var timer: Timer?

    private var startDate: Date?

    private var lastVerdictState: NudgeState?
    private var lastVerdictDate: Date?

    private let saveKey = "savedSession"


    init() {

        scheduler.onCheck = { [weak self] in

            Task { @MainActor in

                self?.performCheck()

            }

        }

        loadSession()
    }


    func start(goal: String) {

        currentGoal = Goal(title: goal)

        isRunning = true

        appState = .focused

        startDate = Date()

        elapsedTime = 0

        lastVerdictState = nil
        lastVerdictDate = nil
        lastDecision = nil

        contextManager.activityMonitor.update()

        contextManager.update(
            goal: currentGoal
        )

        saveSession()

        scheduler.start(
            minSeconds: SettingsManager.shared.minIntervalSeconds,
            maxSeconds: SettingsManager.shared.maxIntervalSeconds
        )

        contextManager.batteryMonitor.startMonitoring()

        startTimer()

        Task {

            _ = await NotificationService.shared.requestAuthorization()

            do {

                _ = try await aiManager.buildPolicy(goal: goal)

            } catch {

                // Policy will be built lazily on the first `evaluate` call instead.

            }

        }
    }


    func stop() {

        isRunning = false
        appState = .idle

        timer?.invalidate()
        timer = nil
        scheduler.stop()
        contextManager.batteryMonitor.stopMonitoring()

        let goal = currentGoal
        let duration = elapsedTime

        aiManager.reset()

        if let goal {

            HistoryStore.shared.recordSessionCompleted(duration: duration)

            Task {

                await NotificationService.shared.notifySessionComplete(
                    goal: goal.title,
                    duration: duration
                )

            }

        }

        currentGoal = nil
        startDate = nil
        elapsedTime = 0
        lastVerdictState = nil
        lastVerdictDate = nil
        lastDecision = nil

        clearSavedSession()
    }


    private func startTimer() {

        timer?.invalidate()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in

            guard let self else { return }

            Task { @MainActor in

                self.updateElapsedTime()
                self.updateAppState()

            }

        }
    }


    /// Precedence, highest first: battery standby > idle (mouse) > last AI
    /// verdict > default focused. The 1-second timer only ever owns the
    /// standby/idle transitions here — it must never overwrite a
    /// `.distracted`/`.focused` verdict that came from the AI, or that
    /// verdict would vanish within a second of being set.
    private func updateAppState() {

        if aiManager.isThinking {

            appState = .checking

            return

        }

        let battery = contextManager.batteryMonitor.batteryLevel
        let charging = contextManager.batteryMonitor.isCharging

        if battery < 15 && !charging {

            appState = .standby

            return

        }

        if contextManager.activityMonitor.idleTime > 300 {

            appState = .idle

            return

        }

        if let lastVerdictState {

            appState = lastVerdictState

            return

        }

        appState = .focused

    }


    private func performCheck() {

        guard let goal = currentGoal else {
            return
        }

        guard contextManager.checkPermissionManager.canRunCheck() else {

            return

        }

        contextManager.update(
            goal: goal
        )

        guard let context = contextManager.context else {

            return
        }

        Task {

            do {

                let decision = try await aiManager.evaluate(context: context)

                self.apply(decision: decision, application: context.currentApplication)

            }
            catch {

                // `AIManager.evaluate` only throws for programmer-error paths;
                // there's nothing useful to do besides skip this check.

            }

        }

    }


    private func apply(decision: FocusDecision, application: String) {

        lastDecision = decision

        let status: FocusStatus

        switch (decision.source, decision.focused) {

        case (.fallback, _):
            status = .unknown

        case (_, true):
            status = .onTask

        case (_, false):
            status = .distracted

        }

        if status != .unknown {

            lastVerdictState = decision.focused ? .focused : .distracted
            lastVerdictDate = Date()

        }

        updateAppState()

        HistoryStore.shared.record(

            FocusCheck(
                status: status,
                confidence: decision.confidence,
                application: application,
                reason: decision.reason
            )

        )

        switch status {

        case .distracted:

            scheduler.distracted()

            if SettingsManager.shared.notificationsEnabled {

                let goalTitle = currentGoal?.title ?? ""

                Task {

                    await NotificationService.shared.notifyDistracted(
                        goal: goalTitle,
                        app: application,
                        reason: decision.reason
                    )

                }

            }

        case .onTask:

            scheduler.focused()

        case .unknown:

            // No real verdict — leave the scheduler's interval as-is rather
            // than treating a fallback as either signal.
            break

        }

    }


    private func updateElapsedTime() {

        guard let startDate else {
            return
        }

        elapsedTime = Date().timeIntervalSince(startDate)
    }


    // MARK: Persistence


    private func saveSession() {

        guard let goal = currentGoal,
              let startDate else {
            return
        }


        let session = SavedSession(
            goalTitle: goal.title,
            startDate: startDate,
            isRunning: isRunning
        )


        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(
                data,
                forKey: saveKey
            )
        }
    }


    private func loadSession() {

        guard let data = UserDefaults.standard.data(
            forKey: saveKey
        )
        else {
            return
        }


        guard let session = try? JSONDecoder().decode(
            SavedSession.self,
            from: data
        )
        else {
            return
        }


        currentGoal = Goal(
            title: session.goalTitle
        )

        isRunning = session.isRunning

        startDate = session.startDate


        if isRunning {

            scheduler.start(
            minSeconds: SettingsManager.shared.minIntervalSeconds,
            maxSeconds: SettingsManager.shared.maxIntervalSeconds
        )

            contextManager.batteryMonitor.startMonitoring()

            updateElapsedTime()

            startTimer()

        }
    }


    private func clearSavedSession() {

        UserDefaults.standard.removeObject(
            forKey: saveKey
        )
    }
}
