//
//  FlickrSetup.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/25.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import Foundation

class FlickrProvider {
    
    typealias FlickrResponse = (NSError?, [FlickrPhoto]?) -> Void
    typealias FlickrResponse2 = (NSError?, [FlickrPlace]?) -> Void
    typealias FlickrResponse3 = (NSError?, [FlickrInfo]?) -> Void
    
    struct Keys {
        static let flickrKey = "1fbc41bb8fc230e03161d4b793ab13a7"
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func fetchPhotosByLocation(searchType: Int, searchLat: Decimal, searchLon: Decimal, placeId: String, onCompletion: @escaping FlickrResponse) -> Void {
        
        var urlString: String = ""
        if (searchType == 1) {
            urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Keys.flickrKey)&place_id=\(placeId)&per_page=50&format=json&nojsoncallback=1"
        } else {
            urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Keys.flickrKey)&lat=\(searchLat)&lon=\(searchLon)&per_page=50&format=json&nojsoncallback=1"
        }
        
        let url: NSURL = NSURL(string: urlString)!

        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(String(describing: error))")
                onCompletion(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
                guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
                
                let flickrPhotos: [FlickrPhoto] = photosArray.map { photoDictionary in
                    
                    let photoId = photoDictionary["id"] as? String ?? ""
                    let farm = photoDictionary["farm"] as? Int ?? 0
                    let secret = photoDictionary["secret"] as? String ?? ""
                    let server = photoDictionary["server"] as? String ?? ""
                    let title = photoDictionary["title"] as? String ?? ""
                    
                    let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                    return flickrPhoto
                }
                
                onCompletion(nil, flickrPhotos)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
            
        })
        searchTask.resume()
    }
    
    class func fetchPhotosByPlace(searchLat: Decimal, searchLon: Decimal, onCompletion: @escaping FlickrResponse2) -> Void {
        
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=\(Keys.flickrKey)&lat=\(searchLat)&lon=\(searchLon)&accuracy=12&format=json&nojsoncallback=1"

        let url: NSURL = NSURL(string: urlString)!

        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching place: \(String(describing: error))")
                onCompletion(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let placesContainer = resultsDictionary!["places"] as? NSDictionary else { return }
                guard let placesArray = placesContainer["place"] as? [NSDictionary] else { return }
                
                let flickrPlaces: [FlickrPlace] = placesArray.map { placesDictionary in
                    
                    let placeId = placesDictionary["place_id"] as? String ?? ""
                    let name = placesDictionary["name"] as? String ?? ""
                    let latitude = placesDictionary["latitude"] as? String ?? ""
                    let longitude = placesDictionary["longitude"] as? String ?? ""
                    
                    let flickrPlace = FlickrPlace(placeId: placeId, name: name, latitude: Double(latitude)!, longitude: Double(longitude)!)
                    return flickrPlace
                }
                
                onCompletion(nil, flickrPlaces)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
            
        })
        searchTask.resume()
    }
    
    class func fetchPhotosInfo(photoId: Int, onCompletion: @escaping FlickrResponse3) -> Void {
        
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(Keys.flickrKey)&photo_id=\(photoId)&format=json&nojsoncallback=1"
        
        let url: NSURL = NSURL(string: urlString)!

        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photo info: \(String(describing: error))")
                onCompletion(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }

                guard let photoObject = resultsDictionary!["photo"]
                    else { return }

                guard let titleKey = photoObject["title"] as? [String: String],
                    let title = titleKey["_content"]
                    else { return }
                guard let descriptionKey = photoObject["description"] as? [String: String],
                    let description = descriptionKey["_content"]
                    else { return }
                guard let dateKey = photoObject["dates"] as? [String: String],
                    let taken = dateKey["taken"]
                    else { return }
                
                let flickrInfos: [FlickrInfo] = [FlickrInfo(title: title, description: description, taken: taken)]
            
                onCompletion(nil, flickrInfos)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
            
        })
        searchTask.resume()
    }
    
}

extension String {
    
    func split(regex pattern: String) -> [String] {
        
        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }
        
        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }
}

