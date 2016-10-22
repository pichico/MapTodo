//
//  Place+CoreDataProperties.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/16.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import Foundation
import CoreData

extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place");
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var todo: NSSet?

}

// MARK: Generated accessors for todo
extension Place {

    @objc(addTodoObject:)
    @NSManaged public func addToTodo(_ value: Todo)

    @objc(removeTodoObject:)
    @NSManaged public func removeFromTodo(_ value: Todo)

    @objc(addTodo:)
    @NSManaged public func addToTodo(_ values: NSSet)

    @objc(removeTodo:)
    @NSManaged public func removeFromTodo(_ values: NSSet)

}
