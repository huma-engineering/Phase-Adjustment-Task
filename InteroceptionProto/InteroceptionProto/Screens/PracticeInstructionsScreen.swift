//
//  PracticeInstructionsScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 28/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI

struct PracticeInstructionsScreen: View {
    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    Text("_onboarding9_content")
                        .padding(.all, UIUtils.defaultVPadding)
                        .multilineTextAlignment(.center)
                }.frame(height: 300)
            }
        }
        .foregroundColor(Color.mainFgColor)
        .navigationBarBackButtonHidden(true)

    }
}

struct PracticeInstructionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        PracticeInstructionsScreen()
    }
}
