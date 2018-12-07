//
//  PhotoOperations.swift
//  Virtual Tourist
//
//  Created by macos on 25/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
}

class ImageDownloader: Operation {
    let photoRecord: Photo
    
    init(_ photoRecord: Photo) {
        self.photoRecord = photoRecord
    }
    
    override func main(){
        if isCancelled {
            return
        }
        
        guard let imageData = try? Data(contentsOf: URL(string: photoRecord.url!)!) else {
            return
        }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            photoRecord.image = imageData
            photoRecord.downloaded = true
        } else {
            photoRecord.downloaded = false
            photoRecord.image = nil
        }
    }
}
