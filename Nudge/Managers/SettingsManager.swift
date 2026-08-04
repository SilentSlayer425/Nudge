//
//  SettingsManager.swift
//  Nudge
//
//  Created by Sai on 7/31/26.
//

import Foundation
import Combine


@MainActor
final class SettingsManager: ObservableObject {


    static let shared = SettingsManager()


    private let defaults = UserDefaults.standard


    private enum Keys {

        static let model = "settings.model"

        static let notificationsEnabled = "settings.notificationsEnabled"

        static let useScreenshots = "settings.useScreenshots"

        static let minIntervalSeconds = "settings.minIntervalSeconds"

        static let maxIntervalSeconds = "settings.maxIntervalSeconds"

    }


    @Published var model: String {

        didSet {

            defaults.set(model, forKey: Keys.model)

        }

    }


    @Published var notificationsEnabled: Bool {

        didSet {

            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)

        }

    }


    @Published var useScreenshots: Bool {

        didSet {

            defaults.set(useScreenshots, forKey: Keys.useScreenshots)

        }

    }


    @Published var minIntervalSeconds: TimeInterval {

        didSet {

            defaults.set(minIntervalSeconds, forKey: Keys.minIntervalSeconds)

        }

    }


    @Published var maxIntervalSeconds: TimeInterval {

        didSet {

            defaults.set(maxIntervalSeconds, forKey: Keys.maxIntervalSeconds)

        }

    }


    private init() {


        self.model =
            defaults.string(forKey: Keys.model)
            ?? "qwen3.5:4b"


        self.notificationsEnabled =
            defaults.object(forKey: Keys.notificationsEnabled) as? Bool
            ?? true


        self.useScreenshots =
            defaults.object(forKey: Keys.useScreenshots) as? Bool
            ?? false


        self.minIntervalSeconds =
            defaults.object(forKey: Keys.minIntervalSeconds) as? TimeInterval
            ?? 300


        self.maxIntervalSeconds =
            defaults.object(forKey: Keys.maxIntervalSeconds) as? TimeInterval
            ?? 900

    }

}
