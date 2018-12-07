//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.managedObjectContext, let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext) else {
            fatalError()
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        owner = try values.decode(String.self, forKey: .owner)
        secret = try values.decode(String.self, forKey: .secret)
        server = try values.decode(String.self, forKey: .server)
        title = try values.decode(String.self, forKey: .title)
        farm = try values.decode(Int16.self, forKey: .farm)
        ispublic = try values.decode(Int16.self, forKey: .ispublic)
        isfriend = try values.decode(Int16.self, forKey: .isfriend)
        isfamily = try values.decode(Int16.self, forKey: .isfamily)
    }
}
