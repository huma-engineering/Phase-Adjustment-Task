//
//  TrialScreen.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 02/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine
import os

final class TrialScreenViewModel: ObservableObject {
    static let shortestDelay = Double(60.0/140.0)

    private static let baselineDuration = Int32(10)
    private static let pollingInterval = TimeInterval(0.001) // 50Hz

    private var player: AVAudioPlayer?
    private var secondPlayer: AVAudioPlayer?
    private var fakeBpmTimerCanc: AnyCancellable!
    private var motionDetector: MotionDetector!

    var averageBpm = Float(0)
    var simHRTimer = Timer()

    @Published var practiceLabelTxt = String("")

    @Published var debugViewHidden = true

    // Min/Max output from knob is -1 / 1 (1 period)
    let knobValueRange = 1.0
    @Published var currentKnobValue = Double(0)

    @Published var instantBpm = Float(0)
    @Published var averagePeriod = Double(0)
    @Published var instantPeriod = Double(0)
    private var isFingerPresent = true
    private var isMovingTooMuch = false
    @Published var instantErr = Double(0)
    @Published var measureNotValid = false

    @Published var currentDelays: [Double] = []
    @Published var averagePeriods: [Double] = []
    @Published var instantPeriods: [Double] = []
    @Published var knobScales: [Double] = []
    @Published var instantErrs: [Double] = []

    @Published var flashNotWorking = false

    var device: AVCaptureDevice?

    var secsTimer = Timer()

    init() {
        initAudioPlayer()
        initSecondAudioPlayer()
    }

    @objc
    func start() {
        currentKnobValue = .random(in: -knobValueRange ... knobValueRange)

        self.motionDetector = MotionDetector()
        self.motionDetector.start()
        os_log("Motion detector started", log: OSLog.motiondetection, type: .info)

        self.measureNotValid = false
        self.isFingerPresent = true
        self.isMovingTooMuch = false

        if SyncroTaskManager.shared.isSimulator() {
            self.isFingerPresent = true
        }

        self.secsTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.secsTimerFinished),
            userInfo: nil,
            repeats: true)

        SyncroTaskManager.shared.taskDelegate = nil
        SyncroTaskManager.shared.taskDelegate = self

        self.instantPeriods.removeAll()
        self.averagePeriods.removeAll()
        self.knobScales.removeAll()
        self.instantErrs.removeAll()
        self.currentDelays.removeAll()

        // @David: Decomment the following to switch to real HR
        SyncroTaskManager.shared.start()
        // @David: Comment the following to switch to real HR
        //        startFakeBpmTimer()
    }

    @objc
    func stop() {
        SyncroTaskManager.shared.stop()
        // @David: Comment the following to switch to real HR
        // self.fakeBpmTimerCanc.cancel()

        self.secsTimer.invalidate()
        self.motionDetector.stop()
        os_log("Motion detector stopped", log: OSLog.motiondetection, type: .info)
    }

    @objc
    func secsTimerFinished () {
        guard device != nil
        else {
            return
        }
        if !device!.isTorchActive {
            self.flashNotWorking = true
        }
    }

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(start), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stop), name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func initAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "lowBeep", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        } catch let error {
            os_log("Failed to get AVAudioSession %s", log: OSLog.video, type: .error, error.localizedDescription)
        }
    }

    private func initSecondAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "highBeep", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            secondPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        } catch let error {
            os_log("Failed to get AVAudioSession %s", log: OSLog.video, type: .error, error.localizedDescription)
        }
    }

    private func startFakeBpmTimer() {
        fakeBpmTimerCanc = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                self.beatDetected(withInstantBPM: 60, andAverageBPM: 60)
            }
    }

    private func playDelayedSound() {
        guard !measureNotValid, let player = player else { return }
        player.play()
    }

    private func playHRSound() {
        if measureNotValid {
            return
        }
        guard !measureNotValid, let secondPlayer = secondPlayer else { return }
        secondPlayer.play()
    }
}

// PRAGMA MARK: SyncroTaskManagerDelegate
extension TrialScreenViewModel: SyncroTaskManagerDelegate {

