///
///  NMPAnchorOverlayView.swift
///
///  Created by Narumol Pugkhem on 5/8/17.
///  Copyright © 2017 Systability. All rights reserved.
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to deal
///  in the Software without restriction, including without limitation the rights
///  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
///  copies of the Software, and to permit persons to whom the Software is
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in
///  all copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
///  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
///  THE SOFTWARE.

/*
 NMPAnchorOverlayView mimics the functionality of the Control Center from iPhone. 
 It is basically a UIView that lets you slide to expand which reveals extra utilities
 buttons, labels, textfields, imageViews etc. and to shrink to regain your App real-estate.
 The API allows the view to  anchor itself at it’s top or bottom edge of it’s 
 parent viewController’s view to suit your overall App design. This API supports
 both initialization from code or conveniently layout in storyboard.

 */

import UIKit

@objc protocol NMPAnchorOverlayViewDelegate {
   @objc optional func NMPAnchorOverlayViewDidExpand(view: UIView)
   @objc optional func NMPAnchorOverlayViewDidShrink(view: UIView)
   @objc optional func NMPAnchorOverlayViewWillExpand(view: UIView)
   @objc optional func NMPAnchorOverlayViewWillShrink(view: UIView)
}

class NMPAnchorOverlayView: UIView {
   
   enum NMPAnchorOverlayViewError: Error {
      case errorViewHeightConstraintNotSet
      case errorSuperViewTopOrBottomMarginNotSet
      case errorInitWithStoryBoard
      case errorInitWithFrame
   }
   
   enum SlideDirection {
      case none, up, down
   }
   
   enum AnchorLocation {
      case top, bottom
   }
   
   // The view is closed or opened
   enum ViewState {
      case shrink, expand
   }
   
   // MARK: - class variables
   
   class var NMPAnchorOverlayViewOpenHeight: CGFloat {
      return 150
   }
   class var NMPAnchorOverlayViewCloseHeight: CGFloat {
      return 25.0
   }
   
   // MARK: - Internal Properties
   
   var delegate: NMPAnchorOverlayViewDelegate?
   var anchorLocation: AnchorLocation = .top
   var maxHeight: CGFloat! = NMPAnchorOverlayViewOpenHeight
   var minHeight: CGFloat! = NMPAnchorOverlayViewCloseHeight
   
   // MARK: -  Parameters for view animation when expand or shrink
   // Refer to the developer api reference for more details
   // https://developer.apple.com/reference/uikit/uiview/1622594-animatewithduration
   
   // Total duration, measured in seconds
   var animDuration: TimeInterval = 0.4
   // Amount of time to wait before the animation begins, default
   // is 0.0 which begin immidiately, measured in seconds
   var animDelay: TimeInterval = 0.0
   // The damping ratio for spring animation default to 0.7
   var animSpringDampingRatio: CGFloat = 0.6
   // The initial spring velocity
   var animInitialSpringVelocity: CGFloat = 20.0
   
   // The amount of relative verticle movement of view at the end
   // of animation ranges 0.01 - 1.0
   var animClearance: CGFloat = 0.7

   
   // MARK: - Read only public Properties
   
   public private(set) weak var trailingConstraint: NSLayoutConstraint!
   public private(set) weak var leadingConstraint: NSLayoutConstraint!
   public private(set) weak var heightConstraint: NSLayoutConstraint!
   public private(set) weak var topConstraint: NSLayoutConstraint?
   public private(set) weak var bottomConstraint: NSLayoutConstraint?
   public private(set) var viewState: ViewState = .shrink
   public private(set) var yMargin: CGFloat! = 35.0
   
   // MARK: - Private Variables
   
   private var startHeight: CGFloat!
   private var startPoint: CGPoint = CGPoint.zero
   private var slideDirection: SlideDirection = .none
   private var mySuperView: UIView?
   
   
   /// Set to True if the view is initiated by story board otherwise set to False.
   /// Uses observer willSet to set some other properties if the view is created programatically.
   /// - Returns: n/a
   private var useStoryBoard: Bool! {
      willSet {
         guard let value = newValue else { return }
         if value == false {
            self.layer.cornerRadius = 10.0
            self.clipsToBounds = true
            self.backgroundColor = UIColor.init(white: 0.8, alpha: 0.5)
         }
      }
   }
   
   
   // MARK: -  Initializer methods
   
