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

class PhotoAlbumViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionTouch: UIButton!
    
    
    var coordinate: CLLocationCoordinate2D?
    var photosCount: Int = 0
    var photoUrlArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.addObserver(self, forKeyPath: "photoLoaded", options: .old, context: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.mapType = .standard
        mapView.showsScale = true
        mapView.showsCompass = true

        newCollectionTouch.isEnabled = false
        
        FlickerClient.sharedInstance().getPhotosInfoFromSearch(longitude: (coordinate?.longitude)!, latitude: (coordinate?.latitude)!) { (photoIds, error) in
            
            //Loop through each photos and get the photo url
            if let photoIds = photoIds{
                
                var maxPicCount = 0
                if photoIds.count > 20 {
                    maxPicCount = 20
                }else {
                    maxPicCount = photoIds.count % 20
                }
                
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
            }
            
            // For each url download the photo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addAnnotation()
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

    @IBAction func onCancelTouch(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func newCollectionLoad(_ sender: Any) {
        newCollectionTouch.isEnabled = false
        self.photoUrlArray.removeAll()
        
        FlickerClient.sharedInstance().getPhotosInfoFromSearch(longitude: (coordinate?.longitude)!, latitude: (coordinate?.latitude)!) { (photoIds, error) in
            
            //Loop through each photos and get the photo url
            if let photoIds = photoIds{
                
                var maxPicCount = 0
                if photoIds.count > 20 {
                    maxPicCount = 20
                }else {
                    maxPicCount = photoIds.count % 20
                }
                
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
            }
            
            // For each url download the photo
        }
    }
    
    
}

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoUrlArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrImageReuseIdentifier", for: indexPath) as! PhotoAlbumViewCell
        
        if self.photoUrlArray.count > 0 {
            let photoUrl = self.photoUrlArray[indexPath.item]
            FlickerClient.sharedInstance().downloadImagesFromUrl(photoUrl: photoUrl, completionHandlerForDownloadImage: { (photoData, error) in
                
                performUIUpdatesOnMain {
                    if let photoData = photoData {
                        cell.photoAlbumCellImage.image = UIImage(data: photoData)
                    }
                }
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
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

