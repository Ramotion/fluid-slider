//
//  Slider.swift
//  Fluid
//
//  Created by Dmitry Nesterenko on 16/10/2017.
//  Copyright Ramotion Inc. All rights reserved.
//

import UIKit
import CoreImage

private let kContentViewMarginX: CGFloat = 10
private let kContentViewCornerRadius: CGFloat = 8

private func isAnimationAllowed() -> Bool {
    let isUnderHighload: Bool
    if #available(iOS 11.0, *) {
        isUnderHighload = ProcessInfo.processInfo.thermalState == .serious || ProcessInfo.processInfo.thermalState == .critical
    } else {
        isUnderHighload = false
    }
    
    let isSimulator = TARGET_OS_SIMULATOR != 0
    
    return !isSimulator && !ProcessInfo.processInfo.isLowPowerModeEnabled && !UIAccessibilityIsReduceMotionEnabled() && !isUnderHighload
}

open class Slider : UIControl {
    
    open var locale: Locale? {
        didSet {
            setNeedsLayout()
        }
    }

    open var didBeginTracking: ((Slider) -> ())?
    open var didEndTracking: ((Slider) -> ())?
    
    private let contentView = UIView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        filterView.mask = UIImageView()
        addSubview(filterView)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(minimumLabel)
        contentView.addSubview(maximumLabel)
        contentView.addSubview(valueView)
        valueView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        valueView.isUserInteractionEnabled = false
        
        setMinimumLabelAttributedText(NSAttributedString(string: "0"))
        setMaximumLabelAttributedText(NSAttributedString(string: "1"))
        