   /// Storyboard initializer
   /// - Returns:
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      commonInit()
      useStoryBoard(newValue: true)
   }
   
   
   /// Designated Initializer to set size, anchor location, vertical margin from edge of the view.
   /// - Returns: n/a
   init(size: CGSize, anchorLocation: AnchorLocation = .top, yMargin: CGFloat = 35.0) {
      super.init(frame: CGRect(origin: CGPoint.zero, size: size))
      
      self.anchorLocation = anchorLocation
      self.yMargin = abs(yMargin)
      commonInit()
      useStoryBoard(newValue: false)
   }
   
   
   /// Convenience Init to set aditional min and max height of this view
   /// - Returns:
   convenience init(size: CGSize, anchorLocation: AnchorLocation = .top, yMargin: CGFloat = 35.0, minimumHeight: CGFloat = NMPAnchorOverlayView.NMPAnchorOverlayViewCloseHeight, maximumHeight: CGFloat = NMPAnchorOverlayView.NMPAnchorOverlayViewOpenHeight) {
      
      self.init(size: size, anchorLocation: anchorLocation, yMargin: yMargin)
      self.minHeight = minimumHeight
      self.maxHeight = maximumHeight
   }
   
   
   /// Set the common appearance of the view.
   /// - Returns: n/a
   private func commonInit() {
      self.startHeight = minHeight
      self.translatesAutoresizingMaskIntoConstraints = false
   }
   
   
   /// Override method. Called when this view is added to superview which mean we can
   /// add neccessary constraints.
   /// - Returns: n/a
   override func didMoveToSuperview() {
      
      if mySuperView != self.superview && !useStoryBoard {
         mySuperView = self.superview
         addConstraintsToSuperView()
      }
   }
   
   // MARK: -  private properties setter methods
   
   /// A setter method for 'useStoryBoard' property, to allow the use of observer 'willSet'
   /// - Returns: n/a
   private func useStoryBoard(newValue: Bool) {
      self.useStoryBoard = newValue
   }
   
   // MARK: -  Public methods
   
   /// For view created from storyboard: Must call by parent view controller to connects
   /// the required iboutlet constraints of the parent view controller to those of this view.
   /// - Returns: n/a
   /// - Throws: NMPAnchorOverlayViewError.errorInitWithFrame
   func addIBOutletConstraintsFromParentViewController(leading: NSLayoutConstraint, trailing: NSLayoutConstraint ,height: NSLayoutConstraint, topMargin:NSLayoutConstraint?, bottomMargin: NSLayoutConstraint?) throws {
      
      guard useStoryBoard else { throw NMPAnchorOverlayViewError.errorInitWithStoryBoard }
      
      leadingConstraint = leading
      trailingConstraint = trailing
      
      // Init ivar with passed argument then modify the constant
      heightConstraint = height
      heightConstraint.constant = minHeight
      
      // Use the passed value to set maxHeight
      maxHeight = height.constant
      
      // Need to set at least top margin. Both top and bottom margin may be set but
      // top margin has priority over bottom margin, only one will be affectuated.
      if (topMargin != nil) {
         topConstraint = topMargin
         anchorLocation = .top
      } else if (bottomMargin != nil) {
         bottomConstraint = bottomMargin
         anchorLocation = .bottom
      }
      else {
         // Neither top nor bottom margins passed
         throw NMPAnchorOverlayViewError.errorSuperViewTopOrBottomMarginNotSet
      }
   }
   
   
   /// For view created from code: Must call by parent view controller after the call to addSubview()
   /// This will add neccessary constraints of the view to it's superview.
   /// - Returns: n/a
   private func addConstraintsToSuperView()  {
      
      guard !useStoryBoard else { return }
      guard let mySuperView = self.mySuperView else { return }
      
      if anchorLocation == .top {
         self.topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: mySuperView, attribute: .top, multiplier: 1, constant: abs(yMargin))
      } else if anchorLocation == .bottom {
         self.bottomConstraint = self.bottomAnchor.constraint(equalTo: mySuperView.bottomAnchor, constant: -abs(yMargin))
      }
      
      let hSpace = abs(mySuperView.frame.width - frame.width)
      
      self.leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: mySuperView, attribute: .leading, multiplier: 1, constant: hSpace/2 )
      
      self.trailingConstraint =  NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: mySuperView, attribute: .trailing, multiplier: 1, constant: -hSpace/2 )
      
      self.heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: self.minHeight)
      
      if topConstraint != nil {
         mySuperView.addConstraint(topConstraint!)
      } else if bottomConstraint != nil {
         mySuperView.addConstraint(bottomConstraint!)
      }
      mySuperView.addConstraints( [leadingConstraint,trailingConstraint, heightConstraint])
   }
   
   
   /// A parent view controller can call this function
   /// when it needs to close the view to regain it's real estate.
   /// This method changes size and animates.
   /// - Returns: n/a
   func closeView() {
      guard heightConstraint.constant == maxHeight else { return }
      
      if self.anchorLocation == .bottom {
         self.slideDirection = .down
      } else if self.anchorLocation == .top {
         self.slideDirection = .up
      }
      
      modifyHeightConstraints()
      animateViewTransition( duration: animDuration, delay: animDelay, clearance: animClearance, springDampingRatio: animSpringDampingRatio, initialSpringVelocity: animInitialSpringVelocity ) {
         self.slideDirection = .none
      }
   }
   
   
   // MARK: - Override Methods
   
   
   /// Called when the view is touched. Saves the touch point location and current view's height.
   /// And resets slide-direction.
   /// - Returns: n/a
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let  touch = touches.first else { print("no touches"); return }
      
      startPoint = touch.location(in: self)
      startHeight = heightConstraint.constant
      slideDirection = .none
      super.touchesBegan(touches, with: event)
   }
   
   
   /// Calculates the new height constraint during finger drag, updates the height
   /// and set direction.
   /// - Returns: n/a
   override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else { print("touchesMovedno touches"); return }
      
      let endPoint = touch.location(in: self)
      let diff = endPoint.y - startPoint.y
      
      // This causes the view to move along the drag
      switch anchorLocation {
      case .top :
         heightConstraint.constant = startHeight + diff
      case .bottom :
         heightConstraint.constant = startHeight - diff
      }
      self.layoutIfNeeded()
      
      // Update direction
      if diff == 0.0 {
         self.slideDirection = .none
      } else {
         self.slideDirection = (diff > 0) ? .down : .up
      }
      super.touchesMoved(touches, with: event)
   }
   
   
   /// Limits the height to min and max values when the touch has ended.
   /// - Returns: n/a
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      
      self.modifyHeightConstraints()
      self.animateViewTransition(duration: animDuration, delay: animDelay, clearance: animClearance, springDampingRatio: animSpringDampingRatio, initialSpringVelocity: animInitialSpringVelocity, complete: {
         self.slideDirection = .none
      })
      super.touchesEnded(touches, with: event)
   }
   
   
   // MARK: - Private Functions
   
   /// Animates the view movement to mimic the spring bouncing
   /// when open or close the view.
   /// - duration: animate duration in second
   /// - delay: delay in second before animation starts
   /// - clearance: value 0 - 1, relative movements of the view when expand or shrink.
   /// - Returns: n/a
   private func animateViewTransition(duration: TimeInterval, delay: TimeInterval, clearance: CGFloat, springDampingRatio: CGFloat, initialSpringVelocity: CGFloat, complete:@escaping ()->Void) {
      var moveSpace = clearance >= 1.0 ? 1.0 : clearance
      moveSpace = moveSpace < 0.05 ? 0.05 : moveSpace
      moveSpace = moveSpace * 100
      
      UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springDampingRatio, initialSpringVelocity: initialSpringVelocity, options: .curveEaseOut, animations: {
         
         switch self.anchorLocation {
         case .top :
            if self.slideDirection == .up {
               self.center.y += moveSpace
               self.delegate?.NMPAnchorOverlayViewWillShrink?(view: self)
            }
            else if self.slideDirection == .down {
               self.center.y -= moveSpace
               self.delegate?.NMPAnchorOverlayViewWillExpand?(view: self)
            }
            self.layoutIfNeeded()
            
         case .bottom :
            if self.slideDirection == .down {
               self.center.y += moveSpace
               self.delegate?.NMPAnchorOverlayViewWillShrink?(view: self)
            }
            else if self.slideDirection == .up {
               self.center.y -= moveSpace
               self.delegate?.NMPAnchorOverlayViewWillExpand?(view: self)
            }
            self.layoutIfNeeded()
         }
      }) { _ in
         
         switch self.anchorLocation {
         case .top :
            if self.slideDirection == .up { self.delegate?.NMPAnchorOverlayViewDidShrink?(view: self) }
            else if self.slideDirection == .down { self.delegate?.NMPAnchorOverlayViewDidExpand?(view: self) }
            self.layoutIfNeeded()
            
         case .bottom :
            if self.slideDirection == .down { self.delegate?.NMPAnchorOverlayViewDidShrink?(view: self) }
            else if self.slideDirection == .up { self.delegate?.NMPAnchorOverlayViewDidExpand?(view: self) }
            self.layoutIfNeeded()
         }
         complete()
      }
   }
   
   
   /// Sets height constraints to change view's height to min/max values.
   /// - Returns: n/a
   private func modifyHeightConstraints() {
      
      if self.anchorLocation == .bottom {
         switch self.slideDirection {
         case .down:
            self.heightConstraint.constant = self.minHeight
            viewState = .shrink
         case .up:
            self.heightConstraint.constant = self.maxHeight
            viewState = .expand
         case .none:
            break
         }
      } else if self.anchorLocation == .top {
         switch self.slideDirection {
         case .up:
            self.heightConstraint.constant = self.minHeight
            viewState = .shrink
         case .down:
            self.heightConstraint.constant = self.maxHeight
            viewState = .expand
         case .none:
            break
         }
      }
   }
}








