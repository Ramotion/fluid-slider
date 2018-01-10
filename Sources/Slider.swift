//
//  Slider.swift
//  Fluid
//
//  Created by Dmitry Nesterenko on 16/10/2017.
//  Copyright Ramotion Inc. All rights reserved.
//

import UIKit
import CoreImage

private let kBlurRadiusDefault: CGFloat = 12
private let kBlurRadiusIphonePlus: CGFloat = 18 // blur a little bit more to avoid fluid disconnection effect

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
		contentView.addSubview(minimumImageView)
		contentView.addSubview(maximumImageView)
        contentView.addSubview(minimumLabel)
        contentView.addSubview(maximumLabel)
        contentView.addSubview(valueView)
        valueView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        valueView.isUserInteractionEnabled = false
        valueView.animationFrame = redrawFilterView
        
        setMinimumLabelAttributedText(NSAttributedString(string: "0"))
        setMaximumLabelAttributedText(NSAttributedString(string: "1"))
        
        updateValueViewColor()
        updateValueViewText()
    }
    
    // MARK: - Value
    
    open var fraction: CGFloat = 0 {
        didSet {
            updateValueViewText()
			layoutValueView()
        }
    }

	open var showFractionOnlyWhileTracking = false {
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

	open var valueViewMargin: CGFloat = ValueView.kLayoutMarginInset {
		didSet {
			if valueViewMargin < ValueView.kLayoutMarginInset {
				valueViewMargin = ValueView.kLayoutMarginInset
			}
			layoutValueView()
		}
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

	open var isAnimationEnabled = true
	private(set) open var isSliderTracking = false
    
    private func updateValueViewText() {
		if !showFractionOnlyWhileTracking || isSliderTracking {
			let text = attributedTextForFraction(fraction)
			valueView.attributedText = text
		} else {
			valueView.attributedText = nil
		}
    }

	// MARK: - Images

	private let minimumImageView = UIImageView()
	private let maximumImageView = UIImageView()

	open var imagesMargin: CGFloat = 10 {
		didSet {
			layoutImageViews()
		}
	}

	open var imagesColor: UIColor? {
		didSet {
			minimumImageView.tintColor = imagesColor
			maximumImageView.tintColor = imagesColor
		}
	}

	open func setMinimumImage(_ image: UIImage?) {
		minimumImageView.image = image?.withRenderingMode(.alwaysTemplate)
		layoutImageViews()
	}

	open func setMaximumImage(_ image: UIImage?) {
		maximumImageView.image = image?.withRenderingMode(.alwaysTemplate)
		layoutImageViews()
	}
    
    // MARK: - Labels

    private let minimumLabel = UILabel()
    private let maximumLabel = UILabel()

	open var labelsMargin: CGFloat = 10 {
		didSet {
			layoutLabelsText()
		}
	}

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

	open var contentViewCornerRadius: CGFloat = 8 {
		didSet {
			layoutBackgroundImage()
		}
	}
    
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
		layoutImageViews()
        layoutLabelsText()
        layoutValueView()
    }
    
    private func layoutLabelsText() {
        minimumLabel.sizeToFit()
        minimumLabel.frame = CGRect(x: labelsMargin, y: bounds.midY - minimumLabel.bounds.midY, width: minimumLabel.bounds.width, height: minimumLabel.bounds.height).integral
        
        maximumLabel.sizeToFit()
        maximumLabel.frame = CGRect(x: bounds.maxX - labelsMargin - maximumLabel.bounds.width, y: bounds.midY - maximumLabel.bounds.midY, width: maximumLabel.bounds.width, height: maximumLabel.bounds.height).integral
    }

	private func layoutImageViews() {
		let imageInset = ValueView.kLayoutMarginInset * 2
		let imageSize = CGSize(width: bounds.height - imageInset * 2, height: bounds.height - imageInset * 2)

		minimumImageView.frame = CGRect(x: imagesMargin, y: imageInset, width: imageSize.width, height: imageSize.height).integral
		minimumImageView.contentMode = .left
		if let image = minimumImageView.image, image.size.width > minimumImageView.bounds.width || image.size.height > minimumImageView.bounds.height {
			minimumImageView.contentMode = .scaleAspectFit
		}

		maximumImageView.frame = CGRect(x: bounds.maxX - imagesMargin - imageSize.width, y: imageInset, width: imageSize.width, height: imageSize.height).integral
		maximumImageView.contentMode = .right
		if let image = maximumImageView.image, image.size.width > maximumImageView.bounds.width || image.size.height > maximumImageView.bounds.height {
			maximumImageView.contentMode = .scaleAspectFit
		}
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
            UIBezierPath(roundedRect: UIEdgeInsetsInsetRect(backgroundImageView.bounds, inset), cornerRadius: contentViewCornerRadius).fill()
        })
    }
    
    private func layoutValueView() {
        let bounds = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsets(top: 0, left: valueViewMargin, bottom: 0, right: valueViewMargin))
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
		isSliderTracking = true
        fraction = fractionForPositionX(x)
        valueView.animateTrackingBegin()
        sendActions(for: .valueChanged)
        didBeginTracking?(self)
        return result
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.continueTracking(touch, with: event)
        let x = touch.location(in: self).x
		isSliderTracking = true
        fraction = fractionForPositionX(x)
        filterView.center.x = valueView.center.x
        sendActions(for: .valueChanged)
        return result
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
		isSliderTracking = false
        valueView.animateTrackingEnd()
		updateValueViewText()
        didEndTracking?(self)
    }
    
    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
		isSliderTracking = false
        valueView.animateTrackingEnd()
		updateValueViewText()
        didEndTracking?(self)
    }
    
    private func boundsForValueViewCenter() -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: valueViewMargin - ValueView.kLayoutMarginInset + valueView.bounds.midX, bottom: 0, right: valueViewMargin - ValueView.kLayoutMarginInset + valueView.bounds.midX))
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
        guard isAnimationEnabled && isAnimationAllowed() else { return }
        
        let scale = UIScreen.main.scale
        let radius: CGFloat = UIScreen.main.bounds.width >= 414 ? kBlurRadiusIphonePlus : kBlurRadiusDefault
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
