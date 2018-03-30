//
//  Outcome+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 10/27/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension Outcome {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Outcome> {
        return NSFetchRequest<Outcome>(entityName: "Outcome")
    }

    @NSManaged public var money: Int32
    @NSManaged public var title: String?

}
