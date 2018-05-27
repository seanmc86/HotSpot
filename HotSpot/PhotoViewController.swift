//
//  PhotoViewController.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/25.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var photoDescription: UILabel!
    @IBOutlet weak var photoDate: UILabel!
    
    var flickrPhoto: FlickrPhoto?
    var photoInfo: [FlickrInfo] = []
    var flickrInfo: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if flickrPhoto != nil {
            photoImageView.sd_setImage(with: flickrPhoto!.photoUrl as URL?)
            photoLabel.text = flickrPhoto!.title
            
            fullScreenImage()
            
        } else {
            photoLabel.text = "Error loading photo :("
        }
        
        let photoId = flickrPhoto!.photoId
        self.fetchPhotosInfo(photoId: Int(photoId)!)
        
    }
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
        //self.performSegue(withIdentifier: "NearbyViewBack", sender: Any?.self)
    }
    
    @IBAction func tappedPhoto(_ sender: Any) {
        fullScreenImage()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func fullScreenImage() {
        let newImageView = UIImageView(image: photoImageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func fetchPhotosInfo(photoId: Int) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FlickrProvider.fetchPhotosInfo(photoId: photoId, onCompletion: { (error: NSError?, flickrInfo: [FlickrInfo]?) -> Void in
            
            DispatchQueue.main.async {
                
                _ = UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print(flickrInfo!)
                if error == nil {
                    print("Reloading photo info")
                    self.photoInfo = flickrInfo!
                    
                    self.photoLabel.text = self.photoInfo[0].title
                    self.photoDescription.text = "Description: \(self.photoInfo[0].description)"
                    self.photoDate.text = "Taken: \(self.photoInfo[0].taken)"
                    
                } else {
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
