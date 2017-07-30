//
//  File.swift
//  TrackMe
//
//  Created by Shane Whitehead on 2/7/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import TableViewKit

enum AdventuresSections {
	case adventures
}

enum AdventureTableCellIdentifier: String {
	case adventure = "Cell.adventure"
}

enum AdventureSegueIdentifier: String {
	case adventure = "Cell.adventure"
}

class AdventuresTableViewModel: TVKDynamicModel<AdventuresSections> {
	
	var adventures: [Adventure] {
		set {
			guard let section = allSections[.adventures] as? AdventuresTableViewSection else {
				return
			}
			section.adventures = newValue
		}
		
		get {
			guard let section = allSections[.adventures] as? AdventuresTableViewSection else {
				return []
			}
			return section.adventures
		}
	}
	
	override init() {
		super.init()
		
		allSections = [
			.adventures: AdventuresTableViewSection(delegate: self)
		]
		preferredSectionOrder = [
			.adventures
		]
		
		updateContents()
	}
	
}
