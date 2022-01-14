//
//  AppDelegate.swift
//  Demo
//
//  Created by Appinventiv on 5/19/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var backgroundTaskTimer:Timer! = Timer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.doBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if self.backgroundTaskTimer != nil {
            self.backgroundTaskTimer.invalidate()
            self.backgroundTaskTimer = nil
        }
    }
}


extension AppDelegate{
    
    func doBackgroundTask() {
        DispatchQueue.global(qos: .default).async {
            self.beginBackgroundTask()
            
            if self.backgroundTaskTimer != nil {
                self.backgroundTaskTimer.invalidate()
                self.backgroundTaskTimer = nil
            }
            
            //Making the app to run in background forever by calling the API
            self.backgroundTaskTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTracking), userInfo: nil, repeats: true)
            RunLoop.current.add(self.backgroundTaskTimer, forMode: RunLoop.Mode.default)
            RunLoop.current.run()
            
            // End the background task.
            self.endBackgroundTask()
            
        }
    }
    
    func beginBackgroundTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(withName: "Track trip", expirationHandler: {
            self.endBackgroundTask()
        })
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    @objc func startTracking(){
        print("Calling")
    }
}
