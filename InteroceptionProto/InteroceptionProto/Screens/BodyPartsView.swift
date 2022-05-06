//
//  BodyPartsView.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 04/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import SwiftUI
import os
import Combine

private enum BodyPart: RawRepresentable {
    case chest
    case fingers
    case neck
    case ears
    case stomach
    case legs
    case head
    case nowhere

    // TODO refactor to struct
    var rawValue: (value: Int, name: String, color: Color) {
        switch self {
        case .chest: return (1, "chest", .blue)
        case .fingers: return (2, "fingers", .purple)
        case .neck: return (3, "neck", .black)
        case .ears: return (4, "ears", .red)
        case .stomach: return (5, "stomach", .yellow)
        case .legs: return (6, "legs", .gray)
        case .head: return (7, "head", .green)
        case .nowhere: return (8, "nowhere", .clear)
        }
    }

    init?(rawValue: (value: Int, name: String, color: Color)) {
        switch rawValue {
        case (1, "chest", .blue): self = .chest
        case (2, "fingers", .purple): self = .fingers
        case (3, "neck", .black): self = .neck
        case (4, "ears", .red): self = .ears
        case (5, "stomach", .yellow): self = .stomach
        case (6, "legs", .gray): self = .legs
        case (7, "head", .green): self = .head
        case (8, "nowhere", .clear): self = .nowhere
        default: return nil
        }
    }
}

private class BodyPartsViewModel: ObservableObject {
    public let objectWillChange = PassthroughSubject<Bool,Never>()
    private var needReset = false
    @Published var measureNotValid = false

    @Published var youSelected = "Please select an area"

    @Published var showBodyPart = false

    @Published var showActivity = false

    @Published var selectedPart = BodyPart.nowhere {
        willSet {
            youSelected = "You selected:"
            showBodyPart = true
            needReset = newValue != .nowhere && (newValue == selectedPart)
            objectWillChange.send(true)
        }

        didSet {
            if needReset {
                needReset = false
                self.selectedPart = .nowhere
            }
        }
    }

    @Published var theButtonText = "Confirm"

    @objc func start() {
        // Logging.JLog(message: "start")
        SyncroTaskManager.shared.taskDelegate = self
    }

}

// PRAGMA MARK: SyncroTaskManagerDelegate
extension BodyPartsViewModel: SyncroTaskManagerDelegate {

    func torchError () {
    }

    func fingerPresentChanged(_ isPresent: Bool) {

        print("Finger is present: \(isPresent)")
        DispatchQueue.main.async {
            self.measureNotValid = !isPresent
        }
    }

    func beatDetected(withInstantBPM instantBPM: Float, andAverageBPM averageBPM: Float) {

    }

    func newPPGSampleReady(_ sample: Float) {

    }

    func reportHRVActivation(_ activation: Float, withMaxPeriod max: Float, andMinPeriod min: Float) {

    }
}

struct NowhereButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: UIUtils.buttonsMinWidth)
            .padding()
            .foregroundColor(.mainFgColor)
            .border(Color.mainFgColor)
    }
}

struct BodyPartsView: View {
    @ObservedObject private var viewModel = BodyPartsViewModel()
    @ObservedObject var interoceptionSettings: InteroceptionSettings

    @Environment(\.presentationMode) var presentationMode
    @State private var restartTrial = false
    @State private var goToFinalScreen = false
    @State private var showOverlay = false
    @Binding var hasSelected: Bool


    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)

            if viewModel.measureNotValid {
                FingerOverlay().transition(AnyTransition.opacity.animation(.easeOut(duration: 0.2)))
            }

            VStack {

                Text("BODY MAP:")
                    .padding([.top, .horizontal], UIUtils.defaultVPadding)
                    .multilineTextAlignment(.center)

                Text("_mannequin_title")
                    .padding([.horizontal], UIUtils.defaultVPadding)
                    .multilineTextAlignment(.center)

                Button(action: {
                    self.viewModel.selectedPart = .nowhere
                    hasSelected = true
                }, label: {
                    Text("_mannequin_nowhere_button")
                })
                .buttonStyle(NowhereButtonStyle())
                .padding(.top, 20)

                Image("mannequin")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 10)
                    .overlay(overlay())
                    .onReceive(self.viewModel.objectWillChange) { _ in
                        hasSelected = true
                    }
                Text("\(viewModel.youSelected)")

                if $viewModel.showBodyPart.wrappedValue {
                    Text("\(viewModel.selectedPart.rawValue.name)")
                        .italic()
                        .font(.subheadline)
                }
                Spacer().frame(height: 30)
            }
        }
        .foregroundColor(.mainFgColor)

        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                self.showOverlay = true
            }
        }
        .onDisappear {
            let bodyPos = self.viewModel.selectedPart.rawValue.value
            NotificationCenter.default.post(name: .storeBodyPosition, object: bodyPos)

            InteroceptionSettings.isPracticeRun = false
        }
    }

    private func overlay() -> some View {
        Group {
            if showOverlay {
                BodyOverlay().environmentObject(viewModel)
            } else {
                EmptyView()
            }
        }
    }
}

