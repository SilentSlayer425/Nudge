import Foundation


enum NudgeState {

    case idle
    case focused
    case checking
    case distracted
    case standby


    var icon: String {

        switch self {

        case .idle:
            return "brain.head.profile"

        case .focused:
            return "brain.head.profile.fill"

        case .checking:
            return "hourglass"

        case .distracted:
            return "exclamationmark.circle"

        case .standby:
            return "moon"

        }

    }

}
