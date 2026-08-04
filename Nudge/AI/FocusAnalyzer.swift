import Foundation


class FocusAnalyzer {


    private let ollama = OllamaClient()

    private let parser = DecisionParser()


    /// One LLM call: classifies a single app the current policy doesn't
    /// already know about.
    func classify(
        goal: String,
        app: String,
        model: String
    ) async throws -> FocusDecision {


        let prompt =
            PromptBuilder.classificationPrompt(
                goal: goal,
                app: app
            )


        do {

            let payload =
                try await ollama.generate(
                    prompt: prompt,
                    model: model,
                    schema: DecisionParser.classificationSchema,
                    as: DecisionParser.ClassificationPayload.self
                )


            return parser.map(payload, source: .model)

        } catch let OllamaError.malformedResponse(raw, _) {


            return parser.parseText(raw, source: .fallback)

        }

    }


    /// One LLM call: expands a goal into an allow/block policy.
    func buildPolicy(
        goal: String,
        model: String
    ) async throws -> FocusPolicy {


        let prompt =
            PromptBuilder.policyExpansionPrompt(goal: goal)


        let payload =
            try await ollama.generate(
                prompt: prompt,
                model: model,
                schema: DecisionParser.policySchema,
                as: DecisionParser.PolicyPayload.self
            )


        return parser.map(payload, goal: goal)

    }

}
