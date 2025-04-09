//
//  PlaneuroTaskEntity+CoreDataProperties.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 01.04.2025.
//

import Foundation
import CoreData

extension PlaneuroTaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaneuroTaskEntity> {
        return NSFetchRequest<PlaneuroTaskEntity>(entityName: "PlaneuroTaskEntity")
    }

    @NSManaged public var title: String
    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var address: String?
    @NSManaged public var timeTravel: Int16
    @NSManaged public var categoryColor: String?
    @NSManaged public var categoryTitle: String?
    @NSManaged public var status: Int16
    @NSManaged public var type: Int16
    @NSManaged public var eventIdentifier: String?
    @NSManaged public var reminderOffset1: Double
    @NSManaged public var reminderOffset2: Double
    @NSManaged public var reminderNotificationID1: String?
    @NSManaged public var reminderNotificationID2: String?
}

extension PlaneuroTaskEntity : Identifiable {

}

extension PlaneuroTaskEntity {
    var task: Tasks {
        let offsets: [TimeInterval] = {
            var a: [TimeInterval] = []
            if reminderOffset1 > 0 { a.append(reminderOffset1) }
            if reminderOffset2 > 0 { a.append(reminderOffset2) }
            return a
        }()
        let ids: [String] = {
            var a: [String] = []
            if let id1 = reminderNotificationID1 { a.append(id1) }
            if let id2 = reminderNotificationID2 { a.append(id2) }
            return a
        }()
        return Tasks(
            title: title,
            startDate: startDate ?? .init(),
            endDate: endDate     ?? .init(),
            address: address     ?? "",
            timeTravel: Int(timeTravel),
            categoryColorName: categoryColor ?? "",
            categoryTitle: categoryTitle ?? "",
            status: TaskStatus(rawValue: status) ?? .active,
            type: TaskType(rawValue: type) ?? .userDefined,
            eventIdentifier: eventIdentifier,
            reminderOffsets: offsets,
            reminderNotificationIDs: ids
        )
    }
}
