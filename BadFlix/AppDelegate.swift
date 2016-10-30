//
//  AppDelegate.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    
    func refreshBackend() {
        MovieBackend.defaultInstance.refresh({
            (errorReturn : Error?) in
            if let error = errorReturn {
                let alertCtrl = UIAlertController(
                    title: NSLocalizedString("Backend error", comment:"Error title"),
                    message: String(format:NSLocalizedString("Could not connect to server: %@", comment: "Error message"),error.localizedDescription),
                    preferredStyle: .alert)
                // TODO: add an alternative action since this will result in an endless loop of prompts.
                alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Try Again",comment:"Button"), style: .default, handler: {
                    (_ : UIAlertAction) in
                    self.refreshBackend()
                }))
                self.window?.rootViewController?.present(alertCtrl, animated: true, completion: nil)
            }
        })
        
        GenreList.defaultInstance.refresh(nil)
    }    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        refreshBackend()
        self.window!.tintColor = UIColor(red: 0.95, green: 0.66, blue: 0.33, alpha: 1.000)
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        Fabric.with([Crashlytics.self])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let navController = secondaryViewController as? UINavigationController {
            return navController.topViewController?.isMember(of: UIViewController.self) ?? false
        }
        return false
    }

}

