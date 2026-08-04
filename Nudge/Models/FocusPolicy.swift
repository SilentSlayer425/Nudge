import Foundation


enum PolicyVerdict {

    case allowed

    case blocked

    case unknown

}


struct FocusPolicy: Codable, Equatable {


    var goal: String

    var allow: Set<String>

    var block: Set<String>


    private static func normalize(
        _ app: String
    ) -> String {

        app
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

    }


    func classify(
        app: String
    ) -> PolicyVerdict {


        let key = Self.normalize(app)


        if allow.contains(key) {

            return .allowed

        }


        if block.contains(key) {

            return .blocked

        }


        return .unknown

    }


    mutating func learn(
        app: String,
        focused: Bool
    ) {


        let key = Self.normalize(app)


        if focused {

            allow.insert(key)

            block.remove(key)

        } else {

            block.insert(key)

            allow.remove(key)

        }

    }

}
