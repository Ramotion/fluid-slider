//
//  ValueView.swift
//  Fluid
//
//  Created by Dmitry Nesterenko on 16/10/2017.
//  Copyright Ramotion Inc. All rights reserved.
//

import UIKit
import pop

class ValueView : UIView {

    static let kLayoutMarginInset: CGFloat = 4
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        shapeView.frame = bounds
        shapeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shapeView.layer.addSublayer(outerShapeLayer)
        shapeView.layer.addSublayer(innerShapeLayer)
        addSubview(shapeView)
        
        shapeView.addSubview(textLabel)
    }
    
    // MARK: - Layers
    
    private let outerShapeLayer = CAShapeLayer()
    private let innerShapeLayer = CAShapeLayer()
    
    var outerFillColor: UIColor? {
        didSet {
            outerShapeLayer.fillColor = outerFillColor?.cgColor
            outerShapeLayer.removeAllAnimations()
        }
    }
    
    var innerFillColor: UIColor? {
        didSet {
            innerShapeLayer.fillColor = innerFillColor?.cgColor
            innerShapeLayer.removeAllAnimations()
        }
    }
    
    // MARK: - Text Label
    
    private let textLabel = UILabel()
    
    var attributedText: NSAttributedString? {
        get {
            return textLabel.attributedText
        }
        set {
			if let newValue = newValue {
				// apply centered horizontal alignment
				let string = newValue.mutableCopy() as! NSMutableAttributedString
				let paragraph = (string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle ?? NSParagraphStyle()).mutableCopy() as! NSMutableParagraphStyle
				paragraph.alignment = .center
				string.addAttribute(.paragraphStyle, value: paragraph, range: NSMakeRange(0, string.length))
				textLabel.attributedText = string
			} else {
				textLabel.attributedText = nil
			}
		}
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = bounds
        
        outerShapeLayer.path = UIBezierPath(ovalIn: shapeView.bounds).cgPath
        innerShapeLayer.path = UIBezierPath(ovalIn: shapeView.bounds.insetBy(dx: ValueView.kLayoutMarginInset, dy: ValueView.kLayoutMarginInset)).cgPath
        layer.removeAllAnimations()
    }
    
    // MARK: - Animations
    
    private let shapeView = UIView()
    public var animationFrame: (() -> ())?
    
    func animateTrackingBegin() {
        let topY = -shapeView.bounds.height - 4
        
        if let animation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY) {
            animation.toValue = topY + shapeView.bounds.midY
            animation.springBounciness = 8
            animation.springSpeed = 15
            animation.removedOnCompletion = true
            animation.animationDidApplyBlock = { [weak self] _ in
                self?.animationFrame?()
            }
            shapeView.layer.pop_add(animation, forKey: "bounce")
        }
    }
    
    func animateTrackingEnd() {
        if let animation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY) {
            animation.toValue = shapeView.bounds.midY
            animation.removedOnCompletion = true
            animation.duration = 0.22
            animation.animationDidApplyBlock = { [weak self] _ in
                self?.animationFrame?()
            }
            shapeView.layer.pop_add(animation, forKey: "bounce")
        }
    }
    
}
