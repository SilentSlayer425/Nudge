import Foundation
import Combine


@MainActor
final class HistoryStore: ObservableObject {


    static let shared = HistoryStore()


    @Published private(set) var checks: [FocusCheck] = []

    @Published private(set) var completedSessions: Int = 0

    @Published private(set) var totalFocusTime: TimeInterval = 0


    private let maxRetainedChecks = 1000

    private let fileURL: URL


    private struct PersistedHistory: Codable {

        var checks: [FocusCheck]

        var completedSessions: Int

        var totalFocusTime: TimeInterval

    }



    private init() {

        let supportDirectory =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first


        let nudgeDirectory =
            (supportDirectory ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("Nudge", isDirectory: true)


        try? FileManager.default.createDirectory(
            at: nudgeDirectory,
            withIntermediateDirectories: true
        )


        fileURL =
            nudgeDirectory.appendingPathComponent("history.json")


        load()

    }



    func record(_ check: FocusCheck) {

        checks.append(check)


        if checks.count > maxRetainedChecks {

            checks.removeFirst(checks.count - maxRetainedChecks)

        }


        save()

    }



    func recordSessionCompleted(duration: TimeInterval) {

        completedSessions += 1

        totalFocusTime += duration

        save()

    }



    /// Share of checks with status == .onTask, over checks that aren't
    /// .unknown. nil when there is nothing to average yet.
    var focusAccuracy: Double? {

        let scored =
            checks.filter { $0.status != .unknown }


        guard !scored.isEmpty else {

            return nil

        }


        let onTask =
            scored.filter { $0.status == .onTask }.count


        return Double(onTask) / Double(scored.count)

    }



    func clearHistory() {

        checks = []

        completedSessions = 0

        totalFocusTime = 0

        save()

    }



    private func load() {

        guard let data =
                try? Data(contentsOf: fileURL)
        else {

            return

        }


        guard let decoded =
                try? JSONDecoder().decode(
                    PersistedHistory.self,
                    from: data
                )
        else {

            return

        }


        checks = decoded.checks

        completedSessions = decoded.completedSessions

        totalFocusTime = decoded.totalFocusTime

    }



    private func save() {

        let snapshot =
            PersistedHistory(
                checks: checks,
                completedSessions: completedSessions,
                totalFocusTime: totalFocusTime
            )


        guard let data =
                try? JSONEncoder().encode(snapshot)
        else {

            return

        }


        try? data.write(
            to: fileURL,
            options: .atomic
        )

    }

}
