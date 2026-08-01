import Foundation
import Combine


class SessionManager: ObservableObject {
    let scheduler = Scheduler()
    @Published var contextManager = ContextManager()
    @Published var currentGoal: Goal?
    @Published var isRunning = false
    @Published var appState: NudgeState = .idle
    @Published var elapsedTime: TimeInterval = 0
    
    
    private var timer: Timer?
    
    private var startDate: Date?
    
    private let saveKey = "savedSession"
    
    
    init() {
        loadSession()
    }
    
    
    func start(goal: String) {
        
        currentGoal = Goal(title: goal)
        scheduler.start()
        isRunning = true
        appState = .focused
        
        startDate = Date()
        elapsedTime = 0
        contextManager.activityMonitor.update()
        saveSession()
        scheduler.start()
        startTimer()
    }
    
    
    func stop() {
        
        isRunning = false
        appState = .idle
        
        timer?.invalidate()
        timer = nil
        scheduler.stop()
        currentGoal = nil
        startDate = nil
        elapsedTime = 0
        
        clearSavedSession()
    }
    
    
    private func startTimer() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in
            
            DispatchQueue.main.async {
                self.updateElapsedTime()
                self.updateAppState()
            }
        }
    }
    private func updateAppState() {


        let battery =
        contextManager.batteryMonitor.batteryLevel


        let charging =
        contextManager.batteryMonitor.isCharging



        if battery < 15 && !charging {

            appState = .standby

            return

        }



        if contextManager.activityMonitor.idleTime > 300 {

            appState = .idle

        }
        else {

            appState = .focused

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
