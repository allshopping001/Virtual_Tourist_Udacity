//
//  Client.swift
//  Virtual Tourist
//
//  Created by macos on 16/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import Foundation
import CoreData

class Client: NSObject {
    
    let sharedViewContext = AppDelegate.sharedViewContext
    let session = URLSession.shared
    
    func taskForGetMethod(_ queryItems: [String:AnyObject], completionHandler: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?) -> Void ) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: createURLFromMethod(queryItems))
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            //Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandler(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                return
            }
            self.parseJSON("taskForGetMethod", data, completionHandlerForData: completionHandler)
        }
        task.resume()
        return task
    }
    
    // MARK: - Convert Data Method
    private func parseJSON(_ method:String, _ data: Data, completionHandlerForData: (_ result: Any?, _ statusCode: Int?, _ error: Error?)-> Void){
        
        let decoder = JSONDecoder()
        //let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        var result: Any?
        
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve context")
            }
            // Parse JSON data
            let managedObjectContext = sharedViewContext
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            result = try decoder.decode(Root.self, from: data)
            completionHandlerForData(result, nil, nil)
        } catch let error {
            print(error)
        }
    }
        
    
    private func createURLFromMethod(_ queryItems: [String:AnyObject]?) -> URL {
        
        var components = URLComponents()
        components.scheme = Client.Constants.ApiScheme
        components.host = Client.Constants.ApiHost
        components.path = Client.Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        //Check if parameters exist
        if let queryItems = queryItems {
            for (key, value) in queryItems {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
}

