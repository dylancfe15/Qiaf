//
//  IHavePlan+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/27/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension IHavePlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IHavePlan> {
        return NSFetchRequest<IHavePlan>(entityName: "IHavePlan")
    }

    @NSManaged public var savingFrequancy: Int32
    @NSManaged public var savingMoney: Int32
    @NSManaged public var targetDate: NSDate?

}
