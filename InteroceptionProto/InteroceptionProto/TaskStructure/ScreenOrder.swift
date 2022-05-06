//
//  ScreenOrder.swift
//  InteroceptionProto
//
//  Created by Tom Piercy on 10/06/2021.
//  Copyright © 2021 BioBeats. All rights reserved.
//

import Foundation

struct ScreenData: Decodable {
    let text: String?
    let image: String?
    let video: String?

    init(text: String) {
        self.text = text
        image = nil
        video = nil
    }
}

struct OnboardingPage: ViewPage {
    let type: OnboardingPageType
    let data: ScreenData?

    init(type: OnboardingPageType, data: ScreenData) {
        self.type = type
        self.data = data
    }
}

struct TrialPageAppearanceRules: Decodable {
    let every: Int
}

struct TrialPage: ViewPage {
    let type: TrialPageType
    let appears: TrialPageAppearanceRules?

    init(type: TrialPageType, appears: TrialPageAppearanceRules?) {
        self.type = type
        self.appears = appears
    }
}

public protocol ViewPage: Decodable {
}

struct Screen: Decodable {
    let type: TaskViews
    let pages: [ViewPage]?
    let trials: Int?

    enum CodingKeys: String, CodingKey {
        case type
        case pages
        case trials
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(TaskViews.self, forKey: .type)
        var possiblePages = try? values.decode([OnboardingPage].self, forKey: .pages) as [ViewPage]
        if possiblePages == nil {
            possiblePages = try? values.decode([TrialPage].self, forKey: .pages) as [ViewPage]
        }
        pages = possiblePages
        trials = try? values.decode(Int.self, forKey: .trials)
    }
}

struct ScreenOrder: Decodable {
    let screens: [Screen]
    var index = 0
    var currentScreen: Screen {
        screens[index]
    }

    mutating func moveToNextScreen() -> Screen {
        self.index += 1
        return currentScreen
    }
}

func loadScreenOrder() -> ScreenOrder? {
    let decoder = JSONDecoder()
    guard
        let url = Bundle.main.url(forResource: "screenorder", withExtension: "json")
    else {
        print("screenorder.json path not valid")
        return nil
    }

    guard
        let data = try? Data(contentsOf: url)
    else {
        print("screenorder.json data could not be read")
        return nil
    }
    do {
        let screens: [Screen] = try decoder.decode([Screen].self, from: data)
        return ScreenOrder(screens: screens)
    } catch {
        print("\(error)")
    }

    return nil
}
