//
//  GoalInfo+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/27/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension GoalInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalInfo> {
        return NSFetchRequest<GoalInfo>(entityName: "GoalInfo")
    }

    @NSManaged public var goalAmount: Int32
    @NSManaged public var goalSavings: Int32
    @NSManaged public var goalTask: Int32
    @NSManaged public var goalTitle: String?

}
