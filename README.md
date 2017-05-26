# NMPAnchorOverlayView

NMPAnchorOverlayView mimics the functionality of the Control Center from the iPhone. It is a UIView based component that lets the user slide to expand (revealing any components you may have placed in it such as buttons, labels, textfields, imageViews etc.) and to slide it back in its entirety or partially thereby regaining screen real estate. The component implements sliding with an animated bounch effect. The API allows the view to anchor itself at it’s top or bottom edge of it’s parent viewController’s view to suit your overall App design. This API support both initialization from code or storyboard.

Just like a regular UIView, you can change NMPAnchorOverlayView's' appearance to suit your needs. This includes backgroundColor, cornerRadius, border width, alpha, tintColor, contentMode just to name a few.

# Features
- Swift 3.0
- iOS 9.0 
- Supports code or storyboard initialization
- Works like any UIView where you can add as many subviews as you like
- backgroundColor, tintColor, cornerRadius, alpha and other UIView properties can be specified
- Uses delegation to notify view expand and shrink states
- Minimum and maximum height properties of the view can be specified
- Vertical margin (yMargin) property lets your place the view anywhere you want
- Supports top or bottom anchor location

## Installation
Download the NMPAnchorOverlayView.swift

## Initialized in code
To create NMPAnchorOverlayView programmatically from a parent viewController, use init function as follows

      let size: CGSize = CGSize(width: view.bounds.width - 20, height: view.bounds.height)
      let yMargin: CGFloat = 50.0
      slideView = NMPAnchorOverlayView(size: size, anchorLocation: .top, yMargin: yMargin)
      
      // Additional Properties
      slideView.maxHeight = 300
      slideView.minHeight = 30
      slideView.backgroundColor = UIColor.green
      slideView.layer.cornerRadius = 12.0

      // Set delegate and add view
      slideView.delegate = self
      self.view.addSubview(slideView)

### Convenience init function:  
convenience init(size: CGSize, anchorLocation: AnchorLocation = .top, yMargin: CGFloat, minimumHeight: CGFloat, maximumHeight: CGFloat)

- size: the original size of an NMPAnchorOverlayView instance. The view will be created with the width from size.width and will appear with height of minHeight. 
- minHeight: the size of view in shrink state
- maxHeight: the size of view in expand state
- anchorLocation: indicates whether the view will anchor it’s top or bottom to it’s superview. .top is the default location
- yMargin: the space from the view’s top edge to that of it’s superview for top anchor location. Space from view’s bottom edge to that of it’s superview for bottom anchor location. 

Using Default Parameter in init methods, a NMPAnchorOverlayView instance can be initiated by one or more parameters as follows

- let defaultTopAnchoredView = NMPAnchorOverlayView(size: size)
- let bottomAnchoredView = NMPAnchorOverlayView(size: size, anchorLocation: .bottom)
- let veryLargeTopAnchoredView  = NMPAnchorOverlayView(size: size, maximumHeight: 700)

## Initialized in Storyboard
1) Add a UIView object in parent viewController's view
2) Set custom class to NMPAnchorOverlayView, this can be done in the Custom Class section in identity inspector panel. 
3) Add the following constraints to your custom view: Height, Trailing Space, Leading Space, and either Top Space or Bottom Space constraint depending on whether your custom view should be anchored to top or bottom. 
4) Connect all four constraints @IBOutlets to your parent ViewController in code. 
(Refer to Example project).

- 1   @IBOutlet weak var heightCt: NSLayoutConstraint!
- 2   @IBOutlet weak var leftCt: NSLayoutConstraint!
- 3   @IBOutlet weak var rightCt: NSLayoutConstraint!
- 4   @IBOutlet weak var bottomCt: NSLayoutConstraint! or @IBOutlet weak var topCt: NSLayoutConstraint! 

## Delegate methods
To get notified of view’s state you can implement following optional four methods.

##### func AnchorOverlayViewDidExpand(view: UIView)
##### func AnchorOverlayViewDidShrink(view: UIView)
##### func AnchorOverlayViewWillExpand(view: UIView)
##### func AnchorOverlayViewWillShrink(view: UIView)

## Animation Parameters
The animation of view’s expand and shrink can be modified with the following parameters, refer to NMPAnchorOverlayView.swift 
and the developer api reference for more details https://developer.apple.com/reference/uikit/uiview/1622594-animatewithduration
   
- animDuration: TimeInterval with default value of 0.4
- animDelay: TimeInterval default value of 0.0
- animSpringDampingRatio: CGFloat = 0.6
- animInitialSpringVelocity: CGFloat = 20.0
- animClearance: CGFloat = 0.7

## Author 
Narumol Pugkhem

## Demo

![img](https://github.com/narumolp/NMPAnchorOverlayView/blob/master/Gif/demo.gif)
