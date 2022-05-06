//
//  RootView.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 06/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI
import os

enum TaskViews: String, Decodable {
    case id = "ID"
    case onboarding = "Onboarding"
    case baseline = "Baseline"
    case trial = "Trial"
    case end = "End"
}

class ScreenController: ObservableObject {
    private var screens = loadScreenOrder()!
    @Published var currentScreen: Screen

    init() {
        currentScreen = screens.currentScreen
    }

    func nextScreen() {
        currentScreen = screens.moveToNextScreen()
    }
}

struct RootView: View {
    @ObservedObject var controller = ScreenController()

    var body: some View {
        let screen = controller.currentScreen
        switch screen.type {
        case .id:
            PartiIdScreen(controller: controller)
        case .onboarding:
            if let pages = screen.pages as? [OnboardingPage] {
                Onboarding(pages: pages, controller: controller)
            } else {
                EmptyView()
            }
        case .baseline:
            BaselineDataScreen(controller: controller)
        case .trial:
            if let pages = screen.pages as? [TrialPage] {
                TrialViews(pages: pages, trials: screen.trials!, controller: controller)
            } else {
                EmptyView()
            }
        case .end:
            FinalScreen()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
