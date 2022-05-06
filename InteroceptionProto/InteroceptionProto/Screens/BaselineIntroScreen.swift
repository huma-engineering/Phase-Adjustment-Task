//
//  BaselineIntroScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 24/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI

struct BaselineIntroScreen: View {
    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)

            VStack {
                VStack {
                    Spacer().frame(height: 10)

                    HStack(alignment: .center) {

                        VStack {
                            Image("FingerOnCameraStandard")
                            Text("_baseline_intro_title").frame(width: 320)
                            Spacer()
                            Text("_baseline_intro_body")
                                .frame(width: 320)
                                .font(.system(size: 13))
                        }
                    }
                    Spacer().frame(height: 30)
                }.frame(height: 500)
                Spacer()
            }
        }
    }
}

struct BaselineIntroScreen_Previews: PreviewProvider {

    static var previews: some View {
        BaselineIntroScreen()
    }
}
