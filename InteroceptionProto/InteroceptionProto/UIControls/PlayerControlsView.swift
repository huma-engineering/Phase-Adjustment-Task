//
//  PlayerControlsView.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 19/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVKit

// This is the SwiftUI view that contains the controls for the player
struct PlayerControlsView: View {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool

    let player: AVPlayer

    @State private var playerPaused = true

    var body: some View {
        HStack {
            // Play/pause button
            Button(action: togglePlayPause) {
                Image(systemName: playerPaused ? "play" : "pause")
                    .padding(.trailing, 10)
            }
            // Slider for seeking / showing video progress
            Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }

    private func togglePlayPause() {
        pausePlayer(!playerPaused)
    }

    private func pausePlayer(_ pause: Bool) {
        playerPaused = pause
        if playerPaused {
            player.pause()
        } else {
            player.play()
        }
    }

    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Set a flag stating that we're seeking so the slider doesn't
            // get updated by the periodic time observer on the player
            seeking = true
            pausePlayer(true)
        }

        // Do the seek if we're finished
        if !editingStarted {
            let targetTime = CMTime(seconds: videoPos * videoDuration,
                                    preferredTimescale: 600)
            player.seek(to: targetTime) { _ in
                // Now the seek is finished, resume normal operation
                self.seeking = false
                self.pausePlayer(false)
            }
        }
    }
}
