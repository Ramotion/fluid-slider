//
//  ViewController.swift
//  Example
//
//  Created by Dmitry Nesterenko on 19/10/2017.
//  Copyright © 2017 Dmitry Nesterenko. All rights reserved.
//

import UIKit
import Slider

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    @IBOutlet var slider: Slider!
	@IBOutlet var sliderWithImages: Slider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelTextAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 500) as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
        }
        slider.setMinimumLabelAttributedText(NSAttributedString(string: "0", attributes: labelTextAttributes))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: "500", attributes: labelTextAttributes))
        slider.fraction = 0.5
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
        slider.valueViewColor = .white
        slider.didBeginTracking = { [weak self] _ in
            self?.setLabelHidden(true, animated: true)
        }
        slider.didEndTracking = { [weak self] _ in
            self?.setLabelHidden(false, animated: true)
        }

		sliderWithImages.attributedTextForFraction = { fraction in
			let formatter = NumberFormatter()
			formatter.maximumIntegerDigits = 3
			formatter.maximumFractionDigits = 0
			let string = formatter.string(from: (fraction * 800 + 100) as NSNumber) ?? ""
			return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
		}
		sliderWithImages.setMinimumImage(UIImage(named: "banana"))
		sliderWithImages.setMaximumImage(UIImage(named: "cake"))
		sliderWithImages.imagesColor = UIColor.white.withAlphaComponent(0.8)
		sliderWithImages.setMinimumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
		sliderWithImages.setMaximumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
		sliderWithImages.fraction = 0.5
		sliderWithImages.shadowOffset = CGSize(width: 0, height: 10)
		sliderWithImages.shadowBlur = 5
		sliderWithImages.shadowColor = UIColor(white: 0, alpha: 0.1)
		sliderWithImages.contentViewColor = UIColor.purple
		sliderWithImages.valueViewColor = .white
    }
    
    private func setLabelHidden(_ hidden: Bool, animated: Bool) {
        let animations = {
            self.label.alpha = hidden ? 0 : 1
        }
        if animated {
            UIView.animate(withDuration: 0.11, animations: animations)
        } else {
            animations()
        }
    }
    
}

