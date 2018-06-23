//
//  SharedData.swift
//  Virtual Tourist
//
//  Created by Apple on 20/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import MapKit

class SharedData: NSObject {
    
    static let shared = SharedData()
    var pinCoordinates = [PinCoordinate]()
    
    static func pinCoordinatesFromFetchedData(_ pins: [Pin]?){
        
        SharedData.shared.pinCoordinates.removeAll()
        
        if let pins = pins{
            for pin in pins {
                SharedData.shared.pinCoordinates.append(PinCoordinate(pin))
            }
        }
    }
    
    static func getPinFromCoordinate(_ longitude: CLLocationDegrees, _ latitude: CLLocationDegrees) -> Pin? {
        
        for pinCoordinate in SharedData.shared.pinCoordinates{
            if pinCoordinate.coordinate.longitude == longitude && pinCoordinate.coordinate.latitude == latitude{
                return pinCoordinate.pin!
            }
        }
        return nil
    }
    
}
