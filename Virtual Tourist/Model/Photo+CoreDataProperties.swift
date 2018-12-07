//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    //Properties
    @NSManaged public var farm: Int16
    @NSManaged public var id: String?
    @NSManaged public var isfamily: Int16
    @NSManaged public var isfriend: Int16
    @NSManaged public var ispublic: Int16
    @NSManaged public var owner: String?
    @NSManaged public var secret: String?
    @NSManaged public var server: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?
    @NSManaged public var album: Album?
    @NSManaged public var image: Data?
    @NSManaged public var downloaded: Bool
    @NSManaged public var url: String?




    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
    }

}
