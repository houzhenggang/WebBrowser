//
//  AppDelegate.swift
//  WebBrowser
//
//  Created by xuran on 16/2/15.
//  Copyright © 2016年 X.R. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // 注册 URL Loading System协议，使得每个请求都要经过WebCacheURLProtocol协议进行处理
        NSURLProtocol.registerClass(WebCacheURLProtocol.self)
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    // MARK: CoreData Stack
    
    // document directory url
    lazy var appDocumentDirectory: NSURL = {
        
       let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var mangedObjectModel: NSManagedObjectModel = {
    
        let modelURL = NSBundle.mainBundle().URLForResource("WebBrowser", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.mangedObjectModel)
        let sqliteURL = self.appDocumentDirectory.URLByAppendingPathComponent("webBrowserCoreData.sqlite")
        print("sqlitePath -> \(sqliteURL.absoluteString)")
        
        let failureReason = "This is an error creating or loading application's saved data."
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteURL, options: nil)
        }
        catch let error as NSError {
            // any error we got.
            var dict: [String : AnyObject] = [:]
            
            dict[NSLocalizedDescriptionKey] = "Failed to initial application save data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            let wrappedError = NSError(domain: "Your Error Domain", code: 9999, userInfo: dict)
            
            print("error: \(wrappedError)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
    
        let managedObjectCtxt: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectCtxt.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectCtxt
    }()
    
    // MARK: CoreData Save
    
    func saveContext() {
        
        if managedObjectContext.hasChanges {
            
            do {
                try managedObjectContext.save()
            }
            catch let error as NSError {
                
                print("error: \(error.localizedDescription, error.userInfo)")
                abort()
            }
        }
    }
    
    
    
}

