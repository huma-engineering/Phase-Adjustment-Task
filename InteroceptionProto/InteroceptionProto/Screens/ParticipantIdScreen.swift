//
//  ParticipantIdScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 17/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import UIKit
import os

final class ParticipantIdModel: NSObject, ObservableObject {

    @Published var partiId = ""

    @Published var haveData = false

    @Published var showActivity = true
}

struct ParticipantIdScreen<Content>: View where Content: View {
    let content: Content
    let controller: ScreenController
    @ObservedObject var partiViewModel = ParticipantIdModel()

    @State private var havePartiId = false

    init(@ViewBuilder content: () -> Content, controller: ScreenController) {
        self.content = content()
        self.controller = controller

        let previousData = InteroceptionDataset.hasPreviousData()

        self.partiViewModel.haveData = previousData
    }

    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer().frame(height: 50)
                content
                Spacer()
                    .frame(height: 150.0)
                HStack(alignment: .center) {
                    TextField("ParticipantId", text: $partiViewModel.partiId, onCommit: {() in
                        if self.$partiViewModel.partiId.wrappedValue != "" {
                            self.$havePartiId.wrappedValue = true
                        }

                    })
                    .frame(width: 170.0)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all, UIUtils.defaultVPadding)
                }

                ActivityIndicatorView(isShowing: $partiViewModel.showActivity) {
                    NavigationView {
                        Text("")
                    }
                }

                Spacer().frame(height: 200)

                Button(action: {
                    withAnimation {
                        controller.nextScreen()
                    }
                }, label: {
                    Text("_onboarding_continue_button_label")
                })
                .modifier(UIUtils.ButtonContinueLabelStyle())
                .cornerRadius(10)
                .padding(.bottom, UIUtils.defaultVPadding)
                .opacity(havePartiId ? 1 : 0)
            }
        }.onAppear {
            UIApplication.shared.isIdleTimerDisabled = true

            UserManager.shared.loginOrSignUpAnon { (errorStr: String) in
                os_log("Failed loading the data %s", log: OSLog.firebase, type: .error, errorStr)
                self.partiViewModel.showActivity = false
            }
        }.onDisappear {
            let enteredParticpantID = self.$partiViewModel.partiId.wrappedValue
            let uniqueID = UserDetails.shared.participantIDs?.ensureUniquePartipantID(proposedID: enteredParticpantID)
            let hasCompletedAlready = UserDetails.shared.participantIDs!.timesCompleted(uniqueID: uniqueID!) > 0
            print("\(uniqueID!) has already completed the task at least once \(hasCompletedAlready)")
            NotificationCenter.default.post(
                name: .storeParticipant,
                object: Participant(
                    uuid: UserManager.signedInUser?.uuid,
                    participant: uniqueID ?? enteredParticpantID
                )
            )
        }
        .foregroundColor(Color.mainFgColor)
    }
}

extension ParticipantIdModel {

    func getAllUsers () {

        UserDetails.shared.getAllUuids { (uuids: [String: InteroceptionDataset], errorStr: String) in
            if !errorStr.isEmpty {
                os_log("Get all UUIS Failed %s", log: OSLog.firebase, type: .error, errorStr)
            }
            for (uuid, dataSet) in uuids {
                os_log("--------------------------------", log: OSLog.firebase, type: .info)
                os_log("UUID : %s", log: OSLog.firebase, type: .info, uuid)
                os_log("%s", log: OSLog.firebase, type: .info, dataSet.toCSV())
                os_log("--------------------------------", log: OSLog.firebase, type: .info)
            }
        }
    }
}

struct ParticipantIdScreen_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantIdScreen(content: {
            Text("_participantId")
        }, controller: ScreenController())
    }
}
