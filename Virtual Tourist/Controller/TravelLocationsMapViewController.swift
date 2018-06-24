//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Apple on 17/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var pinCoordinate: PinCoordinate?
    
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Configure Map
        self.requestLocationAccess()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
        
        
        
        //Configure and get data from CoreData
        setupFetchedResultsController()
        
        SharedData.pinCoordinatesFromFetchedData(fetchedResultsController.fetchedObjects)
        
        //Configure long press in the map
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.handleTap(gestureReconizer:)))
        longpressGestureRecognizer.minimumPressDuration = .init(0.5)
        longpressGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(longpressGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadAnnotations()
        if fetchedResultsController == nil {
            setupFetchedResultsController()
            SharedData.pinCoordinatesFromFetchedData(fetchedResultsController.fetchedObjects)
        } 
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.fetchedResultsController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        SharedData.pinCoordinatesFromFetchedData(fetchedResultsController.fetchedObjects)
        
        if segue.identifier == "PhotoAlbumViewSegue"{
            if let photoAlbumViewController = segue.destination as? PhotoAlbumViewController{
                photoAlbumViewController.pin = SharedData.getPinFromCoordinate((self.coordinate?.longitude)!, (self.coordinate?.latitude)!)
                photoAlbumViewController.coordinate = self.coordinate ?? nil
                photoAlbumViewController.dataController = self.dataController
            }
        }
    }
    
}

extension TravelLocationsMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        } else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") as? MKPinAnnotationView ?? MKPinAnnotationView()
            annotationView.pinTintColor = UIColor.red
            
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        self.coordinate = view.annotation?.coordinate
        performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: nil)
    }
    
}

extension TravelLocationsMapViewController : UIGestureRecognizerDelegate{
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        if !(gestureReconizer.state == .began){
            return
        }else {
            let location = gestureReconizer.location(in: mapView)
            let annotationCoordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(context: self.dataController.viewContext)
            pin.latitude = annotationCoordinate.latitude as Double
            pin.longitude = annotationCoordinate.longitude as Double
            pin.photos = nil
            
            if self.dataController.viewContext.hasChanges{
                try? self.dataController.viewContext.save()
            }
            
            setupFetchedResultsController()
            
            performUIUpdatesOnMain {
                // Add annotation:
                let annotation = MKPointAnnotation()
                annotation.coordinate = annotationCoordinate
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension TravelLocationsMapViewController : NSFetchedResultsControllerDelegate{
    
}



extension TravelLocationsMapViewController{
    
    func requestLocationAccess() {
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            print("Location access denied")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func loadAnnotations() {
        self.mapView.delegate = self
        self.mapView.addAnnotations(SharedData.shared.pinCoordinates as [MKAnnotation])
    }
    
    
}

