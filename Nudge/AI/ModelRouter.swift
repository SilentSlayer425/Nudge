//
//  ModelRouter.swift
//  Nudge
//
//  Created by Sai on 7/31/26.
//

import Foundation


enum AIJob {

    case policyExpansion

    case appClassification

}


@MainActor
enum ModelRouter {


    /// Picks the model for a given job. Both jobs currently share the
    /// user's configured model, but routing is centralized here so a future
    /// change (e.g. a cheaper model for classification) touches one place.
    static func model(for job: AIJob) -> String {

        switch job {

        case .policyExpansion:

            return SettingsManager.shared.model

        case .appClassification:

            return SettingsManager.shared.model

        }

    }

}
