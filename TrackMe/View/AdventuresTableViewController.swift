//
//  AdventuresTableViewController.swift
//  TrackMe
//
//  Created by Shane Whitehead on 2/7/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import UIKit
import TableViewKit

class AdventuresTableViewController: TVKDefaultTableViewController, SegueIdentifable {
	
	enum SegueIdentifier: String {
		case detail = "Segue.AdventureDetail"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
}
