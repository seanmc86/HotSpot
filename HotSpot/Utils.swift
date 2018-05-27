//
//  Utils.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/24.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import Foundation
import UIKit

/// The total animation duration of the splash animation
let kAnimationDuration: TimeInterval = 3.0

/// The length of the second part of the duration
let kAnimationDurationDelay: TimeInterval = 0.5

/// The offset between the AnimatedULogoView and the background Grid
let kAnimationTimeOffset: CFTimeInterval = 0.35 * kAnimationDuration

/// The ripple magnitude. Increase by small amounts for amusement ( <= .2) :]
let kRippleMagnitudeMultiplier: Float = 0.025

struct FlickrPhoto {
    
    let photoId: String
    let farm: Int
    let secret: String
    let server: String
    let title: String
    
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg")!
    }
    
}

struct FlickrPlace {
    
    let placeId: String
    let name: String
    let latitude: Double
    let longitude: Double
    
    var placeResult: String {
        return placeId
    }
    
}

struct FlickrInfo {
    
    let title: String
    let description: String
    let taken: String
    
}


public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
