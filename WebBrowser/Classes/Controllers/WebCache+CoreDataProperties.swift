//
//  WebCache+CoreDataProperties.swift
//  WebBrowser
//
//  Created by xuran on 16/8/1.
//  Copyright © 2016年 X.R. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WebCache {
    
    @NSManaged var data: NSData?
    @NSManaged var url: String?
    @NSManaged var encoding: String?
    @NSManaged var mimetype: String?
    @NSManaged var timestamp: NSDate?

}
