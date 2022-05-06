//
//  OnboardingImageScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 16/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVKit

final class OnboardingImageModel: NSObject, ObservableObject {
    @Published var imageName = ""

    @Published var textHeight = CGFloat()
}

struct OnboardingImageScreen<Content>: View where Content: View {

    @ObservedObject var viewModal = OnboardingImageModel()

    let content: Content

    init(_ imgName: String, txtHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.viewModal.imageName = imgName
        self.viewModal.textHeight = txtHeight
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    content
                        .multilineTextAlignment(.center)
                }
            }.frame(height: $viewModal.textHeight.wrappedValue)

            HStack {
                Image($viewModal.imageName.wrappedValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 279)
            }
        }
        .id($viewModal.imageName.wrappedValue)
        .transition(.slide)
    }
}

struct OnboardingImage1Screen: View {
    var body: some View {
        OnboardingImageScreen("confidence_screenshot", txtHeight: 160, content: {
            Text("_onboardingimage1_content")
        })
    }
}

struct OnboardingImage2Screen: View {
    var body: some View {
        OnboardingImageScreen("mannequin_coloured", txtHeight: 230, content: {
            Text("_onboardingimage2_content")
        })
    }
}
