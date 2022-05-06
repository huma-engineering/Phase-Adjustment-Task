//
//  DoublePressButton.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 15/06/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import SwiftUI

struct DoublePressButton: View {
    @State var armed = false
    var action:() -> Void
    var body: some View {
        Button(action: {
            if !self.armed {
                self.armed = true
                return
            }
            action()
        }, label: {
            Text(armed ? "_button_continue_label" : "_button_confirm_label")
        })
        .background((armed ? Color.red : .green).shadow(radius: 3))
        .buttonStyle(UIUtils.MyMutiButtonStyle())
    }
}

struct DoublePressButton_Previews: PreviewProvider {
    static var previews: some View {
        DoublePressButton(action: {print("Pressed")})
    }
}
