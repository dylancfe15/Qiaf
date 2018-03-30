//
//  SavingHistory+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/14/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension SavingHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavingHistory> {
        return NSFetchRequest<SavingHistory>(entityName: "SavingHistory")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var money: Int32
    @NSManaged public var type: String?
    @NSManaged public var note: String?
    @NSManaged public var goals: Goals?

}
