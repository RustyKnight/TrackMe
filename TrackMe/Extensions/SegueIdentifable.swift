//
//  UIViewController+Segue.swift
//  TrackMe
//
//  Created by Shane Whitehead on 3/7/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import UIKit

protocol SegueIdentifable {
	associatedtype SegueIdentifier: RawRepresentable
}

extension SegueIdentifable where Self: UIViewController,
	SegueIdentifier.RawValue == String
{
	
	func performSegueWithIdentifier(segueIdentifier: SegueIdentifier,
	                                sender: AnyObject?) {
		
		performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
	}
	
	func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
		
		// still have to use guard stuff here, but at least you're
		// extracting it this time
		guard let identifier = segue.identifier,
			let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
				fatalError("Invalid segue identifier \(segue.identifier).") }
		
		return segueIdentifier
	}
}
