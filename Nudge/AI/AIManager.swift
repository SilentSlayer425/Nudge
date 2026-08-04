import Foundation
import Combine


@MainActor
final class AIManager: ObservableObject {


    @Published private(set) var policy: FocusPolicy?

    @Published private(set) var isThinking: Bool = false


    private let analyzer = FocusAnalyzer()

    private let defaults = UserDefaults.standard


    /// One LLM call. Call this when a session starts.
    func buildPolicy(goal: String) async throws -> FocusPolicy {


        if let cached = Self.loadCachedPolicy(goal: goal, defaults: defaults) {

            policy = cached

            return cached

        }


        isThinking = true

        defer { isThinking = false }


        let model = ModelRouter.model(for: .policyExpansion)


        let built =
            try await analyzer.buildPolicy(
                goal: goal,
                model: model
            )


        policy = built

        Self.cachePolicy(built, defaults: defaults)


        return built

    }


    /// Policy lookup first; one LLM call ONLY when the app is unknown; caches
    /// the result back into `policy`. Never throws for a normal miss — a
    /// `.fallback` decision is returned if the model is unreachable.
    func evaluate(context: FocusContext) async throws -> FocusDecision {


        var currentPolicy: FocusPolicy


        if let existing = policy, existing.goal == context.goal {

            currentPolicy = existing

        } else {

            do {

                currentPolicy = try await buildPolicy(goal: context.goal)

            } catch {

                return FocusDecision(

                    focused: true,

                    confidence: 0,

                    reason: "No policy is available yet and the local model is unreachable.",

                    source: .fallback

                )

            }

        }


        let app = context.currentApplication


        switch currentPolicy.classify(app: app) {


        case .allowed:

            return FocusDecision(

                focused: true,

                confidence: 100,

                reason: "\(app) is on the allow list for this goal.",

                source: .policy

            )


        case .blocked:

            return FocusDecision(

                focused: false,

                confidence: 100,

                reason: "\(app) is on the block list for this goal.",

                source: .policy

            )


        case .unknown:

            isThinking = true

            defer { isThinking = false }


            do {

                let model = ModelRouter.model(for: .appClassification)


                let decision =
                    try await analyzer.classify(
                        goal: context.goal,
                        app: app,
                        model: model
                    )


                currentPolicy.learn(app: app, focused: decision.focused)

                policy = currentPolicy

                Self.cachePolicy(currentPolicy, defaults: defaults)


                return decision

            } catch {

                return FocusDecision(

                    focused: true,

                    confidence: 0,

                    reason: "Could not reach the local model; skipping this check.",

                    source: .fallback

                )

            }

        }

    }


    /// Clear policy state when a session ends.
    func reset() {

        policy = nil

    }


    private static func cacheKey(for goal: String) -> String {

        let normalized =
            goal
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return "ai.policy.\(normalized)"

    }


    private static func cachePolicy(
        _ policy: FocusPolicy,
        defaults: UserDefaults
    ) {

        guard let data = try? JSONEncoder().encode(policy) else {

            return

        }

        defaults.set(data, forKey: cacheKey(for: policy.goal))

    }


    private static func loadCachedPolicy(
        goal: String,
        defaults: UserDefaults
    ) -> FocusPolicy? {

        guard let data = defaults.data(forKey: cacheKey(for: goal)) else {

            return nil

        }

        return try? JSONDecoder().decode(FocusPolicy.self, from: data)

    }

}
