//
//  ViewController.swift
//  NMPAnchorOverlayViewExample project
//
//  Created by Narumol Pugkhem on 5/8/17.
//  Copyright © 2017 Narumol. All rights reserved.
//
// This is the main viewController of NMPAnchorOverlayViewExample app.
// It's main purpose is to demonstrate usage of NMPAnchorOverlayView. 
// It creates two NMPAnchorOverlayView instances as subviews; one is anchored
// to the top and the other to the bottom.

// some work done
// some more work done


import UIKit

class ViewController: UIViewController, NMPAnchorOverlayViewDelegate {
   
   var slideView: NMPAnchorOverlayView!
   internal let ImageNames = ["playful", "bark", "sweet"]
   
   @IBOutlet weak var stbView: NMPAnchorOverlayView!
   @IBOutlet weak var B4: UIButton!
   
   // Constraints IBOutlets
   
   @IBOutlet weak var heightCt: NSLayoutConstraint!
   @IBOutlet weak var bottomCt: NSLayoutConstraint!
   @IBOutlet weak var leftCt: NSLayoutConstraint!
   @IBOutlet weak var rightCt: NSLayoutConstraint!
   
   // MARK: -  Private variables
   
   private var button: UIButton!
   
   /// Add two NMPAnchorOverlayView instances on ViewController's view
   /// - Returns: n/a
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // 1 Create programatically
      //
      let size: CGSize = CGSize(width: view.frame.width - 20, height: view.bounds.height)
      slideView = NMPAnchorOverlayView(size: size,  anchorLocation: .top, maximumHeight: 500)
      
      // Additional Properties
      //
      slideView.minHeight = 28.0
      slideView.backgroundColor = UIColor.green
      slideView.layer.cornerRadius = 12.0
      
      // Set delegate and add view
      slideView.delegate = self
      self.view.addSubview(slideView)
      
      // Add additional view to AanchorOverlayView
      addStuffOnSlideView()
      
      // 2 Create from storyboard, then call this method to add IBOutlets contraints on an
      // NMPAnchorOverlayView instance
      //
      
      do {
         try stbView.addIBOutletConstraintsFromParentViewController(leading: leftCt, trailing: rightCt, height: heightCt, topMargin: nil, bottomMargin: bottomCt)
      } catch {
         print("error add const")
      }
      
      // Set additional properties
      stbView.maxHeight = 500
      stbView.minHeight = 25
//      stbView.animSpringDampingRatio = 0.2
//      stbView.animClearance = 0.7
      
      // Set delegate
      stbView.delegate = self
      
      // Optionally hide the NMPAnchorOverlayView instance's subviews
      for v in stbView.subviews {
         v.isHidden = true
      }
   }
   
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

   /// Add a purple view on NMPAnchorOverlayView's instance
   /// - Returns:
   func addStuffOnSlideView() {
      button = UIButton(frame: CGRect(x:0, y:0, width:150, height: (slideView.maxHeight)/3))
      button.backgroundColor = UIColor.lightGray
      button.isHidden = true
      button.setTitle("BUTTON !", for: .normal)
      button.titleLabel?.adjustsFontSizeToFitWidth = true
      button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      button.layer.cornerRadius = 8.0
      slideView.addSubview(button)
   }
   
   
   /// Close AnchorOverlay instance views when a finger touches outside the view
   /// - Returns: n/a
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let  touch = touches.first else { return }
      let point = touch.location(in: view)
      
      if !( stbView.frame.contains(point) || slideView.frame.contains(point)) {
         for v in view.subviews {
            if v is NMPAnchorOverlayView {
               (v as! NMPAnchorOverlayView).closeView()
            }
         }
      }
   }
   
   
   // MARK: -  AnchorOverlayView Delegate
   
   /// Hide the button after the slideView close
   /// - Returns: n/a
   func NMPAnchorOverlayViewDidShrink(view: UIView) {
      
      if view === slideView {
         UIView.animate(withDuration: 0.5) {
            self.button.alpha = 0.0
            self.button.isHidden = true
         }
      }
   }
   
   
   /// Hide subviews of stbView
   /// - Returns: n/a
   func NMPAnchorOverlayViewWillShrink(view: UIView) {
      
      if view === stbView {
         UIView.animate(withDuration: 0.3) {
            for v in self.stbView.subviews {
               v.isHidden = true
            }
         }
      }
   }
   
   
   /// Show the button and animate
   /// - Returns: n/a
   func NMPAnchorOverlayViewDidExpand(view: UIView) {
      
      if view === slideView {
         button.center.x = slideView.bounds.width/2
         button.center.y = slideView.bounds.height/2
         
         UIView.animate(withDuration: 0.5) {
            self.button.alpha = 1.0
            self.button.isHidden = false
         }
      }
   }
   
   
   /// Show stbView's subviews
   /// - Returns: n/a
   func NMPAnchorOverlayViewWillExpand(view: UIView) {
      if view === stbView {
         UIView.animate(withDuration: 0.3) {
            for v in self.stbView.subviews {
               v.isHidden = false
            }
         }
      }
   }
   
}

