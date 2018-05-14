

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   var window: UIWindow?

  // test 1
  
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      // Override point for customization after application launch.
      return true
   }

  func applicationDidBecomeActive(_ application: UIApplication) {
    print("applicationDid Become Active added in feature/Test1")
  }

}