        updateValueViewColor()
        updateValueViewText()
    }
    
    // MARK: - Value
    
    open var fraction: CGFloat = 0 {
        didSet {
            updateValueViewText()
        }
    }
    
    open var attributedTextForFraction: (CGFloat) -> (NSAttributedString) = { fraction in
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.maximumIntegerDigits = 0
        let string = formatter.string(from: fraction as NSNumber) ?? ""
        return NSAttributedString(string: string)
    }
    
    private let valueView = ValueView()
    
    open var valueViewColor: UIColor? {
        didSet {
            updateValueViewColor()
        }
    }
    
    private func updateValueViewColor() {
        valueView.outerFillColor = contentViewColor
        valueView.innerFillColor = valueViewColor
    }
    
    private func updateValueViewText() {
        let text = attributedTextForFraction(fraction)
        valueView.attributedText = text
    }
    
    // MARK: - Labels

    private let minimumLabel = UILabel()
    private let maximumLabel = UILabel()

    open func setMinimumLabelAttributedText(_ attributedText: NSAttributedString?) {
        minimumLabel.attributedText = attributedText
        setNeedsLayout()
    }
    
    open func setMaximumLabelAttributedText(_ attributedText: NSAttributedString?) {
        maximumLabel.attributedText = attributedText
        setNeedsLayout()
    }
    
    // MARK: - Background Image
    
    private let backgroundImageView = UIImageView()
    
    open var contentViewColor: UIColor? {
        didSet {
            updateValueViewColor()
            setNeedsLayout()
        }
    }
    
    open var shadowOffset: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    open var shadowBlur: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var shadowColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Laying out Subviews
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        filterViewMask = nil
        filterView.mask?.frame = filterView.bounds
        
        layoutBackgroundImage()
        layoutLabelsText()
        layoutValueView()
    }
    
    private func layoutLabelsText() {
        minimumLabel.sizeToFit()
        minimumLabel.frame = CGRect(x: kContentViewMarginX, y: bounds.midY - minimumLabel.bounds.midY, width: minimumLabel.bounds.width, height: minimumLabel.bounds.height).integral
        
        maximumLabel.sizeToFit()
        maximumLabel.frame = CGRect(x: bounds.maxX - kContentViewMarginX - maximumLabel.bounds.width, y: bounds.midY - maximumLabel.bounds.midY, width: maximumLabel.bounds.width, height: maximumLabel.bounds.height).integral
    }
    
    private func layoutBackgroundImage() {
        let inset = UIEdgeInsets(top: min(0, shadowOffset.height - shadowBlur), left: min(0, shadowOffset.width - shadowBlur), bottom: max(0, shadowOffset.height + shadowBlur) * -1, right: max(0, shadowOffset.width + shadowBlur) * -1)
        backgroundImageView.frame = UIEdgeInsetsInsetRect(self.bounds, inset)
        backgroundImageView.image = UIGraphicsImageRenderer(bounds: backgroundImageView.bounds).image(actions: { context in
            if let color = shadowColor {
                context.cgContext.setShadow(offset: shadowOffset, blur: shadowBlur, color: color.cgColor)
            }
            contentViewColor?.setFill()
            let inset = UIEdgeInsets(top: inset.top * -1, left: inset.left * -1, bottom: inset.bottom * -1, right: inset.right * -1)
            UIBezierPath(roundedRect: UIEdgeInsetsInsetRect(backgroundImageView.bounds, inset), cornerRadius: kContentViewCornerRadius).fill()
        })
    }
    
    private func layoutValueView() {
        let bounds = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsets(top: 0, left: kContentViewMarginX, bottom: 0, right: kContentViewMarginX))
        let centerX = fraction * bounds.size.width + bounds.minX
        setValueViewPositionX(to: centerX)
    }
    
    private func valueViewFrame(forCenterX centerX: CGFloat) -> CGRect {
        return CGRect(x: centerX - bounds.height / 2, y: bounds.minY, width: bounds.height, height: bounds.height)
    }
    
    // MARK: - Tracking Touches and Redrawing Controls
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event)
        let x = touch.location(in: self).x
        setValueViewPositionX(to: x)
        fraction = fractionForPositionX(x)
        valueView.animateTrackingBegin { [weak self] in
            self?.redrawFilterView()
        }
        sendActions(for: .valueChanged)
        didBeginTracking?(self)
        return result
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.continueTracking(touch, with: event)
        let x = touch.location(in: self).x
        setValueViewPositionX(to: x)
        fraction = fractionForPositionX(x)
        filterView.center.x = valueView.center.x
        sendActions(for: .valueChanged)
        return result
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        valueView.animateTrackingEnd { [weak self] in
            self?.redrawFilterView()
        }
        didEndTracking?(self)
    }
    
    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        valueView.animateTrackingEnd { [weak self] in
            self?.redrawFilterView()
        }
        didEndTracking?(self)
    }
    
    private func boundsForValueViewCenter() -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: kContentViewMarginX - ValueView.kLayoutMarginInset + valueView.bounds.midX, bottom: 0, right: kContentViewMarginX - ValueView.kLayoutMarginInset + valueView.bounds.midX))
    }
    
    private func fractionForPositionX(_ x: CGFloat) -> CGFloat {
        let centerBounds = boundsForValueViewCenter()
        let clampedX = x < centerBounds.minX ? centerBounds.minX : (centerBounds.maxX < x ? centerBounds.maxX : x)
        return (clampedX - centerBounds.minX) / (centerBounds.maxX - centerBounds.minX)
    }
    
    private func setValueViewPositionX(to x: CGFloat) {
        let centerBounds = boundsForValueViewCenter()
        let clampedCenterX = x < centerBounds.minX ? centerBounds.minX : (centerBounds.maxX < x ? centerBounds.maxX : x)
        valueView.frame = valueViewFrame(forCenterX: clampedCenterX)
    }
    
    // MARK: - Filter View
    
    private let filterView = UIImageView()
    private let filter = MetaballFilter()
    private var filterViewMask: UIImage?
    private let context = CIContext()
    
    private func redrawFilterView() {
        guard isAnimationAllowed() else { return }
        
        let scale = UIScreen.main.scale
        let radius: CGFloat = 12
        let bottomMargin: CGFloat = 10
        let offsetY = -contentView.bounds.height / 2
        let bounds = CGRect(x: valueView.frame.origin.x, y: offsetY, width: valueView.frame.size.width, height: -offsetY + bottomMargin).insetBy(dx: -radius, dy: 0)

        let inputImage = UIGraphicsImageRenderer(bounds: bounds).image {
            contentView.layer.render(in: $0.cgContext)
        }
        
        filter.blurRadius = radius
        filter.threshold = 0.49
        filter.backgroundColor = contentViewColor
        filter.antialiasingRadius = scale / 2
        filter.inputImage = CIImage(cgImage: inputImage.cgImage!)
        
        let outputImage = filter.outputImage!.cropped(to: CGRect(x: 0, y: 0, width: inputImage.size.width * scale, height: inputImage.size.height * scale))
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)!

        filterView.image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        filterView.frame = bounds
        
        if filterViewMask == nil {
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: bounds.size))
            filterViewMask = renderer.image(actions: { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: bounds.size))
                context.cgContext.clear(CGRect(x: 0, y: bounds.size.height - bottomMargin, width: radius, height: bottomMargin))
                context.cgContext.clear(CGRect(x: bounds.size.width - radius, y: bounds.size.height - bottomMargin, width: radius, height: bottomMargin))
            })
            (filterView.mask as? UIImageView)?.image = filterViewMask
        }
    }
    
}
