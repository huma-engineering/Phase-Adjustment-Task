//
//  InteroceptionDataset.swift
//  Interoceptor
//
//  Created by Gabriele Cocco on 10/04/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import Foundation
import SwiftDate
import os

class BaseLineDataset {

    var date: Date?

    var recordedHR: [Float] = []
    var instantBpms: [Float] = []

    func equals (other: BaseLineDataset) -> Bool {
        if self.date != other.date {
            return false
        }

        if self.recordedHR != other.recordedHR {
            return false
        }

        if self.instantBpms != other.instantBpms {
            return false
        }

        return true
    }

    fileprivate static func fromDictionary(dictionary: [String: Any]) -> BaseLineDataset {

        let data = BaseLineDataset()

        if let datas = dictionary["recordedHR"] as? [Float] {
            data.recordedHR = datas
        }

        if let datas = dictionary["instantBpms"] as? [Float] {
            data.instantBpms = datas
        }

        if let date = dictionary["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let updatedAt = dateFormatter.date(from: date) // "Jun 5, 2016, 4:56 PM"
            data.date = updatedAt
        }

        if let date = dictionary["date"] as? Date {
            data.date = date
        }
        return data
    }

    fileprivate func toDictionary() -> [String: Any] {
           return [
                    "recordedHR": recordedHR,
                    "instantBpms": instantBpms,
                    "date": date!
           ]
       }

    fileprivate func toFirebaseDictionary() -> [String: Any] {
        return [
                 "recordedHR": recordedHR,
                 "instantBpms": instantBpms,
                 "date": date!.toISO()
        ]
    }

    fileprivate func toCSV () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        var csvString = dateFormatter.string(from: self.date!)  + ";"
        csvString += "\n"
        csvString += "recordedHR;"

        for heartRate in recordedHR {
            csvString += heartRate.description + ";"
        }

        csvString += "\n"

        csvString += "instantBpms;"

        for bpm in instantBpms {
            csvString += bpm.description + ";"
        }

        csvString += "\n"

        return csvString
    }

}

class SyncroTrialDataset {

    var date: Date?

    var confidence: Int = -1
    var bodyPos: Int = -1

    var recordedHR: [Float] = []
    var instantBpms: [Float] = []
    var instantPeriods: [Double] = []
    var averagePeriods: [Double] = []
    var instantErrs: [Double] = []
    var knobScales: [Double] = []
    var currentDelays: [Double] = []

    func equals (other: SyncroTrialDataset) -> Bool {
        if self.date != other.date {
            return false
        }

        if self.confidence != other.confidence {
            return false
        }

        if self.bodyPos != other.bodyPos {
            return false
        }

        if self.recordedHR != other.recordedHR {
            return false
        }

        if self.instantBpms != other.instantBpms {
            return false
        }

        if self.instantPeriods != other.instantPeriods {
            return false
        }

        if self.averagePeriods != other.averagePeriods {
            return false
        }

        if self.instantErrs != other.instantErrs {
            return false
        }

        if self.knobScales != other.knobScales {
            return false
        }

        if self.currentDelays != other.currentDelays {
            return false
        }

        return true
    }

    fileprivate static func fromDictionary(dictionary: [String: Any]) -> SyncroTrialDataset {

        let data = SyncroTrialDataset()

        data.recordedHR = dictionary["recordedHR"] as? [Float] ?? []
        data.instantBpms = dictionary["instantBpms"] as? [Float] ?? []
        data.instantPeriods = dictionary["instantPeriods"] as? [Double] ?? []
        data.averagePeriods = dictionary["averagePeriods"] as? [Double] ?? []
        data.instantErrs = dictionary["instantErrs"] as? [Double] ?? []
        data.knobScales = dictionary["knobScales"] as? [Double] ?? []
        data.currentDelays = dictionary["currentDelays"] as? [Double] ?? []

        data.bodyPos = dictionary["bodyPos"] as? Int ?? -1
        data.confidence = dictionary["confidence"] as? Int ?? -1

        data.date = dictionary["date"] as? Date

        if let date = dictionary["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let updatedAt = dateFormatter.date(from: date) // "Jun 5, 2016, 4:56 PM"
            data.date = updatedAt
        }

        return data
    }

