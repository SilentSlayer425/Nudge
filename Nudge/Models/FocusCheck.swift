import Foundation


struct FocusCheck: Codable, Identifiable, Equatable {

    let id: UUID

    let date: Date

    let status: FocusStatus

    let confidence: Int

    let application: String

    let reason: String


    init(
        id: UUID = UUID(),
        date: Date = Date(),
        status: FocusStatus,
        confidence: Int,
        application: String,
        reason: String
    ) {

        self.id = id

        self.date = date

        self.status = status

        self.confidence = confidence

        self.application = application

        self.reason = reason

    }

}


// `FocusStatus` lives in FocusStatus.swift, owned by another agent right
// now, so its Codable/Equatable conformance is added here — retroactively,
// by hand — rather than by editing that file.

extension FocusStatus: Codable {

    public init(from decoder: Decoder) throws {

        let raw = try decoder
            .singleValueContainer()
            .decode(String.self)


        switch raw {

        case "onTask":
            self = .onTask

        case "distracted":
            self = .distracted

        default:
            self = .unknown

        }

    }


    public func encode(to encoder: Encoder) throws {

        var container = encoder.singleValueContainer()


        switch self {

        case .onTask:
            try container.encode("onTask")

        case .distracted:
            try container.encode("distracted")

        case .unknown:
            try container.encode("unknown")

        }

    }

}


extension FocusStatus: Equatable {

    public static func == (lhs: FocusStatus, rhs: FocusStatus) -> Bool {

        switch (lhs, rhs) {

        case (.onTask, .onTask),
             (.distracted, .distracted),
             (.unknown, .unknown):
            return true

        default:
            return false

        }

    }

}
