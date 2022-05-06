//
//  SwiftUIView.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 05/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI

struct GenericOnboardingScreen<Content>: View where Content: View {
    let content: Content

    @State var goBack = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.bgColor
                .edgesIgnoringSafeArea(.all)

            VStack {
                VStack {
                    HStack {
                        content
                            .multilineTextAlignment(.center)
                            .transition(.slide)
                    }
                    .padding(.all, UIUtils.defaultVPadding)

                }.frame(height: 520)
            }
        }
        .foregroundColor(Color.mainFgColor)
    }
}

enum OnboardingPageType: String, Decodable {
    case text = "Text"
    case image = "Image"
    case video = "Video"
    case baseline = "BaselineIntro"
}

struct Onboarding: View {
    let pages: [OnboardingPage]
    let controller: ScreenController

    @State var transitionDirection = AnyTransition.move(edge: .leading)
    @State var page = 0 {
        willSet(newPage) {
            transitionDirection = AnyTransition.move(edge: newPage > page ? .leading : .trailing)
        }
    }
    var canGoBack: Bool {
        page > pages.startIndex
    }
    var canGoForwards: Bool {
        page < pages.endIndex - 1
    }

    var body: some View {
        VStack {
            let page = pages[self.page]
            let data = page.data
            switch page.type {
            case .text:
                OnboardingScreen(stringKey: data!.text!)
                    .id(data!.text!)
                    .transition(transitionDirection)
            case .image:
                OnboardingImageScreen(data!.image!, txtHeight: 160, content: {
                    let key = data!.text!
                    Text(LocalizedStringKey(key))
                        .id(key)
                })
                    .id(data!.image!)
                    .transition(transitionDirection)
            case .video:
                OnboardingVideoScreen(data!.video!, content: {
                    Text(data!.text != nil ? LocalizedStringKey(data!.text!) : "")
                })
                    .id(data!.video!)
                    .transition(transitionDirection)
            case .baseline:
                BaselineIntroScreen()
                    .transition(transitionDirection)
            }

            HStack {
                Button(action: {
                    withAnimation {
                        if canGoBack {
                            self.prevPage()
                        }
                    }
                }, label: {
                    Text("_button_back_label")
                })
                .buttonStyle(UIUtils.MyButtonBackStyle())
                .cornerRadius(10)
                .padding(.bottom, UIUtils.defaultVPadding)
                .opacity(canGoBack ? 1 : 0)

                Spacer().frame(width: 60)
                Button(action: {
                    withAnimation {
                        if canGoForwards {
                            self.nextPage()
                        } else {
                            controller.nextScreen()
                        }
                    }
                }, label: {
                    Text("_onboarding_continue_button_label")
                })
                .modifier(UIUtils.ButtonNavLabelStyle())
                .cornerRadius(10)
                .padding(.bottom, UIUtils.defaultVPadding)

            }.multilineTextAlignment(.center)
        }
        .transition(.move(edge: page == 0 ? .leading : .trailing))
    }

    func nextPage() {
        if page < pages.endIndex - 1 {
            page += 1
        }
     }

    func prevPage() {
        if page > pages.startIndex {
            page -= 1
        }
    }
}

struct OnboardingScreen: View {
    var stringKey: String = ""

    var body: some View {
        GenericOnboardingScreen {
            Text(LocalizedStringKey(stringKey))
                .id(stringKey)
        }
    }
}

struct PartiIdScreen: View {
    let controller: ScreenController
    var body: some View {
        ParticipantIdScreen(content: {
            Text("_participantId")
        }, controller: controller)
        .transition(.move(edge: .leading))
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding(
            pages: [OnboardingPage(type: .text, data: ScreenData(text: "_onboarding1_content"))],
            controller: ScreenController()
        )
    }
}
