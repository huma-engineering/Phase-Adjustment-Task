//
//  FinalScreen.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 06/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI
import MessageUI
import os

struct RedirectButton: View {
    private let participantID: String

    init(participant: String) {
        self.participantID = participant
    }

    var body: some View {
        Button(action: {
            let participant = participantID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let hasCompletedAlready = UserDetails.shared.participantIDs!.timesCompleted(uniqueID: participant) > 0

            var stringUrl: String
            if hasCompletedAlready {
                stringUrl = "https://app.prolific.co/submissions/complete?cc=YFECRJH5=\((participant).dropLast(2))"
            } else {
                stringUrl =
                    "https://app.prolific.co/submissions/complete?cc=YFECRJH5=\(participant)"
            }
            guard let url = URL(string: stringUrl) else {
                os_log("Invalid URL", log: OSLog.network, type: .fault)
                return
            }
            UIApplication.shared.open(url)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        }, label: {
            Text("Exit")
        })
        .padding()
        .background(Color.red)
        .font(.title)
        .foregroundColor(.white)
    }
}

struct FinalScreen: View {
    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("_thank_you_prolific_redirect")
                .padding([.horizontal], UIUtils.defaultVPadding)
                .multilineTextAlignment(.center)

                Spacer()

                RedirectButton(participant: DataController.shared.participant)
            }
            .padding(.all, UIUtils.defaultVPadding)
            .foregroundColor(.mainFgColor)
        }.onAppear {
            NotificationCenter.default.post(name:.storeTaskCompleted, object: nil)
        }
    }
}

struct FinalScreen_Previews: PreviewProvider {
    static var previews: some View {
        FinalScreen()
    }
}
