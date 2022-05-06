//
//  Knob.swift
//  InteroceptionProto
//
//  Created by Matteo Puccinelli on 02/12/2019.
//  Copyright © 2019 BioBeats. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

/**
 * Return vector from lhs point to rhs point.
 */
func - (lhs: CGPoint, rhs: CGPoint) -> CGVector {
    return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
}

extension CGVector {
    /**
     * Returns angle between vector and receiver in radians. Return is between
     * 0 and 2 * PI in clockwise direction.
     */
    func angleFromVector(vector: CGVector) -> Double {
        let angle = Double(atan2(dy, dx) - atan2(vector.dy, vector.dx))
        return angle > 0 ? angle : angle + 2 * Double.pi
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

extension UIColor {
    /**
     * Returns a color with adjusted saturation and brigtness than can be used to
     * indicate control is disabled.
     */
    func disabledColor() -> UIColor {
        // swiftlint:disable identifier_name
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)

        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * 0.5, brightness: b * 1.2, alpha: a)
        // swiftlint: enable identifier_name
    }
}

/**
 * A Knob object is a visual control used to select a value from a range of values between
 * 0 and 2 * PI radians. A user rotates the control using a single figure pan gesture with
 * values increasing as the knob is rotated clockwise. The value resets from 2 * PI to 0 as
 * the user rotates the knob through the 12 o'clock position.
 */

protocol KnobControlDelegate: AnyObject {

    func knobWasMoved ()

}

public class KnobControl: UIControl {
    private let shapeLayer = CAShapeLayer()
    private var indicatorsLayer = CAShapeLayer()
    private let lineWidth = CGFloat(1)
    private var lastVector = CGVector.zero
    var angle: Double = 0

    var rotations = 0

    /**
     * Contains the current value.
     */
    public var value: Double {
        get {
            return angle
        }
        set {
            angle = newValue.truncatingRemainder(dividingBy: Double.pi * 2)
            updateLayer()
        }
    }

    override public var frame: CGRect {
        didSet {
            self.updateLayer()
        }
    }

    override public var isEnabled: Bool {
        didSet {
            self.updateLayer()
        }
    }

    override public var tintColor: UIColor! {
        didSet {
            self.updateLayer()
        }
    }

    private var knobBackgroundColor: UIColor?
    override public var backgroundColor: UIColor? {
        get {
            return knobBackgroundColor
        }

        set {
            knobBackgroundColor = newValue
            updateLayer()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addShapeLayer()
        updateLayer()
    }

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        addShapeLayer()
        updateLayer()
    }

    private func addShapeLayer() {
        layer.addSublayer(shapeLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = self.bounds
    }

    private func updateLayer() {
        if let color = knobBackgroundColor {
            shapeLayer.fillColor = isEnabled ? color.cgColor : (color.disabledColor().cgColor)
        } else {
            shapeLayer.fillColor = UIColor.clear.cgColor
        }
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = isEnabled ? tintColor.cgColor : (tintColor.disabledColor().cgColor)
        shapeLayer.lineWidth = lineWidth

        // Adjust drawing rectangle for line width
        var dx = shapeLayer.lineWidth / 2, dy = shapeLayer.lineWidth / 2

        // Draw perfect circle even if view is rectangular
        if bounds.width > bounds.height {
            dx += (bounds.width - bounds.height) / 2
        } else if bounds.height > bounds.width {
            dy += (bounds.height - bounds.width) / 2
        }
        let ovalRect = bounds.insetBy(dx: dx, dy: dy)
        shapeLayer.path = UIBezierPath(ovalIn: ovalRect).cgPath

        updateIndicators()
    }

    private func updateIndicators() {
        if indicatorsLayer.bounds == .zero {

            indicatorsLayer.removeFromSuperlayer()
            indicatorsLayer = CAShapeLayer()
            indicatorsLayer.frame = bounds
            shapeLayer.addSublayer(indicatorsLayer)

            let step = 5
            for i in 0..<360 where i%step == 0 {
                let lineLayer = CAShapeLayer()
                let linePath = UIBezierPath()
                lineLayer.frame = indicatorsLayer.bounds
                linePath.move(to: CGPoint(x: bounds.width / 2, y: 0))
                linePath.addLine(to: CGPoint(x: bounds.width / 2, y: i%(2*step) == 0 ? 10 : 5))
                lineLayer.path = linePath.cgPath
                lineLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if Platform.isSimulator {
                    lineLayer.strokeColor = i == 0 ? UIColor.red.cgColor : tintColor.cgColor
                } else {
                    lineLayer.strokeColor = tintColor.cgColor
                }
                let degrees = Measurement(value: Double(i*5), unit: UnitAngle.degrees)
                let rad = degrees.converted(to: .radians).value
                let transform = CGAffineTransform(rotationAngle: CGFloat(rad))
                lineLayer.setAffineTransform(transform)
                indicatorsLayer.addSublayer(lineLayer)
            }
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        indicatorsLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(angle)))
        CATransaction.commit()

    }

    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        lastVector = touch.location(in: self) - bounds.center
        return true
    }

    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Calculate vector from center to touch.
        let vector = touch.location(in: self) - bounds.center

        // Add angular difference to our current value.
        angle = (angle + vector.angleFromVector(vector: lastVector)).truncatingRemainder(dividingBy: 2 * Double.pi)

        lastVector = vector
        updateIndicators()

        sendActions(for: UIControl.Event.valueChanged)

        return true
    }
}

