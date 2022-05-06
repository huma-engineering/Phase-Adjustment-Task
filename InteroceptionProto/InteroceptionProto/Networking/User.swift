//
//  User.swift
//  InteroceptionPrototype
//
//  Created by Joel Barker on 20/06/2019.
//  Copyright © 2019 Biobeats. All rights reserved.
//

import UIKit

@objc
class User: NSObject {

    @objc
    var uuid = ""
    var isAnonUser = false

    init (theUuid: String) {
        super.init()
        self.uuid = theUuid
    }
}
