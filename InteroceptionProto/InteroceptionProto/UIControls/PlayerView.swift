//
//  PlayerView.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 16/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVKit

// This is the SwiftUI view which wraps the UIKit-based PlayerUIView above
struct PlayerView: UIViewRepresentable {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool

    let player: AVPlayer

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes, but we don't in this example
    }

    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> UIView {
        let uiView = PlayerUIView(player: player,
                                  videoPos: $videoPos,
                                  videoDuration: $videoDuration,
                                  seeking: $seeking)
        return uiView
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let playerUIView = uiView as? PlayerUIView else {
            return
        }

        playerUIView.cleanUp()
    }
}
