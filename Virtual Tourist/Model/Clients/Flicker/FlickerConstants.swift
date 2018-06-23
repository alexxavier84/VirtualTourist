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
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        
        // MARK: Const
        static let Json = "json"
        
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Photo search
        static let PhotoSearch = "flickr.photos.search"
        static let PhotoInfo = "flickr.photos.getInfo"
        static let PhotoGetSizes = "flickr.photos.getSizes"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        //static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let PhotoId = "photo_id"
        static let Method = "method"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Format = "format"
        static let Nojsoncallback = "nojsoncallback"
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
        static let Description = "description"
        static let Page = "page"
        static let Pages = "pages"
        static let Perpage = "perpage"
        static let Total = "total"
        static let Urls = "urls"
        static let Url = "url"
        static let Sizes = "sizes"
        static let Size = "size"
        static let Source = "source"
        static let Label = "label"
        static let Content = "_content"
        
    }
    
    struct JSONResponseValues {
        static let Large = "Large Square"
    }
}
