# Fluid Slider

A slider control inspired by [Virgil Pana](https://dribbble.com/shots/3868232-Fluid-Slider)

## Usage

### Slider

Slider can be inserted in a view hierarchy as a subview. Appearance of the slider can be configrured with a number of public attributes:

```swift
let slider = Slider()
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
view.addSubview(slider)
```

Take a look at `Example` project for integration example.

Since `Slider` is a subclass of `UIControl` class it inherits target-action mechanics and It's possible to listen for user-triggered value changes:
```swift
slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
```
### Tracking Behavior

There are a couple of callbacks which allow you to listent to tracking events of the Slider:
```swift
    var didBeginTracking: ((Slider) -> ())?
    var didEndTracking: ((Slider) -> ())?
```

## Animation Performance

This control is designed to use device CPU resources with care. The fluid-style animation will be disabled when low power mode is enabled or the system is under highload.
