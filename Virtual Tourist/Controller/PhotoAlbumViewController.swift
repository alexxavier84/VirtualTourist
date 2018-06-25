//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Apple on 16/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionTouch: UIButton!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var pin: Pin?
    var coordinate: CLLocationCoordinate2D?
    var photoUrlArray = [String]()
    
    fileprivate func setupFetchedResultsController(){
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        
        if let pin = pin {
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "photoUrl", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.addObserver(self, forKeyPath: "photoLoaded", options: .old, context: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.mapType = .standard
        mapView.showsScale = true
        mapView.showsCompass = true
        
        if (fetchedResultsController == nil){
            setupFetchedResultsController()
        }
        
        newCollectionTouch.isEnabled = false
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects, (fetchedObjects.count) == 0 {
            FlickerClient.sharedInstance().getPhotosInfoFromSearch(longitude: (pin?.longitude) ?? 0, latitude: (pin?.latitude) ?? 0) { (photoIds, error) in
                
                func showErrorMessage(_ errorMessage: String) {
                    performUIUpdatesOnMain {
                        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                        }
                        
                        let alert = UIAlertController(title: "", message: errorMessage, preferredStyle: .alert)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                //Loop through each photos and get the photo url
                if let photoIds = photoIds{
                    
                    var maxPicCount = 0
                    if photoIds.count > 20 {
                        maxPicCount = 20
                    }else {
                        maxPicCount = photoIds.count % 20
                    }
                    
                    if !(maxPicCount == 0)
                    {
                        for i in 1...maxPicCount {
                            let index = arc4random_uniform(UInt32(photoIds.count))
                            FlickerClient.sharedInstance().getPhotoUrl(photoId: photoIds[Int(index)], completionHandlerForPhotoUrl: { (photoUrl, error) in
                                
                                if let photoUrl = photoUrl {
                                    self.photoUrlArray.append(photoUrl)
                                }
                                
                                if self.photoUrlArray.count == maxPicCount{
                                    performUIUpdatesOnMain {
                                        self.collectionView.reloadData()
                                        self.newCollectionTouch.isEnabled = true
                                    }
                                }
                            })
                        }
                    } else {
                        showErrorMessage("No photos to show for this location")
                    }
                }
                
                // For each url download the photo
            }
        }else{
            self.newCollectionTouch.isEnabled = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addAnnotation()
        if (fetchedResultsController == nil){
            setupFetchedResultsController()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == self.collectionView{
            self.newCollectionTouch.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.collectionView.removeObserver(self, forKeyPath: "photoLoaded")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.fetchedResultsController = nil
    }
    
    @IBAction func newCollectionLoad(_ sender: Any) {
        newCollectionTouch.isEnabled = false
        self.photoUrlArray.removeAll()
        print(self.photoUrlArray)
        
        let photosToDelete = self.fetchedResultsController.fetchedObjects
        
        if let photosToDelete = photosToDelete{
            for photoToDelete in photosToDelete{
                self.dataController.viewContext.delete(photoToDelete)
            }
            
        }
        
        sleep(5)
        if dataController.viewContext.hasChanges{
            try? self.dataController.viewContext.save()
        }
        
        print(self.fetchedResultsController.fetchedObjects)
        
        
        FlickerClient.sharedInstance().getPhotosInfoFromSearch(longitude: (coordinate?.longitude) ?? 0, latitude: (coordinate?.latitude) ?? 0) { (photoIds, error) in
            
            //Loop through each photos and get the photo url
            if let photoIds = photoIds{
                
                var maxPicCount = 0
                if photoIds.count > 20 {
                    maxPicCount = 20
                }else {
                    maxPicCount = photoIds.count % 20
                }
                
                for _ in 1...maxPicCount {
                    let index = arc4random_uniform(UInt32(photoIds.count))
                    FlickerClient.sharedInstance().getPhotoUrl(photoId: photoIds[Int(index)], completionHandlerForPhotoUrl: { (photoUrl, error) in
                        
                        if let photoUrl = photoUrl {
                            self.photoUrlArray.append(photoUrl)
                        }
                        
                        if self.photoUrlArray.count == maxPicCount{
                            performUIUpdatesOnMain {
                                self.collectionView.reloadData()
                                self.newCollectionTouch.isEnabled = true
                            }
                        }
                    })
                }
            }
            
            // For each url download the photo
        }
    }
    
    
}

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fetchedObject = fetchedResultsController.fetchedObjects, (fetchedObject.count) > 0 {
            return fetchedObject.count
        }else{
            return self.photoUrlArray.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrImageReuseIdentifier", for: indexPath) as! PhotoAlbumViewCell
        
        if self.photoUrlArray.count > 0 && self.photoUrlArray.count > indexPath.item {
            let photoUrl = self.photoUrlArray[indexPath.item]
            FlickerClient.sharedInstance().downloadImagesFromUrl(photoUrl: photoUrl, completionHandlerForDownloadImage: { (photoData, error) in
                
                if let photoData = photoData {
                    
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.photoUrl = photoUrl
                    photo.image = photoData
                    photo.pin = self.pin
                    try? self.dataController.viewContext.save()
                    
                    performUIUpdatesOnMain {
                        cell.photoAlbumCellImage.image = UIImage(data: photoData)
                    }
                }
            })
        }else{
            let photo = fetchedResultsController.object(at: indexPath)
            performUIUpdatesOnMain {
                if let imageData = photo.image{
                    cell.photoAlbumCellImage.image = UIImage(data: imageData)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        
        if dataController.viewContext.hasChanges{
            try? dataController.viewContext.save()
            setupFetchedResultsController()
        }
        
        
        self.collectionView.reloadData()
    }
    
    
}

extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate{
    
}

extension PhotoAlbumViewController {
    
    func addAnnotation() {
        //self.mapView.delegate = self
        
        let regionRadius: CLLocationDistance = 100000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.coordinate)!,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.addAnnotation(PinCoordinate(self.coordinate!) as MKAnnotation)
    }
}


class PhotoAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoAlbumCellImage: UIImageView!
    
}

