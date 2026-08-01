import Foundation


class FocusAnalyzer {


    private let ollama =
        OllamaClient()



    func analyze(
        context: FocusContext
    ) async throws -> String {


        let prompt = """

        You are a productivity assistant.

        Determine if the user is working on their goal.

        Goal:
        \(context.goal)

        Current Application:
        \(context.currentApplication)

        Idle Time:
        \(Int(context.idleTime)) seconds

        Battery:
        \(Int(context.batteryLevel))%

        Return only:

        Focused: true/false
        Confidence: number 0-100
        Reason: short explanation

        """



        let response =
            try await ollama.ask(
                prompt: prompt
            )


        return response

    }


}
