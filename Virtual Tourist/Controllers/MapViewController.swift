//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by macos on 15/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Outlets
    @IBOutlet weak var erasePinButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    //Properties
    var sharedViewContext = AppDelegate.sharedViewContext
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    let initialLocation = CLLocationCoordinate2D(latitude: 39.865706, longitude: 116.401283)
    var selectedPin: Pin?
    var editButtonOn: Bool = false
    var mapSnapshotter = MKMapSnapshotter()

    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
        erasePinButton.isHidden = true
        mapView.delegate = self
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setupFetchRequestForController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func gestureRecognizerPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended && editButtonOn == false {
            let locationInView = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            newAnnotation(coordinate: locationCoordinate)
        }
    }
    
    @objc func editButtonPressed() {
        
        if editButtonOn == true {
            self.navigationItem.rightBarButtonItem?.style = .plain
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
            erasePinButton.isHidden = true
            editButtonOn.toggle()
            
        } else {
            
            self.navigationItem.rightBarButtonItem?.style = .done
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editButtonPressed))
            erasePinButton.isHidden = false
            editButtonOn.toggle()
        }
    }
    
    //MARK: - MapView Delegate Methods
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
        let currentCoordinate = [mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude]
        let currentZoom = [mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta]
        UserDefaults.standard.set(currentCoordinate[0], forKey: "coordinateLatidute")
        UserDefaults.standard.set(currentCoordinate[1], forKey: "coordinateLongitude")
        UserDefaults.standard.set(currentZoom[0], forKey: "zoomLatitude")
        UserDefaults.standard.set(currentZoom[1], forKey: "zoomLongitude")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let predicate = NSPredicate(format: "latitude = %@", String(Double((view.annotation?.coordinate.latitude)!)))
        let predicate2 = NSPredicate(format: "longitude = %@", String(Double((view.annotation?.coordinate.longitude)!)))
        let fetchRequest = setupFetchRequestForSelectedPin(predicate, predicate2)
        performFetchRequestForSelectedPin(fetchRequest)
        if editButtonOn {
            sharedViewContext.delete(selectedPin!)
            try? sharedViewContext.save()
            
        } else {

            performSegue(withIdentifier: "segueToCollectionView", sender: self)
            mapView.deselectAnnotation(view as? MKAnnotation, animated: true)
        }
    }

    //MARK: - Persistance Methods
    
    func newAnnotation(coordinate: CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        setupMapSnapshotter(coordinate: coordinate)
        persistAnnotation(annotation)
    }

    fileprivate func persistAnnotation(_ annotation: MKPointAnnotation) {
        
        let pin = Pin(context: sharedViewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        mapSnapshotter.start { (snapshot, error) in
            pin.snapshot = snapshot?.image.pngData()
            try? self.sharedViewContext.save()
        }
    }
    
    func deleteAnnotation() {
        
        sharedViewContext.delete(selectedPin!)
        try? sharedViewContext.save()
    }
    
    //MARK: - FetchRequest Methods
    
    fileprivate func setupFetchRequestForSelectedPin(_ predicate: NSPredicate, _ predicate2: NSPredicate) -> NSFetchRequest<Pin> {
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = compoundPredicate
        return fetchRequest
    }
    
    fileprivate func performFetchRequestForSelectedPin(_ pinFetchRequest: NSFetchRequest<Pin>)  {
        
        do {
            let fetchedPin = try sharedViewContext.fetch(pinFetchRequest)
            selectedPin = fetchedPin.first
        } catch {
            fatalError()
        }
    }
    
    fileprivate func setupFetchRequestForController(){
        
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        performFetchRequestForController(fetchRequest)
        loadMap()
    }
    
    fileprivate func performFetchRequestForController(_ fetchRequest: NSFetchRequest<Pin>){
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedViewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    fileprivate func loadMap() {
        
        let fetchedObjects = fetchedResultsController.fetchedObjects!
        for object in fetchedObjects {
            DispatchQueue.main.async {
                self.mapView.addAnnotation(object)
            }
        }
    }
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationController = segue.destination as! UINavigationController
        let collectionViewController = navigationController.topViewController as! CollectionViewController
        collectionViewController.pin = selectedPin
    }
}

//MARK: - FetchedResultsController Delegate

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let annotation = anObject as? Pin else {
            fatalError("error FetchController")
        }
        switch type {
        case .insert:
            mapView.addAnnotation(annotation)
        case .delete :
            mapView.removeAnnotation(annotation)
        case .move:
            fatalError("can't move an annotation")
        case .update:
            mapView.removeAnnotation(annotation)
            mapView.addAnnotation(annotation)
       
        }
    }
}

// MARK: - Mapview Setup

extension MapViewController {

    func setupMap(){
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            
            let regionCoordinate = CLLocationCoordinate2D.init(latitude: UserDefaults.standard.value(forKey: "coordinateLatidute") as! Double, longitude: UserDefaults.standard.value(forKey: "coordinateLongitude") as! Double)
            let regionZoom = MKCoordinateSpan.init(latitudeDelta: UserDefaults.standard.value(forKey: "zoomLatitude") as! Double, longitudeDelta: UserDefaults.standard.value(forKey: "zoomLongitude") as! Double)
            let region = MKCoordinateRegion.init(center: regionCoordinate, span: regionZoom)
            mapView.region = region
            
        } else {
            
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            let region = MKCoordinateRegion.init(center: initialLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.region = region
        }
    }
    
    //Mapview Snapshot Setup
    
    func setupMapSnapshotter(coordinate:CLLocationCoordinate2D) {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapSnapshotOptions.region = region
        mapSnapshotOptions.size = CGSize(width: self.mapView.frame.width, height: self.mapView.frame.height/6)
        mapSnapshotOptions.showsPointsOfInterest = true
        mapSnapshotOptions.mapType = .mutedStandard
        mapSnapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
    }
}

