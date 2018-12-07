//
//  Root+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData


extension Root {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Root> {
        return NSFetchRequest<Root>(entityName: "Root")
    }
    
    //Properties
    @NSManaged public var stat: String?
    @NSManaged public var album: Album?

    enum CodingKeys: String, CodingKey {
        case album = "photos"
        case stat
    }
}
