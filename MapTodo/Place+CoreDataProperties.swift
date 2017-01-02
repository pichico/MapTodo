//
//  Place+CoreDataProperties.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/11/05.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import Foundation
import CoreData


extension Place {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Place>(entityName: "Place") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var uuid: String?
    @NSManaged public var radius: NSNumber?
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
