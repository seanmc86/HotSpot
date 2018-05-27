//
//  ExploreViewController.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/24.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ExploreViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapLabel: UILabel!
    
    var places: [FlickrPlace] = []
    
    let locationManager = CLLocationManager()
    var currLat: Double = 0.0
    var currLon: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapLabel.text = "Grabbing Flickr Data..."
        enableBasicLocationServices()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            startReceivingLocationChanges()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableBasicLocationServices()
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
            //self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        currLat = locValue.latitude
        currLon = locValue.longitude
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //Zoom to user location
        let myLocation = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        let viewRegion = MKCoordinateRegionMakeWithDistance(myLocation, 3000, 3000)
        mapView.setRegion(viewRegion, animated: false)
        
        fetchPhotosByPlace(searchLat: Decimal(currLat), searchLon: Decimal(currLon))
    }
    
    private func addPlaceToMap(lat: Double, lon: Double) {
        let annotation = MKPointAnnotation()
        print("Adding coordinate \(lat) and \(lon) vs curr pos of \(currLat) and \(currLon)")
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let nameSplit = self.places[0].name.split(separator: ",")
        annotation.title = String(nameSplit[0])
        annotation.subtitle = "Flickr Group"
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        moveToPhotoScreen()
    }
    
    func moveToPhotoScreen() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "NearbyStory") as! NearbyViewController
        myVC.flickrPlace = self.places[0].placeId
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if (annotation.subtitle! == "Flickr Group") {
            
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = true
            }else{
                annotationView?.annotation = annotation
            }
            
            // Right accessory view
            let image = UIImage(named: "camera")
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(image, for: UIControlState())
            annotationView?.rightCalloutAccessoryView = button
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func fetchPhotosByPlace(searchLat: Decimal, searchLon: Decimal) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FlickrProvider.fetchPhotosByPlace(searchLat: searchLat, searchLon: searchLon, onCompletion: { (error: NSError?, flickrPlaces: [FlickrPlace]?) -> Void in
            
            DispatchQueue.main.async {
                
                _ = UIApplication.shared.isNetworkActivityIndicatorVisible = false
  
                if error == nil {
                    print("Reloading table 1")
                    
                    let placeId = flickrPlaces![0].placeId
                    if (placeId == "") {
                        print("Failed to format or find placeId")
                        return
                    } else {
                        print("Found placeId: \(placeId)")
                        let annotationLat = flickrPlaces![0].latitude
                        let annotationLon = flickrPlaces![0].longitude
 
                        self.places = flickrPlaces!
                        
                        self.addPlaceToMap(lat: annotationLat, lon: annotationLon)
                    }
                    
                    let nameOfPlace = flickrPlaces![0].name
                    if (nameOfPlace == "") {
                        print("Failed to format or find name of place")
                        return
                    } else {
                        let nameSplit = nameOfPlace.split(separator: ",")
                        self.mapLabel.text = "Your nearest Flickr location is \(String(nameSplit[0]))"
                    }
                    
                } else {
                    NearbyViewController().photos = []
                    if (error!.code == FlickrProvider.Errors.invalidAccessErrorCode) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            NearbyViewController().showErrorAlert()
                        })
                    }
                }
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                
            })
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
