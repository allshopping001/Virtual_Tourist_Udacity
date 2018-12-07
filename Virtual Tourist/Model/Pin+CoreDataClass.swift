//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.managedObjectContext, let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedObjectContext) else {
            fatalError()
        }
        self.init(entity: entity, insertInto: managedObjectContext)
    }
}
