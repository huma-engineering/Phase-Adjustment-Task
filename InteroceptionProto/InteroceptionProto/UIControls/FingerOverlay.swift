//
//  FingerOverlay.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 16/07/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import SwiftUI

struct FingerOverlay: View {
    var body: some View {
        ZStack {
            Color.bgColor
            VStack {
                Image("FingerOnCameraStandard")
                Text("_readjust_your_grip_title")
                    .font(.headline)
                Text("_readjust_your_grip_body")
                    .font(.footnote)
                    .padding()
            }
        }
        .zIndex(1)
    }
}

struct FingerOverlay_Previews: PreviewProvider {
    static var previews: some View {
        FingerOverlay()
    }
}
