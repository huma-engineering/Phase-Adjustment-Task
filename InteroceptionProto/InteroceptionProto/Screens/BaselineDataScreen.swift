//
//  BaselineDataScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 23/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CircleProgressBar: View {
    @Binding var progress: Float

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.red)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                .font(.system(size: 30, weight: .bold, design: .monospaced))

        }
    }
}

final class BaselineDataModel: ObservableObject {

    // this is one way to decide how long a baseline to capture
    @Published var maxSeconds = 120

    @Published var maxSecondsDo = Double(120)

    @Published var percentDone: Float = 0.0

    @Published var elapsedSecs = 0

    @Published public var showNext: Int?

    @Published var measureNotValid = true

    @Published var chartWidth = CGFloat(0)

    @Published var flashNotWorking = false

    private var motionDetector: MotionDetector!

    private var isFingerPresent = false
    private var isMovingTooMuch = false

    var secsTimer = Timer()

    var startTimer = Timer()

    var device: AVCaptureDevice?
    let onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        SyncroTaskManager.shared.taskDelegate = self
        let devices = [AVCaptureDevice.DeviceType.builtInTelephotoCamera]
        self.device = AVCaptureDevice.DiscoverySession.init(deviceTypes: devices, mediaType: .video, position: .back).devices.first

        if SyncroTaskManager.shared.isSimulator() {
            self.isFingerPresent = true
            self.maxSeconds = 12
            self.maxSecondsDo = 12.0
        }

        SyncroTaskManager.shared.torchCheck()
    }

    func startCountDown () {
        SyncroTaskManager.shared.start()

        self.motionDetector = MotionDetector()
        self.motionDetector.start()

        self.secsTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.secsTimerFinished),
            userInfo: nil,
            repeats: true
        )

        self.elapsedSecs = maxSeconds
    }

    func stop () {
        motionDetector.stop()

        SyncroTaskManager.shared.taskDelegate = nil
        SyncroTaskManager.shared.stopAndRecordBaseline()
    }

    @objc
    func startTimerFinished () {
        self.chartWidth = CGFloat(330.0)
        self.startCountDown()
    }

    @objc
    func secsTimerFinished () {
        self.elapsedSecs -= 1
        self.percentDone = 1.0 - Float(self.elapsedSecs) / Float(maxSeconds)

        if self.elapsedSecs == 0 {
            self.secsTimer.invalidate()
            self.onComplete()
            self.stop()
        }

        if device != nil {
            if !device!.isTorchActive {
                self.flashNotWorking = true
            }
        }
    }
}

// PRAGMA MARK: SyncroTaskManagerDelegate
extension BaselineDataModel: SyncroTaskManagerDelegate {
    func torchError () {
        self.flashNotWorking = true
    }

    func fingerPresentChanged(_ isPresent: Bool) {
        DispatchQueue.main.async {
            self.isFingerPresent = isPresent
            self.measureNotValid = !self.isFingerPresent || self.isMovingTooMuch
        }
    }

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float) {
        self.motionDetector.checkIsMovingTooMuch { isMovingTooMuch in DispatchQueue.main.async {
                self.isMovingTooMuch = isMovingTooMuch
                self.measureNotValid = !self.isFingerPresent || self.isMovingTooMuch
            }
        }
    }

    func newPPGSampleReady(_ sample: Float) {

    }

    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float) {

    }
}

struct BaselineDataScreen: View {
    @State private var chartWidth: CGFloat = 10
    @ObservedObject var baselineDataModel: BaselineDataModel

    init(controller: ScreenController) {
       baselineDataModel = BaselineDataModel(onComplete: {
           controller.nextScreen()
       })
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {

                Color.bgColor
                    .edgesIgnoringSafeArea(.all)

                if baselineDataModel.measureNotValid {
                    FingerOverlay().transition(AnyTransition.opacity.animation(.easeOut(duration: 0.2)))
                }

                VStack(alignment: .center) {

                    Spacer()
                    Text("_checking")
                    Spacer()

                    Image("FingerOnCameraStandard")
                    Spacer()

                    HStack {
                        Spacer()
                        CircleProgressBar(progress: $baselineDataModel.percentDone)
                            .frame(width: CGFloat(100.0), alignment: .center)
                        Spacer()
                    }

                    Text("_seconds_left_\($baselineDataModel.elapsedSecs.wrappedValue, specifier: "%d")")

                    Spacer()
                }
            }.alert(isPresented: $baselineDataModel.flashNotWorking) {
                Alert(
                    title: Text("_flash_not_working_title"),
                    message: Text("_flash_not_working_body"),
                    dismissButton: .default(
                        Text("_button_okay"),
                        action: {
                            self.$baselineDataModel.flashNotWorking.wrappedValue = false
                        }
                    )
                )
            }.onAppear {
                self.baselineDataModel.startTimerFinished()
            }.frame(width: CGFloat(330.0), alignment: .leading)

        }.navigationBarBackButtonHidden(true)
    }
}

struct MyRectangle: View {
    var body: some View {
        Rectangle().fill(Color.blue)
    }
}

struct BaselineDataScreen_Previews: PreviewProvider {
    static var previews: some View {
        BaselineDataScreen(controller: ScreenController())
    }
}
