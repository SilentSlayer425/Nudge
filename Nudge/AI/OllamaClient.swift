import Foundation


class OllamaClient {


    func ask(
        prompt: String,
        model: String = "qwen3:0.6b"
    ) async throws -> String {


        let url =
        URL(
            string:
            "http://localhost:11434/api/generate"
        )!



        let body =
        [
            "model": model,
            "prompt": prompt,
            "stream": false,
            "think": false
        ] as [String : Any]



        let data =
        try JSONSerialization.data(
            withJSONObject: body
        )



        var request =
        URLRequest(
            url: url
        )


        request.httpMethod = "POST"

        request.httpBody = data

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        print("Sending request to Ollama..")
        print(prompt)
        
        let (response, _) =
        try await URLSession.shared
            .data(for: request)



        let json =
        try JSONSerialization
            .jsonObject(
                with: response
            )
            as! [String:Any]

        print(json)

        return
            json["response"] as? String
            ?? ""

    }

}
