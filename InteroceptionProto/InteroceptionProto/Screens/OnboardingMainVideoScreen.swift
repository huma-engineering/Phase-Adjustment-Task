//
//  OnboardingMainVideoScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 16/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVKit

final class OnboardingMainVideoModel: NSObject, ObservableObject {
    @Published var videoURL: URL?
}

struct OnboardingMainVideoScreen: View {
    @ObservedObject var viewModal = OnboardingMainVideoModel()
    @State var goBack = false

    init(_ videoName: String) {
        self.viewModal.videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")!
    }

    var body: some View {
        VStack {
            HStack {
                PlayerContainerView(url: self.viewModal.videoURL!)
            }
        }
    }
}

struct OnboardingMainVideo1Screen: View {
    var body: some View {
        OnboardingMainVideoScreen("video_for_MAD_task_final")
    }
}
