//
//  OnboardingVideo1Screen.swift
//
//
//  Created by Joel Barker on 16/02/2020.
//

import SwiftUI
import AVKit

final class OnboardingVideoModel: NSObject, ObservableObject {
    @Published var videoURL: URL?
}

struct OnboardingVideoScreen<Content>: View where Content: View {

    @ObservedObject var viewModal = OnboardingVideoModel()

    let content: Content
    init(_ videoName: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.viewModal.videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")!
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    content
                        .multilineTextAlignment(.center)
                        .transition(.slide)
                }
                .padding(.all, UIUtils.defaultVPadding)

            }.frame(height: 220)

            HStack {
                PlayerContainerView(url: self.viewModal.videoURL!)
                    .transition(.slide)
            }
        }
    }
}

struct OnboardingVideo1Screen: View {
    var body: some View {
        OnboardingVideoScreen("heart_beat_sound_out_sync", content: {
            Text("_onboardingvideo1_content")
                .id("_onboardingvideo1_content")
        })
    }
}

struct OnboardingVideo2Screen: View {
    var body: some View {
        OnboardingVideoScreen("heartbeats_in_sync", content: {
            Text("_onboardingvideo2_content")
                .id("_onboardingvideo2_content")
        })
    }
}