    fileprivate func toDictionary() -> [String: Any] {
        return [
                 "recordedHR": recordedHR,
                 "instantBpms": instantBpms,
                 "instantPeriods": instantPeriods,
                 "averagePeriods": averagePeriods,
                 "instantErrs": instantErrs,
                 "knobScales": knobScales,
                 "currentDelays": currentDelays,
                 "confidence": confidence,
                 "bodyPos": bodyPos,
                 "date": date!
        ]
    }

    fileprivate func toFirebaseDictionary() -> [String: Any] {
        return [
                 "recordedHR": recordedHR,
                 "instantBpms": instantBpms,
                 "instantPeriods": instantPeriods,
                 "averagePeriods": averagePeriods,
                 "instantErrs": instantErrs,
                 "knobScales": knobScales,
                 "currentDelays": currentDelays,
                 "confidence": confidence,
                 "bodyPos": bodyPos,
                 "date": date!.toISO()
        ]
    }

    fileprivate func toCSV () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        var csvString = self.confidence.description + ";" + bodyPos.description + ";"
        csvString += dateFormatter.string(from: self.date!)  + ";"
        csvString += "\n"
        csvString += "recordedHR;"

        for heartRate in recordedHR {
            csvString += heartRate.description + ";"
        }

        csvString += "\n"
        csvString += "instantBpms;"

        for bpm in instantBpms {
            csvString += bpm.description + ";"
        }

        csvString += "\n"
        csvString += "instantPeriods;"

        for period in instantPeriods {
            csvString += period.description + ";"
        }

        csvString += "\n"
        csvString += "averagePeriods;"

        for period in averagePeriods {
            csvString += period.description + ";"
        }

        csvString += "\n"
        csvString += "instantErrs;"

        for error in instantErrs {
            csvString += error.description + ";"
        }

        csvString += "\n"
        csvString += "knobScales;"

        for scale in knobScales {
            csvString += scale.description + ";"
        }

        csvString += "\n"
        csvString += "currentDelays;"

        for delay in currentDelays {
            csvString += delay.description + ";"
        }

        csvString += "\n"

        return csvString
    }

}

class HRGatherDataset {
    var samples: [Double] = []
    var date: Date?

    fileprivate static func fromDictionary(dictionary: [String: Any]) -> HRGatherDataset {
        let data = HRGatherDataset()
        data.samples = dictionary["samples"] as? [Double] ?? []
        data.date = dictionary["date"] as? Date

        return data
    }

    fileprivate func toDictionary() -> [String: Any] {
        return [ "samples": samples,
                 "date": date! ]
    }

    fileprivate func toFirebaseDictionary() -> [String: Any] {
        return [ "samples": samples,
                 "date": date!.toISO() ]
    }
}

class HDTRunDataset {
    var delayed: Bool = false
    var guessedDelayed: Bool = false
    var confidence: Float = 0
    var recordedRR: [Double] = []
    var date: Date?

    fileprivate static func fromDictionary(dictionary: [String: Any]) -> HDTRunDataset {
        let data = HDTRunDataset()
        if let delayed = dictionary["delayed"] as? Bool {
            data.delayed = delayed
        }
        if let guessed = dictionary["guessedDelayed"] as? Bool {
            data.guessedDelayed = guessed
        }
        if let recorded = dictionary["recordedRR"] as? [Double] {
            data.recordedRR = recorded
        }
        if let conf = dictionary["confidence"] as? Float {
            data.confidence = conf
        }
        if let date = dictionary["date"] as? Date {
            data.date = date
        }
        return data
    }

