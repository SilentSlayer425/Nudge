import Foundation


enum DecisionSource: String, Codable {

    case policy

    case model

    case fallback

}


struct FocusDecision: Codable, Equatable {


    let focused: Bool

    let confidence: Int

    let reason: String

    let source: DecisionSource

}
