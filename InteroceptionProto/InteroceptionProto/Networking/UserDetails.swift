//
//  UserDetails.swift
//  InteroceptionPrototype
//
//  Created by Joel Barker on 20/06/2019.
//  Copyright © 2019 Biobeats. All rights reserved.
//

import UIKit
import Firebase
import os

struct UserDetailsError: Error {
    let message: String
}

class UserDetails {
    static let shared = UserDetails()

    var participantIDs: Participants?
    let userDataPath = "users/protoprolific"

    func isSignedIn() -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }

        return !user.isAnonymous
    }

    func getUuid() throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw UserDetailsError(message: "No current user. Cannot get UID")
        }

        return user.uid
    }

    func getExisitingParticipants(uuid: String, completionClosure: @escaping () -> Void) {
        let ref = Database.database().reference(withPath: userDataPath)

        let thisUserOnly = ref.child(uuid)
        thisUserOnly.observeSingleEvent(of: .value, with: { snapshot in
            let vals = snapshot.value as? NSDictionary?
            if let usersWithSameUID = vals as? [String: Any] {
                self.participantIDs = Participants(usersWithSameUID)
            } else {
                let blank: [String: Any] = [:]
                self.participantIDs = Participants(blank)
            }
            completionClosure()
        })
    }

    func getUsersBlockByUuid(uuid: String, completionClosure: @escaping (_ users: [User], _ errorStr: String) -> Void) {
        var uuidFind = uuid

        if uuid == "" {
            os_log("UUID empty", log: OSLog.data, type: .fault)
            uuidFind = "EMPTYUUID"
        }

        let ref = Database.database().reference(withPath: userDataPath)

        let thisUserOnly = ref.child(uuidFind)
        var users: [User] = []
        thisUserOnly.observeSingleEvent(of: .value, with: { snapshot in
            let vals = snapshot.value as? NSDictionary?
            var errorStr = ""
            if vals != nil {
                let user = User(theUuid: uuid)

                users.append(user)
            } else {
                errorStr = "user not found : " + uuidFind
            }

            completionClosure(users, errorStr)
        })
    }

    func storeAnyValueForKey(key: String, value: Any, uid: String) {
        os_log("storing %s key %s for UID %s", log: OSLog.firebase, type: .info, key, String(describing: value), uid)

        let ref =  Database.database().reference(withPath: userDataPath)
        let thisUserOnly = ref.child(uid)

        thisUserOnly.updateChildValues([key: value])
    }

    func storeAnyValueForKeyWithCompl(key: String, value: Any, uid: String, completionClosure: @escaping (_ errorStr: Error?) -> Void) {
        var keyUse = key.replacingOccurrences(of: ".", with: "")
        keyUse = key.replacingOccurrences(of: "#", with: "")
        keyUse = key.replacingOccurrences(of: "$", with: "")
        keyUse = key.replacingOccurrences(of: "[", with: "")
        keyUse = key.replacingOccurrences(of: "]", with: "")

        let ref =  Database.database().reference(withPath: userDataPath)
        let thisUserOnly = ref.child(uid)

        thisUserOnly.updateChildValues([keyUse: value]) {(error: Error?, _) in
            if let error = error {
                completionClosure(error)
            } else {
                completionClosure(error)
            }
        }
    }

    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error while signing out!")
        }
    }

    func getAllUuids(completionClosure: @escaping (_ uuids: [String: InteroceptionDataset], _ errorStr: String) -> Void) {
        let ref =  Database.database().reference(withPath: userDataPath)

        ref.observeSingleEvent(of: .value, with: { snapshot in
            var uuidsGot: [String: InteroceptionDataset] = [:]

            let vals = snapshot.value as? NSDictionary?

            for (key, itemVals) in vals!! {
                guard
                    let keyStr = key as? String,
                    let itemDict = itemVals as? NSDictionary
                else {
                    continue
                }
                let dataDict = InteroceptionDataset.load(fromDict: itemDict)
                uuidsGot [keyStr] = dataDict
            }
            completionClosure(uuidsGot, "")
        })
    }
}
