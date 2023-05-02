//
//  MainViewController.swift
//  ISSTrackerDemoSwiftUI
//
//  Created by Donald Angelillo on 5/2/23.
//

import SwiftUI

class MainViewController: UIHostingController<MainView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "ISS Tracker"
    }
}
