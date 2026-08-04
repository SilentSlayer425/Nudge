//
//  NotificationService.swift
//  Nudge
//
//  Created by Sai on 7/31/26.
//

import Foundation
import UserNotifications


@MainActor
final class NotificationService {


    static let shared = NotificationService()


    private var hasRequestedAuthorization = false

    private var isAuthorized = false

    private var lastDistractionNotificationDate: Date?

    private let minimumDistractionInterval: TimeInterval = 60



    private init() {}



    func requestAuthorization() async -> Bool {

        if hasRequestedAuthorization {

            return isAuthorized

        }


        hasRequestedAuthorization = true


        do {

            isAuthorized = try await UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .sound])

        }
        catch {

            isAuthorized = false

        }


        return isAuthorized

    }



    func notifyDistracted(goal: String, app: String, reason: String) async {

        guard await ensureAuthorized() else {

            return

        }


        if let last = lastDistractionNotificationDate,
           Date().timeIntervalSince(last) < minimumDistractionInterval {

            return

        }


        lastDistractionNotificationDate = Date()


        let content = UNMutableNotificationContent()

        content.title = "Off track: \(goal)"

        content.body = "\(app) — \(reason)"

        content.sound = .default


        await deliver(content)

    }



    func notifySessionComplete(goal: String, duration: TimeInterval) async {

        guard await ensureAuthorized() else {

            return

        }


        let content = UNMutableNotificationContent()

        content.title = "Session complete"

        content.body = "\(goal) — \(formatted(duration)) focused"

        content.sound = .default


        await deliver(content)

    }



    private func ensureAuthorized() async -> Bool {

        if hasRequestedAuthorization {

            return isAuthorized

        }


        return await requestAuthorization()

    }



    private func deliver(_ content: UNMutableNotificationContent) async {

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )


        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )


        do {

            try await UNUserNotificationCenter.current().add(request)

        }
        catch {

            // Delivery failure is not actionable here — fail silently.

        }

    }



    private func formatted(_ duration: TimeInterval) -> String {

        let totalMinutes = Int(duration) / 60


        if totalMinutes < 60 {

            return "\(totalMinutes) min"

        }


        let hours = totalMinutes / 60

        let minutes = totalMinutes % 60


        return "\(hours)h \(minutes)m"

    }

}