    fileprivate func toDictionary() -> [String: Any] {
        return [ "delayed": delayed,
                 "guessedDelayed": guessedDelayed,
                 "recordedRR": recordedRR,
                 "confidence": confidence,
                 "date": date! ]
    }

    fileprivate func toFirebaseDictionary() -> [String: Any] {
        return [ "delayed": delayed,
                 "guessedDelayed": guessedDelayed,
                 "recordedRR": recordedRR,
                 "confidence": confidence,
                 "date": date!.toISO() ]
    }
}

class InteroceptionDataset {

    var participantID: String
    var uuid: String

    var startDate: Date
    var endDate: Date?

    var numRuns: Int?

    var baselines: [BaseLineDataset] = []

    var baselineRR: [HRGatherDataset] = []
    var postTrainingRR: [HRGatherDataset] = []
    var baselineHDT: [HDTRunDataset] = []
    var postTrainingHDT: [HDTRunDataset] = []

    var postSyncroTraining: [HDTRunDataset] = []

    var syncroTraining: [SyncroTrialDataset] = []

    init(date: Date? = nil) {
        self.participantID = ""
        self.uuid = ""
        startDate = (date != nil) ? date! : Date()
    }

    init(participant: String, date: Date? = nil) {
        participantID = participant
        self.uuid = ""

        startDate = (date != nil) ? date! : Date()
    }

    static func wipePreviousData () {
        UserDefaults.standard.removeObject(forKey: "dataset")
    }

    static func hasPreviousData () -> Bool {
        return UserDefaults.standard.object(forKey: "dataset") as? [String: Any] != nil
    }

    static func load() -> InteroceptionDataset? {
        if let dict = UserDefaults.standard.object(forKey: "dataset") as? [String: Any] {
            return InteroceptionDataset.fromDictionary(dictionary: dict)
        }
        return nil
    }

    static func load(fromDict: NSDictionary) -> InteroceptionDataset? {
        var dataDict: [String: Any] = [:]
        for (_, itemVals) in fromDict {
            guard
                let itemDict = itemVals as? NSDictionary
            else {
                continue
            }

            for (itemDictKey, itemDictVals) in itemDict {
                guard
                    let itemDictKeyStr = itemDictKey as? String
                else {
                    continue
                }
                dataDict[itemDictKeyStr] = itemDictVals
            }
        }

        return InteroceptionDataset.fromDictionary(dictionary: dataDict)

    }

    func toCSV () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        var csvString = self.participantID + ";"
        csvString += dateFormatter.string(from: self.startDate)  + ";"

        if self.endDate != nil {
            csvString += dateFormatter.string(from: self.endDate!)  + ";"
        }

        if self.numRuns != nil {
            csvString += numRuns!.description + ";"
        } else {
            csvString += "0;"
        }

        csvString += self.uuid + ";"
        csvString += "\n"

        if self.baselines.count > 0 {
            csvString += "BASELINE;\n"

            for syncTrain in self.baselines {
                csvString += syncTrain.toCSV()
                csvString += "\n"
            }
        }

        if self.syncroTraining.count > 0 {
            csvString += "SYNCRO;\n"

            for syncTrain in self.syncroTraining {
                csvString += syncTrain.toCSV()
                csvString += "\n"
            }

        }

