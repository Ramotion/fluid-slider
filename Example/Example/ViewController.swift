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

    @IBOutlet var slider: Slider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.labelTextAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
        slider.valueTextAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black]
        slider.minimumValue = 0
        slider.maximumValue = 500
        slider.value = 250
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
        slider.valueViewColor = .white
    }

}

