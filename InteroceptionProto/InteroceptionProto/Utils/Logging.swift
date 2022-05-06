//
//  Logging.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 14/07/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let video = OSLog(subsystem: subsystem, category: "video")
    static let network = OSLog(subsystem: subsystem, category: "network")
    static let data = OSLog(subsystem: subsystem, category: "data")
    static let device = OSLog(subsystem: subsystem, category: "os")
    static let task = OSLog(subsystem: subsystem, category: "task")
    static let screens = OSLog(subsystem: subsystem, category: "screens")
    static let firebase = OSLog(subsystem: subsystem, category: "firebase")
    static let motiondetection = OSLog(subsystem: subsystem, category: "motiondetection")
    static let heartdetection = OSLog(subsystem: subsystem, category: "heartdetection")
}
