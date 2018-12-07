//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

extension Pin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }
    
    //Properties
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: Set<Photo>?
    @NSManaged public var isNew: Bool
    @NSManaged public var snapshot: Data?
}

// MARK: Generated accessors for photo
extension Pin {
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
    
}

extension Pin : MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}

