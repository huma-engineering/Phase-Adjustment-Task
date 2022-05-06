//
//  InteroceptionSettings.swift
//  InteroceptionProto
//
//  Created by Matteo Vigoni on 06/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import UIKit
import Foundation
import os

class InteroceptionSettings: ObservableObject {
    let numberOfTrials: Int
    // first two runs are practices...
    public var currentIndex = -2

    // set to true so the first run will be a practice
    public static var isPracticeRun = true

    public static var practicesToGo = 1

    init(numberOfTrials: Int) {
        self.numberOfTrials = numberOfTrials
        if let numRuns = DataController.shared.data.numRuns {
            if self.currentIndex == -2 {
                self.currentIndex = numRuns
                InteroceptionSettings.practicesToGo = 0 - self.currentIndex
            }
        }
    }

    func next() {
        currentIndex += 1
        NotificationCenter.default.post(name: .storeNumRuns, object: currentIndex)
    }

    func isLastTrial() -> Bool {
        return currentIndex == numberOfTrials-1
    }
}
