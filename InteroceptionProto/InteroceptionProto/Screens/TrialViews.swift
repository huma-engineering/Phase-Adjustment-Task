//
//  TrialViews.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 15/06/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import SwiftUI

enum TrialPageType: String, Decodable {
    case dial = "Dial"
    case confidence = "Confidence"
    case body = "Body"
}

class ShowEvery: AppearanceRule {
    var lastShownInTrial = 0
    var showEveryNTrials: Int
    let page: TrialPage

    required init(page: TrialPage) {
        self.page = page
        self.showEveryNTrials = 1
    }

    convenience init(page: TrialPage, showEveryNTrials: Int) {
        self.init(page: page)
        self.showEveryNTrials = showEveryNTrials
    }

    func showPage(currentTrial: Int) -> Bool {
        let trialsSinceShown = currentTrial - lastShownInTrial
        return trialsSinceShown >= showEveryNTrials
    }

    func markShown(currentTrial: Int) {
        lastShownInTrial = currentTrial
    }

    func getPage() -> TrialPage {
        return page
    }
}

class ShowAlways: AppearanceRule {
    let page: TrialPage
    required init(page: TrialPage) {
        self.page = page
    }

    func showPage(currentTrial: Int) -> Bool {
        return true
    }

    func markShown(currentTrial: Int) {}

    func getPage() -> TrialPage {
        return page
    }
}

protocol AppearanceRule {
    init(page: TrialPage)
    func showPage(currentTrial: Int) -> Bool
    func markShown(currentTrial: Int)
    func getPage() -> TrialPage
}

class TrialModel: ObservableObject {
    let trials: [TrialPage]
    @Published var page: Int = 0
    var isEndOfTrials: Bool {
        trials.count - 1 == page
    }

    var currentPage: TrialPage {
        trials[page]
    }

    var nextPage: TrialPage? {
        if isEndOfTrials {
            return nil
        }
        return trials[page + 1]
    }

    init(trials: Int, pages: [TrialPage]) {
        var trialPages: [TrialPage] = []
        let trackers: [AppearanceRule] = pages.map {(page: TrialPage) -> AppearanceRule in
            if page.appears != nil {
                return ShowEvery(page: page, showEveryNTrials: (page.appears!.every))
            }
            return ShowAlways(page: page)
        }

        for index in 1...trials {
            let page = trackers.flatMap {(page: AppearanceRule) -> [TrialPage] in
                if page.showPage(currentTrial: index) {
                    page.markShown(currentTrial: index)
                    return [page.getPage()]
                }
                return []
            }
            trialPages += page
        }

        self.trials = trialPages
    }
}

struct TrialViews: View {
    @ObservedObject var task: TrialModel
    @ObservedObject var interoceptionSettings = InteroceptionSettings(numberOfTrials: 20)
    let controller: ScreenController
    @State var showButton = false

    init (pages: [TrialPage], trials: Int, controller: ScreenController) {
        self.task = TrialModel(trials: trials, pages: pages)
        self.controller = controller
    }

    var canGoForwards: Bool {
        !task.isEndOfTrials
    }

    func nextPage() {
        if canGoForwards {
            task.page += 1
            return
        }
        controller.nextScreen()
    }

    var body: some View {
        Group {
            let page = task.currentPage
            switch page.type {
            case .dial:
                TrialScreen(interoceptionSettings: interoceptionSettings, allowProgress: $showButton)
                    .id(task.page)
                    .transition(.slide)
            case .confidence:
                ConfidenceRatingScreen(interoceptionSettings: interoceptionSettings, allowProgress: $showButton)
                    .id(task.page)
                    .transition(.slide)
            case .body:
                BodyPartsView(interoceptionSettings: interoceptionSettings, hasSelected: $showButton)
                    .id(task.page)
                    .transition(.slide)
            }

            switch page.type {
            case .dial:
                Button(action: {
                    withAnimation {
                        showButton = false
                        nextPage()
                    }
                }, label: {
                    Text("_button_confirm_label")
                })
                .buttonStyle(UIUtils.MyButtonStyle())
                .opacity(showButton ? 1 : 0)
            case .confidence, .body:
                DoublePressButton(action: {
                    withAnimation {
                        showButton = false
                        if !canGoForwards {
                            SyncroTaskManager.shared.stop()
                        } else if task.nextPage?.type == .dial {
                            self.interoceptionSettings.next()
                        }
                        nextPage()
                    }

                })
                .opacity(showButton ? 1 : 0)
            }
        }
    }
}

struct TrialViews_Previews: PreviewProvider {
    static var previews: some View {
        TrialViews(pages: [TrialPage(type: .dial, appears: nil)], trials: 1, controller: ScreenController())
    }
}
