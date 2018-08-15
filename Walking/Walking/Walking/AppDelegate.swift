//
//  AppDelegate.swift
//  Walking
//
//  Created by Dennis Schmidt on 13/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit
import CloudKit
import SQLite3
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var application: UIApplication!
    
    var window: UIWindow?
    
    var cloudKitUser: CKRecord!
    
    var publicDB = CKContainer.default().publicCloudDatabase
    
    var cloudKeyStore: NSUbiquitousKeyValueStore!
    
    var db: OpaquePointer? = nil
    
    var runningInTheBackground: Bool = false
    var identifierForVendor: String!
    var deviceToken: String!

    let dateFormatter = DateFormatter()
    
    //MARK: Initialize
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        print("\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.localizedModel) \(UIDevice.current.name)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeExternallyNotification(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: self.cloudKeyStore)
        
        (self.window?.rootViewController as! MainView).parentView = self
        
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "da_DK")
        
        let fileManager = FileManager.default
        
        let bundlePath = Bundle.main.path(forResource: "walking", ofType: ".db")
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("walking.db")
        let fullDestPathString = fullDestPath!.path
        print(fullDestPathString)
        
        if fileManager.fileExists(atPath: fullDestPathString) {
            
            print("Database is available")
            
            /*
            do {
             
                try fileManager.removeItem(at: fullDestPath!)
             
             } catch {
             
                print(error)
             
                return false
             
             }
            */
            
        } else {
            
            do {
                
                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString)
                
            } catch {
                
                return false
                
            }
            
        }

        self.db = self.databaseOpen()

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
    
    //MARK: Database
    
    func databaseOpen() -> OpaquePointer? {
        
        var db: OpaquePointer? = nil
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("walking.db")
        
        sqlite3_shutdown()
        sqlite3_initialize()
        
        print("isThreadSafe \(sqlite3_threadsafe())")
        
        if sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            
            print("Successfully opened connection to database at \(fileURL.path)")
            
            return db
            
        } else {
            
            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
            
            return nil
            
        }
        
    }
    
    func databaseLastID() -> Int {
        
        var id: Int = -1
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, "SELECT LAST_INSERT_ROWID();", -1, &stmt, nil) == SQLITE_OK {
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                
                id = Int(sqlite3_column_int(stmt, 0))
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        return id
        
    }
    
    func databaseInsert(object: AnyObject) -> Bool {
        
        var result: Bool = false
        var query: String!
        
        switch object {
            
        case is Journey:
            
            print("Object is Journey")
            
            if let identity = object as? Journey {
                
                query = "INSERT INTO journey (title, starting, ending, distance, note) VALUES ('\(identity.title!)', '\(dateFormatter.string(from: Date()))', '\(dateFormatter.string(from: Date()))', '0', '\(identity.note!)');"
                
            }
            
        case is LocationNow:
            
            print("Object is LocationNow")
            
            if let identity = object as? LocationNow {
                
                query = "INSERT INTO position (journeyID, latitude, longitude) VALUES (\(identity.journeyID), '\(identity.latitude)', '\(identity.longitude)');"
                
            }
            
        default:
            
            print("Object is wrong")
            
        }
        
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                
                object.setValue(String(databaseLastID()), forKey: "id")
                
                result = true
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        return result
        
    }
    
    func databaseUpdate(object: AnyObject) -> Bool {
        
        var result: Bool = false
        var query: String!
        
        switch object {
            
        case is Journey:
            
            print("Object is Journey")
            
            if let identity = object as? Journey {
                
                query = "UPDATE journey SET title = '\(identity.title!)', ending = '\(dateFormatter.string(from: Date()))', distance = '\(identity.distance)', note = '\(identity.note!)' WHERE id = \(identity.id!);"
                
            }
            
        default:
            
            print("Object is wrong")
            
        }
        
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                
                result = true
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        return result
        
    }
    
    func databaseQuery(query: String) -> Bool {
        
        print("\(query)")
        
        var result: Bool = false
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                
                result = true
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        return result
        
    }

}
