//
//  ExitScreen.swift
//  InteroceptionProto
//
//  Created by Joel Barker on 20/01/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import SwiftUI
import os

struct ExitScreen: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Thank you for your time - feel free to come back if you want to get in sync with your heartbeat!")
                .padding([.horizontal], UIUtils.defaultVPadding)
                .multilineTextAlignment(.center)

                Spacer().frame(height: 50)

                Spacer().frame(height: 50)
                Button(action: {
                    let urlStr = "https://docs.google.com/forms/d/e/1FAIpQLSecxV1tfTjPIbVPf54SmIeMdAQVzy1f5qcWqPnghqFun_R9FA/viewform?usp=sf_link"
                    guard
                        let url = URL(string: urlStr)
                    else {
                        os_log("Invalid URL: %s", log: OSLog.network, type: .error, urlStr)
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
                Spacer().frame(height: 40)
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct ExitScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExitScreen()
    }
}
