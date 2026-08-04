//
//  PrimaryButton.swift
//  Nudge
//
//  Created by Sai on 7/31/26.
//

import SwiftUI


struct PrimaryButtonStyle: ButtonStyle {

    var isDestructive: Bool = false


    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                (isDestructive ? Color.red : Color.accentColor)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

    }

}


extension ButtonStyle where Self == PrimaryButtonStyle {

    static var primary: PrimaryButtonStyle {

        PrimaryButtonStyle()

    }


    static var destructive: PrimaryButtonStyle {

        PrimaryButtonStyle(isDestructive: true)

    }

}
