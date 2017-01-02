//
//  Todo+CoreDataProperties.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/15.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import Foundation
import CoreData

extension Todo {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Todo>(entityName: "Todo") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var item: String?
    @NSManaged public var place: Place?

}
