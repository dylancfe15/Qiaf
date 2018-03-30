//
//  Goals+CoreDataProperties.swift
//  Qiaf
//
//  Created by Difeng Chen on 11/20/17.
//  Copyright © 2017 Difeng Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension Goals {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goals> {
        return NSFetchRequest<Goals>(entityName: "Goals")
    }

    @NSManaged public var finishedDate: NSDate?
    @NSManaged public var moneyPerPeriod: Int32
    @NSManaged public var period: Int16
    @NSManaged public var saving: Int32
    @NSManaged public var startDate: NSDate?
    @NSManaged public var task: Int32
    @NSManaged public var title: String?
    @NSManaged public var totalAmount: Int32
    @NSManaged public var category: String?
    @NSManaged public var savingHistory: NSSet?

}

// MARK: Generated accessors for savingHistory
extension Goals {

    @objc(addSavingHistoryObject:)
    @NSManaged public func addToSavingHistory(_ value: SavingHistory)

    @objc(removeSavingHistoryObject:)
    @NSManaged public func removeFromSavingHistory(_ value: SavingHistory)

    @objc(addSavingHistory:)
    @NSManaged public func addToSavingHistory(_ values: NSSet)

    @objc(removeSavingHistory:)
    @NSManaged public func removeFromSavingHistory(_ values: NSSet)

}