private struct BodyOverlay: View {
    let imgOriginalWidth = CGFloat(240)
    let imgOriginalHeight = CGFloat(511)

    var body: some View {
        GeometryReader { content in
            BodyButton(type: .double, bodyPart: .ears,
                       btnSize: .init(
                        width: self.scaleOnX(60, withNewWidth: content.size.width),
                        height: self.scaleOnY(70, withNewHeight: content.size.height)
                       )
            )
                .frame(
                    width: self.scaleOnX(160, withNewWidth: content.size.width),
                    height: self.scaleOnY(70, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(30, withNewHeight: content.size.height))

            BodyButton(bodyPart: .head)
                .frame(
                    width: self.scaleOnX(40, withNewWidth: content.size.width),
                    height: self.scaleOnY(70, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(30, withNewHeight: content.size.height))

            BodyButton(bodyPart: .neck)
                .frame(
                    width: self.scaleOnX(160, withNewWidth: content.size.width),
                    height: self.scaleOnY(40, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(85, withNewHeight: content.size.height))

            BodyButton(bodyPart: .chest)
                .frame(
                    width: self.scaleOnX(130, withNewWidth: content.size.width),
                    height: self.scaleOnY(70, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(140, withNewHeight: content.size.height))

            BodyButton(type: .double, bodyPart: .fingers, btnSize: .init(
                        width: self.scaleOnX(60, withNewWidth: content.size.width),
                        height: self.scaleOnY(60, withNewHeight: content.size.height)
            ))
                .frame(
                    width: self.scaleOnX(245, withNewWidth: content.size.width),
                    height: self.scaleOnY(70, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(260, withNewHeight: content.size.height))
            BodyButton(bodyPart: .stomach)
                .frame(
                    width: self.scaleOnX(100, withNewWidth: content.size.width),
                    height: self.scaleOnY(90, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(220, withNewHeight: content.size.height))

            BodyButton(bodyPart: .legs)
                .frame(
                    width: self.scaleOnX(110, withNewWidth: content.size.width),
                    height: self.scaleOnY(240, withNewHeight: content.size.height))
                .position(
                    x: self.scaleOnX(120, withNewWidth: content.size.width),
                    y: self.scaleOnY(385, withNewHeight: content.size.height))
        }
    }

    private func scaleOnX(_ x: CGFloat, withNewWidth width: CGFloat) -> CGFloat {
        x * (width/imgOriginalWidth)
    }

    private func scaleOnY(_ y: CGFloat, withNewHeight height: CGFloat) -> CGFloat {
        y * (height/imgOriginalHeight)
    }
}

private struct BodyButton: View {
    private static let btnOpacity = (selected: 0.65, notSelected: 0.2)

    enum BodyButtonType {
        case single
        case double
    }
    @EnvironmentObject var viewModel: BodyPartsViewModel
    var type = BodyButtonType.single
    let bodyPart: BodyPart
    var btnSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)

    var body: some View {
        Button(action: {
            self.viewModel.selectedPart = self.bodyPart
        }, label: {
            HStack(spacing: 0) {

                btnLabelRect()

                if type == .double {
                    Spacer()
                    btnLabelRect()
                }
            }
        })
        .buttonStyle(BodyButtonStyle())
        .onAppear {
            self.viewModel.start()
        }
    }

    private func isSelectedBodyPart() -> Bool {
        bodyPart == viewModel.selectedPart
    }

    private func btnLabelRect() -> some View {
        let baseColor = bodyPart.rawValue.color
        let actualColor = isSelectedBodyPart() ?
            baseColor.opacity(BodyButton.btnOpacity.selected) :
            baseColor.opacity(BodyButton.btnOpacity.notSelected)

        return Rectangle()
            .fill(actualColor)
            .frame(maxWidth: btnSize.width, maxHeight: btnSize.height)
    }

    private struct BodyButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.1))
        }
    }
}

struct BodyPartsView_Previews: PreviewProvider {
    @State static var selected = false
    static var previews: some View {
        BodyPartsView(interoceptionSettings: InteroceptionSettings(numberOfTrials: 20), hasSelected: $selected)
            .previewDevice("iPhone 6s")
    }
}