    func torchError () {
    }

    func fingerPresentChanged(_ isPresent: Bool) {
        os_log("Finger is present: %s", log: OSLog.heartdetection, type: .info, isPresent)

        DispatchQueue.main.async {
            self.isFingerPresent = isPresent
            self.measureNotValid = !self.isFingerPresent
        }
    }

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float) {
        // Check movement
        DispatchQueue.main.async {
            // Update some info
            let currentInstantPeriod = self.instantPeriod
            self.instantBpm = instantBPM
            self.instantPeriod = Double(60.0/self.instantBpm)
            self.instantErr = currentInstantPeriod - self.instantPeriod

            self.averageBpm = averageBPM
            self.averagePeriod = Double(60.0/self.averageBpm)

            self.instantPeriods.append(self.instantPeriod)
            self.averagePeriods.append(self.averagePeriod)
            self.knobScales.append(self.currentKnobValue)
            self.instantErrs.append(self.instantErr)
            self.currentDelays.append(self.currentDelay())

            // Schedule delayed sound based on current know value (aka the delay) and current time
            // If knob < 0, e.g. -1, then the delay in second from now is period + delay (e.g. 1s - 0.5s),
            // otherwise it's just delay
            // @David if you prefer average period intead of instant, change it in the following line
            let delayFromNow = self.currentDelay() < 0 ? self.instantPeriod + self.currentDelay() : self.currentDelay()
            Timer.scheduledTimer(withTimeInterval: delayFromNow, repeats: false, block: { (_) in
                self.playDelayedSound()
            })

            self.motionDetector.checkIsMovingTooMuch { isMovingTooMuch in
                DispatchQueue.main.async {
                    self.isMovingTooMuch = isMovingTooMuch
                }
            }
        }
    }
    func newPPGSampleReady(_ sample: Float) {
        // nothing to do
    }
    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float) {
        // nothing to do
    }

    func currentDelay() -> Double {
        // If an average period is set and the period is X (e.g. 1 second if 60bpm)
        // Then the current delay from the beat to the follow up sound is X/2 * knobValue, cause
        // knob goes from -1 to 1
        guard averagePeriod != 0 else {
            // If not set, just the shortest delay (60bpm/140bpm)
            return TrialScreenViewModel.shortestDelay
        }
        // here we can decide whether we use half the period (averagePeriod/2) or whole
        return averagePeriod/2 * currentKnobValue
    }

    func getTaskData() -> SyncroTrialDataset {
        let taskData = SyncroTrialDataset()

        taskData.date = Date()

        taskData.instantPeriods = instantPeriods
        taskData.averagePeriods = averagePeriods

        taskData.instantErrs = instantErrs
        taskData.knobScales = knobScales
        taskData.currentDelays = currentDelays
        return taskData
    }
}

struct DebugScreen: View {

    @ObservedObject var trialViewModel: TrialScreenViewModel

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: nil) {
                    Text("instantBpm: \(trialViewModel.instantBpm)")
                    Text("averageBpm: \(trialViewModel.averageBpm)")
                    Text("instantPeriod: \(trialViewModel.instantPeriod)")
                    Text("averagePeriod: \(trialViewModel.averagePeriod)")
                    Text("instantErr: \(trialViewModel.instantErr)")
                }

                Spacer()
            }
            .background(Color.black.opacity(0.5))
            .foregroundColor(Color.green)

            Spacer()
        }
        .padding(.top)
    }
}

struct TrialScreen: View {
    private static let knobSize = CGFloat(200)

