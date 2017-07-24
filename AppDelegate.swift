//
//  AppDelegate.swift
//  ScrollTransitionController
//
//  Created by Cobb on 2017/7/24.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var containerViewControllerDelegate: CBContainerViewControllerDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = setupMainViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupMainViewController() -> UIViewController {
        let contactVc = ViewController()
        contactVc.view.backgroundColor = UIColor.red
        let chatVc = ViewController()
        chatVc.view.backgroundColor = UIColor.purple
        let homeVc = ViewController()
        homeVc.view.backgroundColor = UIColor.orange
        let flowVc = ViewController()
        flowVc.view.backgroundColor = UIColor.brown
        
        let icons = ["icon_connections",
                     "icon_chat",
                     "icon_feature",
                     "icon_flow"
        ];
        
        let containerController = CBScrollTabBarViewController(viewControllers: [contactVc, chatVc, homeVc, flowVc], icons: icons)
        containerController.selectedIndex = 2
        containerController.homeIndex = 2
        containerViewControllerDelegate = CBContainerViewControllerDelegate()
        containerController.containerTransitionDelegate = containerViewControllerDelegate
        return containerController
    }
}

