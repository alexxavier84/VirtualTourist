//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Apple on 16/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(coordinate)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

