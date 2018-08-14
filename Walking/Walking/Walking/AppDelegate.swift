//
//  AppDelegate.swift
//  Walking
//
//  Created by Dennis Schmidt on 13/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var application: UIApplication!
    
    var window: UIWindow?
    
    var cloudKitUser: CKRecord!
    
    var publicDB = CKContainer.default().publicCloudDatabase
    
    var cloudKeyStore: NSUbiquitousKeyValueStore!
    
    var runningInTheBackground: Bool = false
    var identifierForVendor: String!
    var deviceToken: String!

    //MARK: Initialize
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        print("\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.localizedModel) \(UIDevice.current.name)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeExternallyNotification(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: self.cloudKeyStore)
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString else { return false }
        self.identifierForVendor = identifierForVendor
        
        self.application = application
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
            
            if !granted { return }
            
            DispatchQueue.main.async {
                
                self.application.registerForRemoteNotifications()
                
            }
            
        }
        
        cloudKeyStore = NSUbiquitousKeyValueStore()
        cloudKeyStore.synchronize()
        
        cloudKitStart()
        
        return true
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        print("applicationDidEnterBackground")
        
        runningInTheBackground = true
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        print("applicationDidBecomeActive")
        
        runningInTheBackground = false
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        print("applicationWillEnterForeground")
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        print("applicationWillResignActive")
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        print("applicationWillTerminate")
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        print("supportedInterfaceOrientationsFor")
        
        return .allButUpsideDown
        
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("performFetchWithCompletionHandler")
        
        completionHandler(fetchNewDataWithCompletionHandler())
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken:\ndeviceToken \(deviceToken)")
        
        self.deviceToken = String(format: "%@", deviceToken as CVarArg).replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Error: \(error.localizedDescription)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        
        print("didReceiveRemoteNotification")
        
        print("\(userInfo)")
        
        guard let aps = userInfo["aps"] as? [AnyHashable : Any] else { return }
        guard let category = aps["category"] as? String else { return }
        
        switch category {
            
        case "xxx": //For future purpose receiving notifications from cloudKit...
            
            guard let ck = userInfo["ck"] as? [AnyHashable : Any] else { return }
            guard let qry = ck["qry"] as? [AnyHashable : Any] else { return }
            guard let rid = qry["rid"] as? String else { return }
            
            publicDB.fetch(withRecordID: CKRecordID(recordName: rid), completionHandler: { record, error in
                
                guard error == nil else { return }
                guard let _ = record else { return }
                
            })
            
        default:
            
            guard let message = aps["alert"] as? String else { return }
            
            let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
            completionHandler(UIBackgroundFetchResult.noData)
            
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("UNUserNotificationCenter")
        
        completionHandler([.alert, .sound, .badge])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("UNNotificationResponse")
        
    }
    
    //MARK: Background
    
    func fetchNewDataWithCompletionHandler() -> UIBackgroundFetchResult {
        
        print("MainView.fetchNewDataWithCompletionHandler")
        
        return .newData
        
    }
    
    //MARK: Value changed on a different device
    
    @objc func didChangeExternallyNotification(notification: NSNotification) {
        
        print("didChangeExternallyNotification")
        
        self.cloudKeyStore.synchronize()
        
    }
    
    //MARK: CloudKit
    
    func cloudKitStart() {
        
        print("cloudKitStart")
        
        CKContainer.default().fetchUserRecordID(completionHandler: { id, error in
            
            guard error == nil else { return }
            guard let id = id else { return }
            
            self.publicDB.fetch(withRecordID: id, completionHandler: { cloudKitUser, error in
                
                guard error == nil else { return }
                guard let cloudKitUser = cloudKitUser else { return }
                
                self.cloudKitUser = cloudKitUser
                
                self.publicDB.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                    
                    guard error == nil else { return }
                    guard let subscriptions = subscriptions else { return }
                    
                    var deleteThem = [String]()
                    
                    for subscription in subscriptions {
                        
                        deleteThem.append(subscription.subscriptionID)
                        
                    }
                    
                    let modify = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: deleteThem)
                    modify.database = self.publicDB
                    modify.qualityOfService = .utility
                    
                    let queue = OperationQueue()
                    queue.addOperations([modify], waitUntilFinished: false)
                    
                    modify.modifySubscriptionsCompletionBlock = { savedRecords, deletedRecordsIDs, error in
                        
                        guard error == nil else { return }
                        
                        print("All subscriptions are deleted ...")
                        
                        /*
                         Ready to add new subscriptions from cloudKit
                        */
                        
                    }
                    
                })
                
            })
            
        })
        
    }
    
}
