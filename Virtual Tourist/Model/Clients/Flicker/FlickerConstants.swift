//
//  FlickerConstants.swift
//  Virtual Tourist
//
//  Created by Apple on 17/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

extension FlickerClient{
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "e1b220326a97cdaf35a23f8ecb5ad623"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flicker.com"
        static let ApiPath = "/services/rest/"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Photo search
        static let PhotoSearch = "flicker.photos.search"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        //static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Format = "format"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Photos
        static let Photos = "photos"
        static let Photo = "photo"
        static let Id = "id"
        static let Owner = "owner"
        static let Secret = "secret"
        static let Title = "title"
        static let Page = "page"
        static let Pages = "pages"
        static let Perpage = "perpage"
        static let Total = "total"
        
    }
}
