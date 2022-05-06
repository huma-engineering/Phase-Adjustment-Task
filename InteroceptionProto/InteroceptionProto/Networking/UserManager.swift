//
//  UserManager.swift
//  InteroceptionPrototype
//
//  Created by Joel Barker on 20/06/2019.
//  Copyright © 2019 Biobeats. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import os

class UserManager {

    static let shared = UserManager()

    static var signedInUser: User?

    static let keyUID = "keyUid"

    func loginOrSignUpAnon (completionClosure: @escaping (_ errorStr: String) -> Void) {
        if UserDefaults.standard.object(forKey: "firstRun") == nil {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set("0", forKey: "firstRun")
        }

        if let uuid = KeychainWrapper.standard.string(forKey: UserManager.keyUID) {
            UserDetails.shared.getExisitingParticipants(uuid: uuid) {
                os_log("already signed in. UUID: %s", log: OSLog.firebase, type: .info, uuid)

                UserDetails.shared.storeAnyValueForKey(key: "isAnonUser", value: false, uid: uuid)

                UserDetails.shared.getUsersBlockByUuid(uuid: uuid) { (matesGot: [User], errorStr: String) in
                    os_log("Users in same block: %d", log: OSLog.firebase, type: .info, matesGot.count)
                    if matesGot.count > 0 {
                        UserManager.signedInUser = matesGot.first!
                    }

                    completionClosure(errorStr)
                }
            }
        } else {
            self.signInAnon { (errorStr: String) in
                completionClosure(errorStr)
            }
        }
    }

    func signInAnon (completionClosure: @escaping (_ errorStr: String) -> Void) {

        Auth.auth().signInAnonymously { (authResult, error) in
            if let err = error {
                os_log("anon sign in error: %s", log: OSLog.firebase, type: .info, err.localizedDescription)
                completionClosure(err.localizedDescription)
            } else {
                let user = authResult?.user
                let uuid = user?.uid

                UserDetails.shared.getExisitingParticipants(uuid: uuid!) {
                    os_log("Signed up as UUID: %s", log: OSLog.firebase, type: .info, uuid!)
                    os_log("IsSignedIn: %s", log: OSLog.firebase, type: .info, UserDetails.shared.isSignedIn())

                    let _: Bool = KeychainWrapper.standard.set(uuid!, forKey: UserManager.keyUID)

                    let anonUser = User(theUuid: uuid!)
                    anonUser.isAnonUser = true
                    UserManager.signedInUser = anonUser

                    UserDetails.shared.storeAnyValueForKey(key: "isAnonUser", value: true, uid: uuid!)

                    completionClosure("")
                }
            }
        }
    }

    func handleIsSignedIn(completionClosure: @escaping (_ errorStr: String) -> Void) {
        os_log("alreadySignedIn", log: OSLog.firebase, type: .info)

        do {
            let uuid = try UserDetails.shared.getUuid()
            os_log("UUID: %s", log: OSLog.firebase, type: .info, uuid)

            UserDetails.shared.storeAnyValueForKey(key: "isAnonUser", value: false, uid: uuid)
            UserDetails.shared.getUsersBlockByUuid(uuid: uuid) { (matesGot: [User], errorStr: String) in
                os_log("Block UUID size: %d", log: OSLog.firebase, type: .info, matesGot.count)

                if matesGot.count > 0 {
                    UserManager.signedInUser = matesGot.first!
                }

                completionClosure(errorStr)
            }
        } catch {
            completionClosure("getUUIDFailed")
        }
    }

    func loginOrSignUp (userName: String, passWord: String, completionClosure: @escaping (_ errorStr: String) -> Void) {

        UserDetails.shared.logUserOut()

        KeychainWrapper.standard.removeAllKeys()
        os_log("Username %s", log: OSLog.firebase, type: .info, userName)

        if UserDetails.shared.isSignedIn() {
            handleIsSignedIn(completionClosure: completionClosure)
        } else {

            let email = userName

            self.signIn(email: email, password: passWord) { (errorStr: String?, uuid: String?) in

                if let uid = uuid {
                    os_log("Sign in with e-mail success for %s", log: OSLog.firebase, type: .info, uid)
                    UserDetails.shared.storeAnyValueForKey(key: "isAnonUser", value: false, uid: uid)

                    UserDetails.shared.getUsersBlockByUuid(uuid: uid) { (matesGot: [User], errorStr: String) in
                        os_log("Block UUID size: %d", log: OSLog.firebase, type: .info, matesGot.count)

                        if matesGot.count > 0 {
                            UserManager.signedInUser = matesGot.first
                        }

                        completionClosure(errorStr)
                    }
                    return
                }
                if let err = errorStr {
                    os_log("Sign in with e-mail failed for %s", log: OSLog.firebase, type: .info, err)
                }

                self.doSignUp(email: email, password: passWord) { (errorStr: String, uuid: String?) in
                    if errorStr.isEmpty {
                        os_log("UUID: %s", log: OSLog.firebase, type: .info, uuid!)
                        UserDetails.shared.storeAnyValueForKey(key: "isAnonUser", value: false, uid: uuid!)

                        UserManager.signedInUser = User(theUuid: uuid!)
                    } else {
                        os_log("signUpError: %s", log: OSLog.firebase, type: .info, errorStr)
                    }
                    os_log("IsSignedIn: %s", log: OSLog.firebase, type: .info, UserDetails.shared.isSignedIn())

                    UserManager.signedInUser?.isAnonUser = false
                    completionClosure(errorStr)
                }
            }
        }
    }

    func signIn (email: String, password: String, completionClosure: @escaping (_ errorStr: String?, _ uuidGot: String?) -> Void) {

        let emailCreds = EmailAuthProvider.credential(withEmail: email, password: password)

        Auth.auth().signIn(with: emailCreds) { (_, error) in

            if let error = error {
                os_log("sign in: %s", log: OSLog.firebase, type: .info, error.localizedDescription)
                completionClosure(error.localizedDescription, nil)
                return
            }

            do {
                let uuid = try UserDetails.shared.getUuid()
                let _: Bool = KeychainWrapper.standard.set(uuid, forKey: UserManager.keyUID)
                os_log("Logged in Okay with UUID: %s", log: OSLog.firebase, type: .info, uuid)
                UserManager.signedInUser?.uuid = uuid

                completionClosure(nil, uuid)

            } catch {
                completionClosure("getUUIDFailed", nil)
            }
        }
    }

    func doSignUp(email: String, password: String, completionClosure: @escaping (_ errorStr: String, _ uuid: String?) -> Void) {
        let uuidMade = ""
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            if let err = error {
                os_log("signup error: %s", log: OSLog.firebase, type: .info, err.localizedDescription)
                completionClosure(err.localizedDescription, uuidMade)
                return
            }

            let emailCreds = EmailAuthProvider.credential(withEmail: email, password: password)

            Auth.auth().signIn(with: emailCreds) { (_, error) in
                if let err = error {
                    os_log("sign in error: %s", log: OSLog.firebase, type: .info, err.localizedDescription)
                    completionClosure(err.localizedDescription, uuidMade)
                    return
                }

                do {
                    let uuid = try UserDetails.shared.getUuid()
                    os_log("uuid signing in: %s", log: OSLog.firebase, type: .info, uuid)
                    let _: Bool = KeychainWrapper.standard.set(uuid, forKey: UserManager.keyUID)
                    completionClosure("signUpOK", uuid)

                } catch {
                    completionClosure("getUUIDFailed", nil)
                }
            }
        }
    }

    func fullyLogout () {
        UserDetails.shared.logUserOut()
        KeychainWrapper.standard.removeAllKeys()
    }
}
