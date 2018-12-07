//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by macos on 16/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CollectionViewController: UICollectionViewController {
    
    //Outlets
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    //Properties
    var sharedViewContext = AppDelegate.sharedViewContext
    var fetchedResultsController: NSFetchedResultsController<Photo>?
    let pendingOperations = PendingOperations()
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 50.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 3
    let client = Client()
    var pin: Pin?
    var photosToDelete : [Photo]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        deleteButton.isEnabled = false
        newCollectionButton.isEnabled = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
       }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        if pin?.isNew == false {
            setupFetchRequestForController()
        } else {
            downloadPhotoForSelectedPin()
            pin?.isNew = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: FetchRequest Methods
    
    func setupFetchRequestForController(){
        
        let predicate = NSPredicate(format: "pin = %@", pin!)
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        performFetchRequestForController(fetchRequest: fetchRequest)
    }
    
    func performFetchRequestForController(fetchRequest : NSFetchRequest<Photo>){
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedViewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController!.delegate = self
        
        do {
            try fetchedResultsController!.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Construct Photo URLS
        DispatchQueue.global(qos: .background).async {
            for object in (self.fetchedResultsController?.fetchedObjects)! {
                object.url = "https://farm\(object.farm).staticflickr.com/\(object.server ?? "")/\(object.id ?? "")_\(object.secret ?? "").jpg"
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: CollectionView Delegate Methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        cell.activityIndicator.hidesWhenStopped = true
        let photoForIndex = fetchedResultsController?.object(at: indexPath)
        
        if photoForIndex?.downloaded == false {
            cell.activityIndicator.startAnimating()
            startImageDownload(for: photoForIndex!, at: indexPath)
            cell.imageView.image = nil
            
        } else {
            
            cell.imageView.image = UIImage(data: (photoForIndex?.image)!)
            cell.activityIndicator.stopAnimating()
            cell.backgroundColor = UIColor.clear
        }
        
        if pendingOperations.downloadQueue.operations.count == 0 {
           newCollectionButton.isEnabled = true
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind:
        String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionReusableView
            header.imageView.image = UIImage(data: (self.pin?.snapshot)!)
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deleteButton.isEnabled = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if (collectionView.indexPathsForSelectedItems?.isEmpty)! {
            deleteButton.isEnabled = false
        }
    }
    
    //MARK: IBAction Methods
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        let indexPaths = collectionView.indexPathsForSelectedItems!
        var photosToDelete = [Photo]()
        for index in indexPaths {
            photosToDelete.append((fetchedResultsController?.object(at: index))!)
        }
        for photo in photosToDelete{
            self.sharedViewContext.delete(photo)
            try? self.sharedViewContext.save()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: UIBarButtonItem) {
        
        for object in (fetchedResultsController?.fetchedObjects)! {
            sharedViewContext.delete(object)
        }
        self.fetchedResultsController = nil
        try? sharedViewContext.save()
        self.downloadPhotoForSelectedPin()
    }
}

//MARK: - CollectionViewFlowLayout Delegate

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height/6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - FetchedResultsController Delegate

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
}

// MARK: - Download Methods

extension CollectionViewController {
    
    func downloadPhotoForSelectedPin() {
        
        client.getPhotosFromFlickr(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!) { (data, response, error) in
            guard (error == nil) else {
                print(error!)
                return
            }
            if let statusCode = response, statusCode <= 200 || statusCode >= 299  {
                print(statusCode)
                
            } else {
                
                if let results = data as! Root? {
                    let photos = results.album?.photo
                    for photo in photos! {
                        self.pin?.addToPhoto(photo)
                    }
                    try? self.sharedViewContext.save()
                    self.setupFetchRequestForController()
                }
            }
        }
    }
    
    func startImageDownload(for photoRecord: Photo, at indexPath: IndexPath) {
        
        guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.collectionView.reloadItems(at: [indexPath])
                try? self.sharedViewContext.save()
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
}

