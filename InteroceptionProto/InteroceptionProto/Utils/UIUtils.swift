//
//  File.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 02/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI

enum UIUtils {}

extension UIUtils {
    static let defaultVPadding = CGFloat(30)
    static let defaultHPadding = CGFloat(30)

    static let buttonsMinWidth = CGFloat(120)

    static let buttonsLittleWidth = CGFloat(90)

    struct ButtonLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(minWidth: UIUtils.buttonsMinWidth)
                .padding()
                .foregroundColor(.confirmButtonFgColor)
                .background(Color.confirmButtonBgColor.shadow(radius: 3))
        }
    }

    struct ButtonContinueLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(minWidth: UIUtils.buttonsMinWidth)
                .padding()
                .foregroundColor(.confirmButtonFgColor)
                .background(Color.green.shadow(radius: 3))
        }
    }

    struct ButtonBackLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(minWidth: UIUtils.buttonsLittleWidth)
                .padding()
                .foregroundColor(.confirmButtonFgColor)

                .background(Color.yellow.shadow(radius: 3))
        }
    }

    struct ButtonNavLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(minWidth: UIUtils.buttonsLittleWidth)
                .padding()
                .foregroundColor(.confirmButtonFgColor)
                .cornerRadius(100)
                .background(Color.green.shadow(radius: 3))
        }
    }

    struct ButtonMutiLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(minWidth: UIUtils.buttonsMinWidth)
                .padding()
                .foregroundColor(.confirmButtonFgColor)
        }
    }

    struct MyButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .modifier(UIUtils.ButtonLabelStyle())
        }
    }

    struct MyButtonContinueStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .modifier(UIUtils.ButtonContinueLabelStyle())
        }
    }

    struct MyButtonNavStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .modifier(UIUtils.ButtonNavLabelStyle())
        }
    }

    struct MyButtonBackStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .modifier(UIUtils.ButtonBackLabelStyle())
        }
    }

    struct MyMutiButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .modifier(UIUtils.ButtonMutiLabelStyle())
        }
    }
}

extension Color {
    static let bgColor = Color.white
    static let mainFgColor = Color.black

    static let confirmButtonBgColor = Color.red
    static let confirmButtonFgColor = Color.white
}

struct UIUtils_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {
            // no action, it's just a preview
        }, label: {
            Text("My button style")
        })
            .buttonStyle(UIUtils.MyButtonStyle())
        .previewLayout(.fixed(width: 200, height: 80))
    }
}
