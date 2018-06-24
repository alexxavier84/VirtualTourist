//
//  FlickerConvenience.swift
//  Virtual Tourist
//
//  Created by Apple on 17/06/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    func getPhotosInfoFromSearch(longitude: Double, latitude: Double, completionHandlerForPhotosFromSearch: @escaping(_ photoIds: [String]?, _ error: NSError?) -> Void) {
        
        let parameter = [
            FlickerClient.ParameterKeys.Method: FlickerClient.Methods.PhotoSearch,
            FlickerClient.ParameterKeys.ApiKey: FlickerClient.Constants.ApiKey,
            FlickerClient.ParameterKeys.Latitude: "\(latitude)",
            FlickerClient.ParameterKeys.Longitude: "\(longitude)",
            FlickerClient.ParameterKeys.Format: FlickerClient.Constants.Json,
            FlickerClient.ParameterKeys.Nojsoncallback: "1"
        ]
        
        self.taskForGETMethod(parameters: parameter as [String : AnyObject]) { (result, error) in
            
            var photoIds = [String]()
            
            guard error == nil else{
                completionHandlerForPhotosFromSearch(nil, error)
                return
            }
            
            guard let photosInfo = result![FlickerClient.JSONResponseKeys.Photos] as? [String: AnyObject] else {
                completionHandlerForPhotosFromSearch(nil, NSError(domain: "getPhotosFromSearch", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Photos json"]))
                return
            }
            
            guard let photoInfoArray = photosInfo[FlickerClient.JSONResponseKeys.Photo] as? [[String: AnyObject]] else{
                completionHandlerForPhotosFromSearch(nil, NSError(domain: "getPhotosFromSearch", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Photo json"]))
                return
            }
            
            for photoInfo in photoInfoArray{
                guard let photoId = photoInfo[FlickerClient.JSONResponseKeys.Id] as? String else {
                    completionHandlerForPhotosFromSearch(nil, NSError(domain: "getPhotosFromSearch", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Photo id from json"]))
                    return
                }
                
                photoIds.append(photoId)
            }
            
            completionHandlerForPhotosFromSearch(photoIds, nil)
        }
    }
    
    func getPhotoUrl(photoId: String, completionHandlerForPhotoUrl: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        let parameter = [
            FlickerClient.ParameterKeys.Method: FlickerClient.Methods.PhotoGetSizes,
            FlickerClient.ParameterKeys.ApiKey: FlickerClient.Constants.ApiKey,
            FlickerClient.ParameterKeys.PhotoId: photoId,
            FlickerClient.ParameterKeys.Format: FlickerClient.Constants.Json,
            FlickerClient.ParameterKeys.Nojsoncallback: "1"
        ]
        
        self.taskForGETMethod(parameters: parameter as [String : AnyObject]) { (result, error) in
            
            guard error == nil else{
                completionHandlerForPhotoUrl(nil, error)
                return
            }
            
            guard let photoSizes = result![FlickerClient.JSONResponseKeys.Sizes] as? [String: AnyObject] else {
                completionHandlerForPhotoUrl(nil, NSError(domain: "getPhotoUrl", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Photo sizes json"]))
                return
            }
            
            guard let photoSizeArray = photoSizes[FlickerClient.JSONResponseKeys.Size] as? [[String: AnyObject]] else{
                completionHandlerForPhotoUrl(nil, NSError(domain: "getPhotoUrl", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Photo size json"]))
                return
            }
            
            for i in 0...photoSizeArray.count{
                if let sizeLabel = photoSizeArray[i][FlickerClient.JSONResponseKeys.Label] as? String, sizeLabel == FlickerClient.JSONResponseValues.Large{
                    if let photoUrl = photoSizeArray[i][FlickerClient.JSONResponseKeys.Source] as? String{
                        completionHandlerForPhotoUrl(photoUrl, nil)
                        break
                    }
                }
            }
        }
    }
    
    func downloadImagesFromUrl(photoUrl: String, completionHandlerForDownloadImage: @escaping(_ imageData: Data?, _ error: NSError?) -> Void){
        // if an image exists at the url, set the image and title
        
        FlickerClient.sharedInstance().taskForDownloadImage(imageUrlParam: photoUrl) { (imageData, error) in
            guard error == nil else {
                completionHandlerForDownloadImage(nil, NSError(domain: "downloadImagesFromUrl", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not download the image"]))
                return
            }
            
            completionHandlerForDownloadImage(imageData, nil)
        }
    }
    
    
}
