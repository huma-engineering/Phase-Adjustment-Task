//
//  ConfidenceRatingScreen.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 03/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI
import os
private final class ConfidenceRatingScreenViewModel: ObservableObject {
    static let confidenceRange = ClosedRange<Double>(uncheckedBounds: (lower: 0, upper: 9))
    @Published var confidence = -1

    @Published var measureNotValid = false

    @Published var theButtonText = "Confirm"

    @Published var showActivity = false

    @Published var confidenceForSlider: Double {
        // double is needed for the slider
        didSet {
            confidence = Int(confidenceForSlider)
        }
    }

    init() {
        confidenceForSlider = .random(in: Self.confidenceRange)
    }

    @objc func start() {
        SyncroTaskManager.shared.taskDelegate = self
    }
}

// PRAGMA MARK: SyncroTaskManagerDelegate
extension ConfidenceRatingScreenViewModel: SyncroTaskManagerDelegate {

    func torchError () {
    }

    func fingerPresentChanged(_ isPresent: Bool) {
        print("Finger is present: \(isPresent)")
        DispatchQueue.main.async {
            self.measureNotValid = !isPresent
        }
    }

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float) {

    }

    func newPPGSampleReady(_ sample: Float) {

    }

    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float) {

    }
}

struct ConfidenceRatingScreen: View {
    @ObservedObject var interoceptionSettings: InteroceptionSettings

    @ObservedObject private var viewModel = ConfidenceRatingScreenViewModel()

    @Environment(\.presentationMode) var presentationMode

    @Binding var allowProgress: Bool

    var body: some View {

        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)

            if viewModel.measureNotValid {
                FingerOverlay().transition(AnyTransition.opacity.animation(.easeOut(duration: 0.2)))
            }

            VStack {
                Text("_rating_screen_title")
                    .padding([.top, .horizontal], UIUtils.defaultVPadding)
                    .multilineTextAlignment(.center)

                Spacer()
                ConfidenceSlider(confidenceForSlider: $viewModel.confidenceForSlider, userHasSetValue: $allowProgress)
                Spacer()

                if self.$viewModel.showActivity.wrappedValue {
                    ProgressBar(width: 25, duration: 1,
                                backgroundColor: .background, color: .slider)
                        .frame(width: 100, height: 80, alignment: .center)
                }
            }
            .foregroundColor(.mainFgColor)
        }.onAppear {
            self.viewModel.start()
        }
        .onDisappear {
            if self.viewModel.confidence == -1 {
                self.viewModel.confidence = Int(self.viewModel.confidenceForSlider)
            }

            NotificationCenter.default.post(name: .recordSyncro, object: self.viewModel.confidence)
            InteroceptionSettings.practicesToGo -= 1
        }
    }
}

private struct ConfidenceSlider: View {
    private static let legendMaxWidth = CGFloat(130)
    @Binding var confidenceForSlider: Double
    @Binding var userHasSetValue: Bool

    var body: some View {
        VStack {
            Slider(
                value: $confidenceForSlider,
                in: ConfidenceRatingScreenViewModel.confidenceRange,
                step: 1,
                onEditingChanged: { _ in
                    userHasSetValue = true
                }
            )
            HStack {
                Text("_rating_screen_lowest_confidence")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: Self.legendMaxWidth, alignment: .leading)
                Spacer()
                Text("_rating_screen_highest_confidence")
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: Self.legendMaxWidth, alignment: .trailing)
            }
        }
        .padding()
    }
}

struct ConfidenceRatingScreen_Previews: PreviewProvider {
    @State static var valueSet = false
    static var previews: some View {
        ConfidenceRatingScreen(interoceptionSettings: InteroceptionSettings(numberOfTrials: 20), allowProgress: $valueSet)
    }
}
