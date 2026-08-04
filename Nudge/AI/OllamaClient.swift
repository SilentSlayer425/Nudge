import Foundation


enum OllamaError: Error, LocalizedError {

    case badURL

    case httpStatus(Int)

    case emptyResponse

    case envelopeDecoding(Error)

    case malformedResponse(raw: String, underlying: Error)

    case transport(Error)


    var errorDescription: String? {

        switch self {

        case .badURL:

            return "Invalid Ollama URL"

        case .httpStatus(let code):

            return "Ollama returned HTTP \(code)"

        case .emptyResponse:

            return "Ollama returned an empty response"

        case .envelopeDecoding(let error):

            return "Failed to decode Ollama's API response: \(error.localizedDescription)"

        case .malformedResponse(_, let underlying):

            return "Model output did not match the expected schema: \(underlying.localizedDescription)"

        case .transport(let error):

            return "Failed to reach Ollama: \(error.localizedDescription)"

        }

    }

}


class OllamaClient {


    private let baseURL = "http://127.0.0.1:11434"

    private let requestTimeout: TimeInterval = 30


    private struct GenerateResponse: Decodable {

        let response: String

    }


    /// Sends a structured-output request to Ollama and decodes the model's
    /// `response` field (a JSON string conforming to `schema`) into `T`.
    func generate<T: Decodable>(
        prompt: String,
        model: String,
        schema: [String: Any],
        as type: T.Type
    ) async throws -> T {


        guard let url = URL(string: "\(baseURL)/api/generate") else {

            throw OllamaError.badURL

        }


        let body: [String: Any] = [

            "model": model,

            "prompt": prompt,

            "stream": false,

            "think": false,

            "keep_alive": "30m",

            "format": schema

        ]


        let bodyData: Data

        do {

            bodyData = try JSONSerialization.data(withJSONObject: body)

        } catch {

            throw OllamaError.envelopeDecoding(error)

        }


        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.httpBody = bodyData

        request.timeoutInterval = requestTimeout

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let data: Data

        let httpResponse: HTTPURLResponse


        do {

            let (responseData, urlResponse) = try await URLSession.shared.data(for: request)

            data = responseData

            guard let http = urlResponse as? HTTPURLResponse else {

                throw OllamaError.emptyResponse

            }

            httpResponse = http

        } catch let error as OllamaError {

            throw error

        } catch {

            throw OllamaError.transport(error)

        }


        guard (200...299).contains(httpResponse.statusCode) else {

            throw OllamaError.httpStatus(httpResponse.statusCode)

        }


        let envelope: GenerateResponse

        do {

            envelope = try JSONDecoder().decode(GenerateResponse.self, from: data)

        } catch {

            throw OllamaError.envelopeDecoding(error)

        }


        guard !envelope.response.isEmpty,
              let responseData = envelope.response.data(using: .utf8)
        else {

            throw OllamaError.emptyResponse

        }


        do {

            let decoded = try JSONDecoder().decode(T.self, from: responseData)

            print("Ollama[\(model)] responded OK")

            return decoded

        } catch {

            throw OllamaError.malformedResponse(raw: envelope.response, underlying: error)

        }

    }

}
