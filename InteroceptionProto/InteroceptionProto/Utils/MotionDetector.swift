//
//  MotionDetector.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 13/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import CoreMotion
import os

final class MotionDetector {
    private static let movementThreshold = 0.2
    private var accAccumulationArray: [Double]?
    private var lastAccX = Double(0)
    private var lastAccY = Double(0)
    private var lastAccZ = Double(0)
    private let accQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "accQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    let manager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 1.0/30.0
        return motionManager
    }()

    func start() {
        manager.startAccelerometerUpdates(to: accQueue) { (data, error) in
            if let err = error {
                os_log("Accelerometer error %s", log: OSLog.motiondetection, type: .error, err.localizedDescription)
            }
            if let accX = data?.acceleration.x, let accY = data?.acceleration.y, let accZ = data?.acceleration.z {
                self.manage(accX: accX, accY: accY, accZ: accZ)
            }
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        clear()
    }

    func checkIsMovingTooMuch(withCallback callback: @escaping (Bool) -> Void) {
        accQueue.addOperation {
            guard let arr = self.accAccumulationArray else {
                callback(false)
                return
            }
            let mean = arr.reduce(0, +)/Double(arr.count)
            self.clear()
            callback(mean > Self.movementThreshold)
        }
    }

    private func manage(accX: Double, accY: Double, accZ: Double) {
        if accAccumulationArray == nil {
            accAccumulationArray = Array()
        }
        let magnitude = sqrt(pow((accX - lastAccX), 2) + pow((accY - lastAccY), 2) + pow((accZ - lastAccZ), 2))
        accAccumulationArray?.append(magnitude)
        lastAccX = accX
        lastAccY = accY
        lastAccZ = accZ
    }

    private func clear() {
        accQueue.addOperation {
            self.accAccumulationArray = nil
            self.lastAccX = 0
            self.lastAccY = 0
            self.lastAccZ = 0
        }
    }
}
