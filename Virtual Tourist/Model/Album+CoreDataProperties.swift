//
//  Album+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    //Properties
    @NSManaged public var page: Int16
    @NSManaged public var pages: Int32
    @NSManaged public var perpage: Int16
    @NSManaged public var total: String?
    @NSManaged public var root: Root?
    @NSManaged public var photo: Set<Photo>?
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case photo
    }

}

// MARK: Generated accessors for photo
extension Album {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}
