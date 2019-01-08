<img src="https://github.com/Ramotion/folding-cell/blob/master/header.png">

<a href="https://github.com/Ramotion/folding-cell">
<img align="left" src="https://github.com/Ramotion/fluid-slider/blob/master/fluid-slider.gif" width="480" height="360" /></a>

<p><h1 align="left">FLUID SLIDER</h1></p>

<h4>A slider widget with a popup bubble displaying the precise value selected written on Swift.</h4>


___



<p><h6>We specialize in the designing and coding of custom UI for Mobile Apps and Websites.</h6>
<a href="https://dev.ramotion.com?utm_source=gthb&utm_medium=repo&utm_campaign=fluid-slider">
<img src="https://github.com/ramotion/gliding-collection/raw/master/contact_our_team@2x.png" width="187" height="34"></a>
</p>
<p><h6>Stay tuned for the latest updates:</h6>
<a href="https://goo.gl/rPFpid" >
<img src="https://i.imgur.com/ziSqeSo.png/" width="156" height="28"></a></p>
<h6><a href="https://store.ramotion.com/product/iphone-x-clay-mockups?utm_source=gthb&utm_medium=special&utm_campaign=fluid-slider#demo">Get Free Mockup For your project →</a></h6>

Inspired by [Virgil Pana](https://dribbble.com/virgilpana) [shot](https://dribbble.com/shots/3868232-Fluid-Slider)

</br>

[![Twitter](https://img.shields.io/badge/Twitter-@Ramotion-blue.svg?style=flat)](http://twitter.com/Ramotion)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Ramotion/fluid-slider)
[![codebeat badge](https://codebeat.co/badges/6f67da5d-c416-4bac-9fb7-c2dc938feedc)](https://codebeat.co/projects/github-com-ramotion-fluid-slider)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/Ramotion)

## Requirements

- iOS 10.0  
- Xcode 9    
- Swift 4.0

## Installation
You can install `fluid-slider` in several ways:

- Add source files to your project.

<br>

- Use [CocoaPods](https://cocoapods.org):
``` ruby
pod 'fluid-slider'
```

<br>

- Use [Carthage](https://github.com/Carthage/Carthage):
```
github "Ramotion/fluid-slider"
```

## Usage

### Slider

```swift
import fluid_slider
```

The slider can be inserted in a view hierarchy as a subview. Appearance can be configured with a number of public attributes:

```swift
let slider = Slider()
slider.attributedTextForFraction = { fraction in
    let formatter = NumberFormatter()
    formatter.maximumIntegerDigits = 3
    formatter.maximumFractionDigits = 0
    let string = formatter.string(from: (fraction * 500) as NSNumber) ?? ""
    return NSAttributedString(string: string)
}
slider.setMinimumLabelAttributedText(NSAttributedString(string: "0"))
slider.setMaximumLabelAttributedText(NSAttributedString(string: "500"))
slider.fraction = 0.5
slider.shadowOffset = CGSize(width: 0, height: 10)
slider.shadowBlur = 5
slider.shadowColor = UIColor(white: 0, alpha: 0.1)
slider.contentViewColor = UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
slider.valueViewColor = .white
view.addSubview(slider)
```

Take a look at the `Example` project for an integration example.

Since `Slider` is a subclass of `UIControl`, it inherits target-action mechanics and it's possible to listen for user-triggered value changes:
```swift
slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
```
### Tracking Behavior

There are a couple of callbacks which allow you to listen to the slider's tracking events:
```swift
    var didBeginTracking: ((Slider) -> ())?
    var didEndTracking: ((Slider) -> ())?
```

## Animation Performance

This control is designed to use device CPU resources with care. The fluid-style animation will be disabled when low power mode is enabled or the system is under heavy load.


This library is a part of a <a href="https://github.com/Ramotion/swift-ui-animation-components-and-libraries"><b>selection of our best UI open-source projects.</b></a>


## 🗂 Check this library on other language:
<a href="https://github.com/Ramotion/fluid-slider-android">
<img src="https://github.com/Ramotion/navigation-stack/blob/master/Android_Kotlin@2x.png" width="178" height="81"></a>


## 📄 License

Fluid Slider is released under the MIT license.
See [LICENSE](./LICENSE) for details.

This library is a part of a <a href="https://github.com/Ramotion/swift-ui-animation-components-and-libraries"><b>selection of our best UI open-source projects.</b></a>

If you use the open-source library in your project, please make sure to credit and backlink to www.ramotion.com

## 📱 Get the Showroom App for iOS to give it a try
Try this UI component and more like this in our iOS app. Contact us if interested.

<a href="https://itunes.apple.com/app/apple-store/id1182360240?pt=550053&ct=fluid-slider&mt=8" >
<img src="https://github.com/ramotion/gliding-collection/raw/master/app_store@2x.png" width="117" height="34"></a>

<a href="https://dev.ramotion.com?utm_source=gthb&utm_medium=repo&utm_campaign=fluid-slider">
<img src="https://github.com/ramotion/gliding-collection/raw/master/contact_our_team@2x.png" width="187" height="34"></a>