// Extra fun stuff
// ViewController extension includes button tapped action methods
// Watch the doc images fly to different directions when with animations.

extension ViewController {
   
   @nonobjc static var b4Index = 2
   
   /// Create an image view with dog image
   /// - Returns: imageView: UIImage
   func makeImageView(index: Int) -> UIImageView {
      
      let imageView = UIImageView(image: UIImage(named: ImageNames[index]))
      imageView.backgroundColor = UIColor.clear
      imageView.layer.cornerRadius = 15.0
      imageView.clipsToBounds = true
      imageView.contentMode = .scaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      return imageView
   }
   
   
   /// Display image with animation when left button pressed
   /// - Returns: n/a
   @IBAction func b2Pressed(_ sender: Any) {
      
      let imageView = makeImageView(index: 0)
      view.addSubview(imageView)
      
      let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height + 200 )
      let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.53, constant: 0.0)
      let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
      NSLayoutConstraint.activate([conX, conBottom, conWidth, conHeight])
      view.layoutIfNeeded()
      
      //Animate in
      UIView.animate( withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10.0, animations: {
         conBottom.constant = -imageView.frame.size.height / 2
         conWidth.constant = 0.0
         self.view.layoutIfNeeded()
      }, completion: nil)
      
      //Animate out
      UIView.animate( withDuration: 0.67, delay: 1.0, animations: {
         conX.constant += 350
         conWidth.constant = -20.0
         self.view.layoutIfNeeded()
      },completion: { _ in
         imageView.removeFromSuperview()
      })
   }
   
   
   /// Display image with animation when middle button pressed
   /// - Returns: n/a
   @IBAction func b3Pressed(_ sender: Any) {
      
      let imageView = makeImageView(index: 1)
      view.addSubview(imageView)
      
      let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      let conTop = imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
      let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: 10.0)
      let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
      NSLayoutConstraint.activate([conX, conTop, conWidth, conHeight])
      view.layoutIfNeeded()
      
      //Animate in
      UIView.animate( withDuration: 3.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5.0, animations: {
         conTop.constant = imageView.frame.size.height * 2
         conWidth.constant = imageView.frame.size.width * 0.7
         self.view.layoutIfNeeded()
      }, completion: nil)
      
      //Animate ratation
      UIView.animate( withDuration: 5.0, delay: 1.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: [], animations: {
         let angle: CGFloat = .pi
         imageView.transform = CGAffineTransform(rotationAngle: angle)
         self.view.layoutIfNeeded()
      })
      
      //Animate out
      UIView.animate( withDuration: 3.67, delay: 2.0, animations: {
         conTop.constant = -imageView.frame.size.width / 3
         conWidth.constant = -50.0
         self.view.layoutIfNeeded()
      }) { _ in
         imageView.removeFromSuperview()
      }
   }
   
   
   /// Display image with animation when right button pressed
   /// - Returns: n/a
   @IBAction func b4Pressed(_ sender: Any) {
      
      let imageView = makeImageView(index: ViewController.b4Index)
      view.addSubview(imageView)
      
      let conX = imageView.centerXAnchor.constraint(equalTo: B4.centerXAnchor)
      let conTop = imageView.topAnchor.constraint(equalTo: B4.topAnchor)
      let conWidth = imageView.widthAnchor.constraint(equalTo: B4.widthAnchor)
      let conHeight = imageView.heightAnchor.constraint(equalTo: B4.heightAnchor)
      
      NSLayoutConstraint.activate([conX, conTop, conWidth, conHeight])
      view.layoutIfNeeded()
      let ratio:CGFloat = 2.0
      
      //Animate in
      UIView.animate( withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 3.0, animations: {
         conWidth.constant = imageView.frame.size.width * ratio
         conHeight.constant = imageView.frame.size.height * ratio
         conX.constant -= abs(imageView.center.x - self.view.center.x)
         self.view.layoutIfNeeded()
      }) { _ in
         UIView.transition(with: imageView, duration: 2.0, options: .transitionCrossDissolve, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: .pi/8)
            imageView.image = UIImage(named: self.ImageNames[ViewController.b4Index])
            ViewController.b4Index = (ViewController.b4Index + 1) % 3
         })
      }
      
      //Animate out
      UIView.animate( withDuration: 2.0, delay: 3.5, animations: {
         conWidth.constant = 0.0
         conHeight.constant = 0.0
         conX.constant = 0.0
         imageView.transform = CGAffineTransform(rotationAngle: -.pi)
         self.view.layoutIfNeeded()
      }) { _ in
         imageView.removeFromSuperview()
         self.B4.setImage(imageView.image, for: .normal)
      }
   }
   
}

