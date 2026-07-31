import SwiftUI

struct TimerView: View {

    let seconds: TimeInterval

    var body: some View {

        Text(timeString)
            .font(.system(size: 42, weight: .bold, design: .rounded))

    }

    var timeString: String {

        let total = Int(seconds)

        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60

        if hours > 0 {

            return String(format: "%02d:%02d:%02d",
                          hours,
                          minutes,
                          secs)

        }

        return String(format: "%02d:%02d",
                      minutes,
                      secs)

    }

}
