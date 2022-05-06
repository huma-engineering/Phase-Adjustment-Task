//
//  PlayerContainersView.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 19/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVKit

// This is the SwiftUI view which contains the player and its controls
struct PlayerContainerView: View {
    // The progress through the video, as a percentage (from 0 to 1)
    @State private var videoPos: Double = 0
    // The duration of the video in seconds
    @State private var videoDuration: Double = 0
    // Whether we're currently interacting with the seek bar or doing a seek
    @State private var seeking = false

    private let player: AVPlayer

    init(url: URL) {
        player = AVPlayer(url: url)
    }

    var body: some View {
        VStack {
            PlayerView(videoPos: $videoPos, videoDuration: $videoDuration, seeking: $seeking, player: player)
            PlayerControlsView(videoPos: $videoPos, videoDuration: $videoDuration, seeking: $seeking, player: player)
        }
    }
}
