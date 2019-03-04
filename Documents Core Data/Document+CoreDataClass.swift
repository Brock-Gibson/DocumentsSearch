//
//  Document+CoreDataClass.swift
//  Documents Core Data
//
//  Created by Brock Gibson on 2/19/19.
//  Copyright © 2019 Brock Gibson. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Document)
public class Document: NSManagedObject {
    var date: Date? {
        get {
            return rawDateModified as Date?
        }
        set {
            rawDateModified = newValue as NSDate?
        }
    }
    
    convenience init?(name: String?, content: String?, date: Date, size: String) {
        let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Document.entity(), insertInto: managedContext)
        
        self.name = name
        self.content = content
        self.date = date
        self.size = Int32(size.utf8.count)
    }
}
