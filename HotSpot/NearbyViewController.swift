//
//  NearbyViewController.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/24.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import UIKit
import CoreLocation

enum LayoutType: Int
{
    case Grid = 0
    case List = 1
}

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    let locationManager = CLLocationManager()
    var currLat: Double = 0.0
    var currLon: Double = 0.0
    
    var photos: [FlickrPhoto] = []
    var photoInfo: [FlickrInfo] = []
    var flickrInfo: String = ""
    var flickrPlace: String = ""
    
    // MARK: - Actions
    
    override func viewWillAppear(_ animated: Bool) {
        
        let placeToGrab = flickrPlace
        
        if (placeToGrab == "") {
            locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
        } else {
            fetchPhotosByLocation(searchType: 1, searchLat: Decimal(currLat), searchLon: Decimal(currLon), placeId: placeToGrab)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations2 = \(locValue.latitude) \(locValue.longitude)")
        
        currLat = locValue.latitude
        currLon = locValue.longitude
        
        fetchPhotosByLocation(searchType: 2, searchLat: Decimal(currLat), searchLon: Decimal(currLon), placeId: "0")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        navItem.title = "HotSpots Near You"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func resetSearch(sender: AnyObject) {
        photos.removeAll(keepingCapacity: false);
        tableView.reloadData()
        self.title = "Flickr Search"
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCellIdentifier = "PhotoCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: photoCellIdentifier, for: indexPath as IndexPath) as? PhotoCell
        cell!.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //self.performSegue(withIdentifier: "PhotoSegue", sender: self)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    // MARK - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let photoViewController = segue.destination as! PhotoViewController
        let selectedIndexPath = tableView.indexPathForSelectedRow
        photoViewController.flickrPhoto = photos[selectedIndexPath!.row]
        
    }
    
    // MARK: - Private
    
    private func fetchPhotosByLocation(searchType: Int, searchLat: Decimal, searchLon: Decimal, placeId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FlickrProvider.fetchPhotosByLocation(searchType: searchType, searchLat: searchLat, searchLon: searchLon, placeId: placeId, onCompletion: { (error: NSError?, flickrPhotos: [FlickrPhoto]?) -> Void in
            
            DispatchQueue.main.async {
                
                _ = UIApplication.shared.isNetworkActivityIndicatorVisible = false

                if error == nil {
                    print("Reloading table 2")
                    self.photos = flickrPhotos!
                    
                    self.tableView.reloadData()
                } else {
                    self.photos = []
                    if (error!.code == FlickrProvider.Errors.invalidAccessErrorCode) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.showErrorAlert()
                        })
                    }
                }
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                
            })
        })
    }
    
    public func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
