import SwiftUI

struct StatusBadge: View {

    let text: String

    let color: Color

    var body: some View {

        Label {

            Text(text)

        } icon: {

            Circle()
                .fill(color)
                .frame(width: 10)

        }

    }

}
