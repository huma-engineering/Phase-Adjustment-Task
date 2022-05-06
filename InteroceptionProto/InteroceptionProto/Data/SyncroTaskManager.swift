//
//  SyncroTaskManager.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 23/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import UIKit
import HeartDetectorEngine
import AVFoundation

protocol SyncroTaskManagerDelegate: AnyObject {

    func fingerPresentChanged(_ isPresent: Bool)

    func torchError ()

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float)

    func newPPGSampleReady(_ sample: Float)

    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float)
}

class SyncroTaskManager: NSObject {

    static var averageBpms: [Float] = []
    static var instantBpms: [Float] = []

    private static let baselineDuration = Int32(10)

    weak var taskDelegate: SyncroTaskManagerDelegate?

    private let engine = HeartDetectorEngine()

    @objc
    static let shared = SyncroTaskManager()

    var simHRTimer = Timer()

    func start() {

        SyncroTaskManager.instantBpms.removeAll()
        SyncroTaskManager.averageBpms.removeAll()

        if Platform.isSimulator {
            self.simHRTimer.invalidate()

            self.simHRTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(self.artificialHeartBeat),
                userInfo: nil,
                repeats: true)

        } else {
            engine.hrDelegate = self
            engine.startHeartEngineSavingRawCameraSamples(false, forDuration: Self.baselineDuration)
        }
    }

    func stopAndRecordBaseline () {
        if Platform.isSimulator {
            self.simHRTimer.invalidate()
        } else {
            engine.stop()
            engine.hrDelegate = nil
        }
        NotificationCenter.default.post(name: .recordBaseline, object: nil)
    }

    func stop () {
        if Platform.isSimulator {
            self.simHRTimer.invalidate()
        } else {
            engine.stop()
            engine.hrDelegate = nil
        }
    }

    @objc
    func artificialHeartBeat () {

        let instantBPM = Float(60)
        let averageBPM = Float(60)

        self.beatDetected(withInstantBPM: instantBPM, andAverageBPM: averageBPM)
    }

    func isSimulator () -> Bool {
        return Platform.isSimulator
    }

    func torchCheck () {
        if self.isSimulator() {
            return
        }

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            device.torchMode = AVCaptureDevice.TorchMode.on
            device.torchMode = AVCaptureDevice.TorchMode.off

            do {
                try device.setTorchModeOn(level: 1.0)
            } catch {
                self.taskDelegate?.torchError()
            }

            device.unlockForConfiguration()
        } catch {
            self.taskDelegate?.torchError()
        }
    }
}

extension SyncroTaskManager: HREventsDelegate {
    func beatDetected(withHR HR: Float, andTotalMeasuredTime seconds: Float) {
    }

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float) {
        SyncroTaskManager.instantBpms.append(instantBPM)
        SyncroTaskManager.averageBpms.append(averageBPM)

        taskDelegate?.beatDetected(withInstantBPM: instantBPM, andAverageBPM: averageBPM)
    }

    func fingerPresentChanged(_ isPresent: Bool) {
        taskDelegate?.fingerPresentChanged(isPresent)

    }

    // nothing here...
    func newPPGSampleReady(_ sample: Float) {
        taskDelegate?.newPPGSampleReady(sample)
    }

    // nothing here...
    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float) {
        self.taskDelegate?.reportHRVActivation(activation, withMaxPeriod: max, andMinPeriod: min)
    }
}
