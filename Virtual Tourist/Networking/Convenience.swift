//
//  Convenience.swift
//  Virtual Tourist
//
//  Created by macos on 16/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import Foundation
extension Client {
    
    func getPhotosFromFlickr(latitude: Double, longitude: Double, _ completionHandler: @escaping (_ results: Any?, _ statusCode: Int?, _ Error: Error?) -> Void){
        
        let queryItems : [String:AnyObject] = [
            "method": Constants.ApiQueryMethod as AnyObject,
            "api_key": Constants.ApiKey as AnyObject,
            "content_type": 1 as AnyObject,
            "format": "json" as AnyObject,
            "nojsoncallback": 1 as AnyObject,
            "lat": latitude as AnyObject,
            "lon": longitude as AnyObject,
            "radius": 5 as AnyObject,
            "per_page" : 20 as AnyObject,
            "page": 1 as AnyObject
            ]
        
        let _ = taskForGetMethod(queryItems) { (data, response, error) in
            guard (error == nil) else {
                completionHandler(nil, nil, error)
                return
            }
            if let statusCode = response, statusCode <= 200 || statusCode >= 299  {
                completionHandler(nil, statusCode, nil)
            } else {
                if let results = data as! Root? {
                    completionHandler(results, nil, nil)
                }
            }
        }
    }
}