        return csvString
    }

    func storeWithCompletion(completionClosure: @escaping (_ errorStr: String) -> Void) {

        let dataAsDict = self.toFirebaseDictionary()

        let uuid = UserManager.signedInUser?.uuid

        self.store()

        UserDetails.shared.storeAnyValueForKeyWithCompl(key: participantID, value: dataAsDict, uid: uuid!) {(errorStr: Error?) in

            if errorStr != nil {
                completionClosure(errorStr!.localizedDescription)
            } else {
                completionClosure("")
            }
        }
    }

    func store() {
        let dataDict = self.toDictionary()
        print(dataDict)

        UserDefaults.standard.set(dataDict, forKey: "dataset")
        UserDefaults.standard.synchronize()
    }

    fileprivate static func fromDictionary(dictionary: [String: Any]) -> InteroceptionDataset {
        guard
            let participant = dictionary["participantID"] as? String
        else {
            os_log("fromDictionary: ParticpantID not a string", log: OSLog.data, type: .error)
            return InteroceptionDataset(participant: "n/a", date: dictionary["startDate"] as? Date)
        }
        let dataset = InteroceptionDataset(participant: participant, date: dictionary["startDate"] as? Date)

        if let baselineRR = dictionary["baselineRR"] as? [[String: Any]] {
            dataset.baselineRR = baselineRR.map({ (dict) -> HRGatherDataset in
                HRGatherDataset.fromDictionary(dictionary: dict)
            })
        }
        if let baselineHDT = dictionary["baselineHDT"] as? [[String: Any]] {
            dataset.baselineHDT = baselineHDT.map({ (dict) -> HDTRunDataset in
                HDTRunDataset.fromDictionary(dictionary: dict)
            })
        }
        if let postTrainingRR = dictionary["postTrainingRR"] as? [[String: Any]] {
            dataset.postTrainingRR = postTrainingRR.map({ (dict) -> HRGatherDataset in
                HRGatherDataset.fromDictionary(dictionary: dict)
            })
        }
        if let postTrainingHDT = dictionary["postTrainingHDT"] as? [[String: Any]] {
            dataset.postTrainingHDT = postTrainingHDT.map({ (dict) -> HDTRunDataset in
                HDTRunDataset.fromDictionary(dictionary: dict)
            })
        }

        if let baselines = dictionary["baselines"] as? [[String: Any]] {
            dataset.baselines = baselines.map({ (dict) -> BaseLineDataset in
                BaseLineDataset.fromDictionary(dictionary: dict)
            })
        }

        if let syncroTraining = dictionary["syncroTraining"] as? [[String: Any]] {
            dataset.syncroTraining = syncroTraining.map({ (dict) -> SyncroTrialDataset in
                SyncroTrialDataset.fromDictionary(dictionary: dict)
            })
        }

        if let numRuns = dictionary["numRuns"] as? Int {
            dataset.numRuns = numRuns
        }

        if let date = dictionary["endDate"] as? Date {
            dataset.endDate = date
        }
        return dataset
    }

    func toFirebaseDictionary() -> [String: Any] {
        var dict = [ "participantID": participantID,
                  "startDate": startDate.toISO() ] as [String: Any]

        if let date = endDate {
            dict["endDate"] = date.toISO()
        }

        dict["numRuns"] = numRuns
        dict["uuid"] = self.uuid

        dict["baselineRR"] = baselineRR.map { $0.toFirebaseDictionary() }
        dict["baselineHDT"] = baselineHDT.map { $0.toFirebaseDictionary() }
        dict["postTrainingRR"] = postTrainingRR.map { $0.toFirebaseDictionary() }
        dict["postTrainingHDT"] = postTrainingHDT.map { $0.toFirebaseDictionary() }
        dict["baselines"] = baselines.map { $0.toFirebaseDictionary() }
        dict["syncroTraining"] = syncroTraining.map { $0.toFirebaseDictionary() }

        return dict

    }

    func toDictionary() -> [String: Any] {
        var dict = [ "participantID": participantID,
                  "startDate": startDate ] as [String: Any]

        if endDate != nil {
            dict["endDate"] = endDate
        }

        dict["numRuns"] = numRuns
        dict["baselineRR"] = baselineRR.map { $0.toDictionary() }
        dict["baselineHDT"] = baselineHDT.map { $0.toDictionary() }
        dict["postTrainingRR"] = postTrainingRR.map { $0.toDictionary() }
        dict["postTrainingHDT"] = postTrainingHDT.map { $0.toDictionary() }
        dict["baselines"] = baselines.map { $0.toDictionary() }
        dict["syncroTraining"] = syncroTraining.map { $0.toDictionary() }

        return dict
    }
}
