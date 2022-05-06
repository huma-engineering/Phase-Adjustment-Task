//
//  Platform.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 17/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

struct Platform {
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
          return true
        #else
           return false
        #endif
    }()
}
