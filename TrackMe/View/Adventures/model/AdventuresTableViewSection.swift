//
//  AdventuresSection.swift
//  TrackMe
//
//  Created by Shane Whitehead on 3/7/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import TableViewKit

class AdventuresTableViewSection: DynamicTableViewSection {
	
	var adventures: [Adventure] = [] {
		didSet {
			var added: [Int] = []
			for adventure in adventures {
				let row = AdventureTableViewRow(adventure: adventure)
				rows.append(row)
				guard let index = index(of: row, in: rows) else {
					continue
				}
				added.append(index)
			}
			
			updateContents()
		}
	}
	
	override init(delegate: TVKSectionDelegate) {
		super.init(delegate: delegate)
	}
	
}
