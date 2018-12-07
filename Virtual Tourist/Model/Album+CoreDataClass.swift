//
//  Album+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.managedObjectContext, let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedObjectContext) else {
            fatalError()
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decode(Int16.self, forKey: .page)
        perpage = try values.decode(Int16.self, forKey: .perpage)
        pages = try values.decode(Int32.self, forKey: .pages)
        total = try values.decode(String.self, forKey: .total)
        photo = try values.decode(Set<Photo>.self, forKey: .photo)
    }
}
