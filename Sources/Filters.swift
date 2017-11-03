//
//  Filters.swift
//  Fluid
//
//  Created by Dmitry Nesterenko on 18/10/2017.
//  Copyright Ramotion Inc. All rights reserved.
//

import UIKit
import CoreImage

@objc
class ThresholdFilter: CIFilter {
    
    private class Constructor : NSObject, CIFilterConstructor {
        func filter(withName name: String) -> CIFilter? {
            if name == String(describing: ThresholdFilter.self) {
                return ThresholdFilter()
            }
            return nil
        }
    }
    
    @objc
    var inputImage : CIImage?
    
    @objc
    var threshold: CGFloat = 0.75
    
    private let filterKernel = CIColorKernel(source: """
kernel vec4 thresholdFilter(__sample image, float threshold) {
    float luma = (image.r * 0.2126) + (image.g * 0.7152) + (image.b * 0.0722);
    return (luma > threshold) ? vec4(1.0, 1.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 0.0);
}
"""
    )
    
    class func register() {
        CIFilter.registerName("ThresholdFilter", constructor: Constructor(), classAttributes: [:])
    }

    override var outputImage : CIImage? {
        guard let inputImage = inputImage, let filterKernel = filterKernel else { return nil }
        return filterKernel.apply(extent: inputImage.extent, arguments: [inputImage, threshold])
    }
    
}

class MetaballFilter : CIFilter {
    
    var inputImage : CIImage?
    
    private let colorFilter = CIFilter(name: "CIColorControls", withInputParameters: [
        kCIInputBrightnessKey: 1,
        kCIInputSaturationKey: 0,
        kCIInputContrastKey: 0
        ])!
    
    private let blurFilter = CIFilter(name: "CIGaussianBlur")!

    private var thresholdFilter = ThresholdFilter()
    
    private let invertFilter = CIFilter(name: "CIFalseColor", withInputParameters: [
        "inputColor0": CIColor(color: .white),
        ])!

    private let antialiasingFilter = CIFilter(name: "CIDiscBlur")!

    var blurRadius: CGFloat = 12
    var threshold: CGFloat = 0.75
    var backgroundColor: UIColor?
    var antialiasingRadius: CGFloat = UIScreen.main.scale / 2
    
    override var outputImage : CIImage? {
        guard let inputImage = inputImage else { return nil }
        
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        thresholdFilter.threshold = threshold
        if let backgroundColor = backgroundColor {
            invertFilter.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")
        }
        antialiasingFilter.setValue(antialiasingRadius, forKey: kCIInputRadiusKey)

        // pipeline
        colorFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(colorFilter.outputImage!, forKey: kCIInputImageKey)
        thresholdFilter.inputImage = blurFilter.outputImage!
        invertFilter.setValue(thresholdFilter.outputImage!, forKey: kCIInputImageKey)
        antialiasingFilter.setValue(invertFilter.outputImage!, forKey: kCIInputImageKey)
        
        return antialiasingFilter.outputImage
    }
    
}
