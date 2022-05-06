//
//  DataController.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 14/07/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import Foundation
import os
import SwiftUI

extension Notification.Name {
    static var recordSyncro: Notification.Name {
        return .init(rawValue: "DataController.RecordSyncro")
    }

    static var recordBaseline: Notification.Name {
        return .init(rawValue: "DataController.RecordBaseline")
    }

    static var recordConfidence: Notification.Name {
        return .init(rawValue: "DataController.RecordConfidence")
    }

    static var storeParticipant: Notification.Name {
        return .init(rawValue: "DataController.RecordParticipant")
    }

    static var storeNumRuns: Notification.Name {
        return .init(rawValue: "DataController.StoreNumRuns")
    }

    static var storeBodyPosition: Notification.Name {
        return .init(rawValue: "DataController.StoreBodyPosition")
    }

    static var storeTaskCompleted: Notification.Name {
        return .init(rawValue: "DataController.TaskCompleted")
    }
}

struct Participant {
    let uuid: String?
    let participant: String
}

class DataController {
    public static var shared = DataController()

    private var dataset: InteroceptionDataset = InteroceptionDataset()

    public var data: InteroceptionDataset {
        return dataset
    }

    public var participant: String {
        return dataset.participantID
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopAndRecordSyncro), name: .recordSyncro, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAndRecordBaseline), name: .recordBaseline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storeConfidence), name: .recordConfidence, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storeParticipant), name: .storeParticipant, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storeNumRuns), name: .storeNumRuns, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storeBodyPosition), name: .storeBodyPosition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taskCompleted), name: .storeTaskCompleted, object: nil)
    }

    @objc
    private func updateDataset(_ notification: Notification) {
        saveData()
    }

    private func saveData() {
        dataset.store()

        dataset.storeWithCompletion { (errorStr: String) in
            if !errorStr.isEmpty {
                os_log("Data store failed %s", log: OSLog.data, type: .error, errorStr)
            }
        }
    }

    @objc
    func taskCompleted() {
        let participant = dataset.participantID
        let hasCompletedAlready = UserDetails.shared.participantIDs!.timesCompleted(uniqueID: participant) > 0
        os_log("%s has already completed the task at least once %s", log: OSLog.task, type: .info, participant, hasCompletedAlready)

        dataset.endDate = Date()
        saveData()
    }

    @objc
    func stopAndRecordSyncro(_ notification: Notification) {
        guard
            let taskData = notification.object as? SyncroTrialDataset
        else {
            os_log("Syncro data was not a SyncroTrialDataset", log: OSLog.data, type: .error)
            saveData()
            return
        }

        dataset.syncroTraining.append(taskData)
        saveData()
        // TODO does this order make sense?
        dataset.syncroTraining.last?.recordedHR = SyncroTaskManager.instantBpms
        dataset.syncroTraining.last?.instantBpms = SyncroTaskManager.averageBpms
    }

    @objc
    func stopAndRecordBaseline(_ notification: Notification) {
        let taskData = BaseLineDataset()

        taskData.date = Date()

        taskData.recordedHR = SyncroTaskManager.averageBpms
        taskData.instantBpms = SyncroTaskManager.instantBpms

        dataset.baselines.append(taskData)
        saveData()
    }

    @objc
    func storeConfidence(_ notifcation: Notification) {
        guard
            let confidence = notifcation.object as? Int
        else {
                os_log("Confidence data was not an int ", log: OSLog.data, type: .error)
                saveData()
                return

        }
        dataset.syncroTraining.last!.confidence = confidence
        saveData()
    }

    @objc
    func storeParticipant(_ notification: Notification) {
        guard
            let participant = notification.object as? Participant
        else {
            os_log("Participant notifcation object was not a Participant", log: OSLog.data, type: .error)
            saveData()
            return
        }

        dataset.participantID = participant.participant
        dataset.uuid = participant.uuid ?? ""
        saveData()
    }

    @objc
    func storeNumRuns(_ notification: Notification) {
        guard
            let runs = notification.object as? Int
        else {
            os_log("Runs notifcation object was not an Int", log: OSLog.data, type: .error)
            saveData()
            return
        }

        dataset.numRuns = runs
        saveData()
    }

    @objc
    func storeBodyPosition(_ notification: Notification) {
        guard
            let bodyPos = notification.object as? Int
        else {
            os_log("Body position object was not an Int", log: OSLog.data, type: .error)
            saveData()
            return
        }

        dataset.syncroTraining.last?.bodyPos = bodyPos
        saveData()
    }
}
