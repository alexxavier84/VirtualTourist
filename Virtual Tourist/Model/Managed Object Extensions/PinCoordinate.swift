//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by Apple on 19/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import MapKit

@objc class PinCoordinate : NSObject, MKAnnotation{
    
    let pin: Pin?
    let coordinate: CLLocationCoordinate2D
    
    init(_ pin: Pin) {
        self.pin = pin
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.pin = nil
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
