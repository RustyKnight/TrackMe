//
//  AdventureTVRow.swift
//  TrackMe
//
//  Created by Shane Whitehead on 3/7/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import TableViewKit

class AdventureTableViewRow: TVKDefaultSeguableRow<AdventuresTableViewController.SegueIdentifier, AdventureTableCellIdentifier> {
	
	var adventure: Adventure
	
	init(adventure: Adventure, delegate: TVKRowDelegate? = nil) {
		self.adventure = adventure
		super.init(
			segueIdentifier: .detail,
			cellIdentifier: .adventure,
			delegate: delegate)
	}
	
	override func configure(_ cell: UITableViewCell) {
		cell.textLabel?.text = adventure.name
	}
	
}
