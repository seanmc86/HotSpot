//
//  TabViewController.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/26.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

}
