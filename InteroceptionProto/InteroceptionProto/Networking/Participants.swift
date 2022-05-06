//
//  ParticipantIDs.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 15/05/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import Foundation

struct Participants {
    let loadedUIDMatches: [String: Any]

    init (_ loadedUIDs: [String: Any]) {
        loadedUIDMatches = loadedUIDs
    }

    func ensureUniquePartipantID(proposedID: String) -> String {
        let matchingUsers = loadedUIDMatches.reduce(0, { $0 + ($1.key.starts(with: proposedID) ? 1: 0)})
        print("\(proposedID) \(matchingUsers)")

        guard matchingUsers > 0 else {
            return proposedID
        }

        return proposedID + "_" + matchingUsers.description
    }

    func timesCompleted(uniqueID: String) -> Int {
        let iDPrefix = uniqueID.contains("_") ? String(uniqueID.split(separator: "_")[0]) : uniqueID
        let matchingUsers = loadedUIDMatches.filter({$0.key.starts(with: iDPrefix)})

        // swiftlint:disable syntactic_sugar
        let numWithEndDate = matchingUsers.reduce(0, {(count: Int, element: Dictionary<String, Any>.Element) -> Int in
            if let dict = element.value as? [String: Any] {
                return dict["endDate"] != nil ? count + 1 : count
            }

            return count
        })

        return numWithEndDate
    }
}