    @ObservedObject var interoceptionSettings: InteroceptionSettings
    @StateObject var trialViewModel = TrialScreenViewModel()
    @Binding var allowProgress: Bool

    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)

            if trialViewModel.measureNotValid {
                FingerOverlay().transition(AnyTransition.opacity.animation(.easeOut(duration: 0.2)))
            }

            if !trialViewModel.debugViewHidden {
                DebugScreen(trialViewModel: trialViewModel)
                    .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.2)))
                    .zIndex(10)
            }

            VStack {
                TextField("", text: $trialViewModel.practiceLabelTxt)
                    .frame(width: CGFloat(330.0), alignment: .leading).multilineTextAlignment(.center)

                Text("_trial_instruction").multilineTextAlignment(.center)

                Spacer()

                HStack {
                    VStack(alignment: .leading) {
                        Text(".")
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 100.0)
                            .font(Font.system(size: 12, design: .default))
                        Path { path in
                            path.move(to: CGPoint(x: 55, y: 0))
                            path.addQuadCurve(to: CGPoint(x: 45, y: 50), control: CGPoint(x: 45, y: 20))
                            path.addQuadCurve(to: CGPoint(x: 55, y: 100), control: CGPoint(x: 45, y: 75))
                            path.addLine(to: CGPoint(x: 45, y: 95))
                            path.move(to: CGPoint(x: 55, y: 100))
                            path.addLine(to: CGPoint(x: 60, y: 91))
                        }
                        .stroke(lineWidth: 2)
                        .frame(width: 50, height: 100.0)
                        Spacer()
                            .frame(width: 30, height: 100.0)

                    }
                    .padding(1.0)

                    KnobView(value: $trialViewModel.currentKnobValue, rang: trialViewModel.knobValueRange, interactedWith: $allowProgress)
                        .padding(.leading, 6.0)
                        .frame(width: Self.knobSize, height: Self.knobSize)
                    VStack(alignment: .leading) {
                        Text(".")
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 100.0)
                            .font(Font.system(size: 12, design: .default))
                        Path { path in
                            path.move(to: CGPoint(x: 5, y: 0))
                            path.addQuadCurve(to: CGPoint(x: 15, y: 50), control: CGPoint(x: 15, y: 20))
                            path.addQuadCurve(to: CGPoint(x: 5, y: 100), control: CGPoint(x: 15, y: 75))
                            path.addLine(to: CGPoint(x: 15, y: 95))
                            path.move(to: CGPoint(x: 5, y: 100))
                            path.addLine(to: CGPoint(x: 0, y: 90))

                        }
                        .stroke(lineWidth: 2)
                        .frame(width: 30, height: 100.0)
                        Spacer()
                            .frame(width: 30, height: 100.0)

                    }
                    .padding(6.0)
                }
            }
            .padding(.all, UIUtils.defaultVPadding)
        }
        .alert(isPresented: $trialViewModel.flashNotWorking) {
            Alert(
                title: Text("_flash_not_working_title"),
                message: Text("_flash_not_working_body"),
                dismissButton: .default(
                    Text("Ok"),
                    action: {
                        self.$trialViewModel.flashNotWorking.wrappedValue = false
                    }
                )
            )
        }
        .foregroundColor(.mainFgColor)
        .onAppear {
            if InteroceptionSettings.practicesToGo > 0 {
                if self.interoceptionSettings.currentIndex == -2 {
                    self.trialViewModel.practiceLabelTxt = "PRACTICE TRIAL 1:"
                } else {
                    self.trialViewModel.practiceLabelTxt = "PRACTICE TRIAL 2:"
                }
            } else {
                let indxDisplay = self.interoceptionSettings.currentIndex + 1

                self.trialViewModel.practiceLabelTxt = "TRIAL " + indxDisplay.description + ":"
            }

            self.trialViewModel.registerForNotifications()
            self.trialViewModel.start()
        }
        .onDisappear {
            self.trialViewModel.stop()
            let taskData = self.trialViewModel.getTaskData()
            NotificationCenter.default.post(name: .recordSyncro, object: taskData)

            SyncroTaskManager.shared.taskDelegate = nil
        }
    }
}

struct TrialScreen_Previews: PreviewProvider {
    @State static var allowProgress = true

    static var previews: some View {
        let trialViewModel = TrialScreenViewModel()
        trialViewModel.measureNotValid = false
        return TrialScreen(
            interoceptionSettings: InteroceptionSettings(numberOfTrials: 20),
            trialViewModel: trialViewModel, allowProgress: $allowProgress)
    }
}
