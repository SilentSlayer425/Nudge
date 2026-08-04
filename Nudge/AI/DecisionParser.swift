import Foundation


/// Thin mapping layer from decoded Ollama structured output into the app's
/// domain types. The regex-based free-text parsing that used to live here is
/// kept only as a defensive fallback for a model that ignores `format`.
class DecisionParser {


    struct ClassificationPayload: Decodable {

        let reasoning: String

        let focused: Bool

        let confidence: Int

    }


    struct PolicyPayload: Decodable {

        let reasoning: String

        let allow: [String]

        let block: [String]

    }


    /// `reasoning` is listed first — JSON Schema property order guides the
    /// model's generation order, which is how reasoning ends up before the
    /// verdict instead of after it.
    static let classificationSchema: [String: Any] = [

        "type": "object",

        "properties": [

            "reasoning": ["type": "string"],

            "focused": ["type": "boolean"],

            "confidence": ["type": "integer"]

        ],

        "required": ["reasoning", "focused", "confidence"]

    ]


    static let policySchema: [String: Any] = [

        "type": "object",

        "properties": [

            "reasoning": ["type": "string"],

            "allow": [

                "type": "array",

                "items": ["type": "string"]

            ],

            "block": [

                "type": "array",

                "items": ["type": "string"]

            ]

        ],

        "required": ["reasoning", "allow", "block"]

    ]


    func map(
        _ payload: ClassificationPayload,
        source: DecisionSource
    ) -> FocusDecision {


        FocusDecision(

            focused: payload.focused,

            confidence: min(max(payload.confidence, 0), 100),

            reason: payload.reasoning,

            source: source

        )

    }


    func map(
        _ payload: PolicyPayload,
        goal: String
    ) -> FocusPolicy {


        FocusPolicy(

            goal: goal,

            allow: Set(payload.allow.map(Self.normalize)),

            block: Set(payload.block.map(Self.normalize))

        )

    }


    private nonisolated static func normalize(_ app: String) -> String {

        app
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

    }


    /// Defensive fallback for a model that ignored `format` and returned
    /// free text instead of schema-conforming JSON.
    func parseText(
        _ response: String,
        source: DecisionSource
    ) -> FocusDecision {


        let lower = response.lowercased()


        let focused =
            lower.contains("\"focused\": true")
            || lower.contains("\"focused\":true")
            || lower.contains("focused: true")


        var confidence = 50


        if let range = lower.range(of: "confidence") {

            let after = lower[range.upperBound...]

            let digits =
                after
                .drop { !$0.isNumber }
                .prefix { $0.isNumber }

            if let parsed = Int(digits) {

                confidence = parsed

            }

        }


        return FocusDecision(

            focused: focused,

            confidence: min(max(confidence, 0), 100),

            reason: response.trimmingCharacters(in: .whitespacesAndNewlines),

            source: source

        )

    }

}
