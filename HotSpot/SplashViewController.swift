//
//  SplashViewController.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/24.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    fileprivate var rootViewController: UIViewController? = nil
    
    var alertView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createView()
        
        delay(1) {
            self.dismissAlert()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createView() {
        
        // Create a red view
        let alertWidth: CGFloat = view.bounds.width
        let alertHeight: CGFloat = view.bounds.height

        let alertViewFrame = CGRect(x: 0, y: 0, width: alertWidth, height: alertHeight)

        alertView = UIView(frame: alertViewFrame)
        //alertView.backgroundColor = UIColor.white
        
        // Create  image view and add it to this view
        let xPoint = (alertView.frame.width / 2) - 64
        let yPoint = (alertView.frame.height / 2) - 64
        let imageView = UIImageView(frame: CGRect(x: xPoint, y: yPoint, width: 128, height: 128))
        let image = UIImage(named: "world")
        imageView.image = image
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        alertView.addSubview(imageView)
        
        // Create a button and set a listener on it for when it is tapped. Then the button is added to the alert view
        /*let button = UIButton(type: UIButtonType.system) as UIButton
        button.setTitle("Dismiss", for: UIControlState.normal)
        button.backgroundColor = UIColor.white
        let buttonWidth: CGFloat = alertWidth/2
        let buttonHeight: CGFloat = 40
        
        button.frame = CGRect(x: alertView.center.x - buttonWidth/2, y: alertView.center.y - buttonHeight/2, width: buttonWidth, height: buttonHeight)
        
        button.addTarget(self, action: #selector(self.dismissAlert), for: .touchUpInside)
        
        alertView.addSubview(button)*/
        view.addSubview(alertView)
    }
    
    func dismissAlert() { //@objc
        let bounds = alertView.bounds

        let smallFrame = alertView.frame.insetBy(dx: alertView.frame.width / 2, dy: alertView.frame.width / 4)
        let finalFrame = smallFrame.offsetBy(dx: smallFrame.width, dy: bounds.size.height)
        
        let snapshot = alertView.snapshotView(afterScreenUpdates: false)!
        snapshot.frame = alertView.frame
        view.addSubview(snapshot)
        alertView.removeFromSuperview()
        
        UIView.animateKeyframes(withDuration: 3, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                snapshot.frame = smallFrame
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                snapshot.frame = finalFrame
            }
        }, completion: { _ in
            self.showMainViewController()
        })
    }
    
    func showMainViewController() {
        guard !(rootViewController is UITabBarController) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav =  storyboard.instantiateViewController(withIdentifier: "NavigationMain") as! UITabBarController
        nav.willMove(toParentViewController: self)
        addChildViewController(nav)
        
        if let rootViewController = self.rootViewController {
            self.rootViewController = nav
            rootViewController.willMove(toParentViewController: nil)
            
            transition(from: rootViewController, to: nav, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
                
            }, completion: { _ in
                nav.didMove(toParentViewController: self)
                rootViewController.removeFromParentViewController()
                rootViewController.didMove(toParentViewController: nil)
            })
        } else {
            rootViewController = nav
            view.addSubview(nav.view)
            nav.didMove(toParentViewController: self)
        }
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
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