struct KnobView: UIViewRepresentable {
    @Binding var value: Double
    @Binding var interactedWith: Bool

    var range: Double

    init(value: Binding<Double>, rang: Double, interactedWith: Binding<Bool>) {
        self._value = value
        self.range = rang
        self._interactedWith = interactedWith
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<KnobView>) -> KnobControl {
        let knob = KnobControl()
        knob.angle = self.currentAngle()

        knob.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentValue(sender:)),
            for: .valueChanged)
        return knob
    }

    func updateUIView(_ uiView: KnobControl, context: UIViewRepresentableContext<KnobView>) {
        // nothing to do here
        uiView.angle = self.currentAngle()
    }

    func currentAngle() -> Double {
        // Set the initial angle based on the value provided and the range
        // First translate -range, range in 0,1
        let normalisedValue = (self._value.wrappedValue + range) / (2 * range)
        // Now map to 0-2pi
        let shiftedRad = normalisedValue * (2 * Double.pi)
        // If the original value is 0, the normalised valus is 1/2 which maps to rad = pi
        // But we want 0 to be = 0 rad, not pi rad, so let's subtract pi and truncate
        let rad = (shiftedRad - Double.pi).truncatingRemainder(dividingBy: 2 * Double.pi)
        print("Original value is \(self._value.wrappedValue), rad is \(rad)")
        return rad
    }

    class Coordinator: NSObject {
        var knob: KnobView
        var lastRadian: Double? = 0

        init(_ knob: KnobView) {
            self.knob = knob
        }

        @objc func updateCurrentValue(sender: KnobControl) {
            if self.lastRadian != nil {
                self.knob.interactedWith = true
                // The rad goes from 0 to 2pi regardless the direction counter/clockwise
                // Need to translate this to a value in [-range, range]
                // Assumption: In 0 position the value outputted is 0
                // Assumption: Half spin clockwise (pi) should bring 0 to +range,
                // while one half spin counter clockwise should bring 0 to the -range
                // If the initial value is != 0, then it will take less then a spin to get to +/-range

                // Translate into radians as if 0 rads from the bottom center of the knob (cos 0, sin -1)
                let shiftedRad = (sender.value + Double.pi).truncatingRemainder(dividingBy: 2 * Double.pi)
                // Map this to the range so on top (cos 0, sin 1) we don't have -range but 0
                let mapping = -self.knob.range + (shiftedRad / (2.0 * Double.pi)) * (self.knob.range * 2)

                self.lastRadian = sender.value

                // Clip within -range, range, even though it should never happen for mapping to be out of the range
                self.knob.value = max(-self.knob.range, min(self.knob.range, mapping))
            }
        }
    }
}
