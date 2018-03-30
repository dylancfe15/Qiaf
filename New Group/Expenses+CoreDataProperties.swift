//
//  Expenses+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/27/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension Expenses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses> {
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }

    @NSManaged public var amount: Double
    @NSManaged public var categry: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var title: String?

}
