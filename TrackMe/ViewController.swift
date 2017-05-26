//
//  ViewController.swift
//  TrackMe
//
//  Created by Shane Whitehead on 12/5/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import UIKit
import SwiftLocation
import MapKit
import XCGLogger

extension Accuracy {
	static func from(_ name: String) -> Accuracy? {
		switch name.lowercased() {
			case "any": return .any
			case "city": return .city
			case "neighborhood": return .neighborhood
			case "block": return .block
			case "navigation": return .navigation
			case "house": return .house
			case "room": return .room
			default: return nil
		}
	}
}

class ViewController: UIViewController {
	
	@IBOutlet weak var courseLabel: UILabel!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var vAccuracyLabel: UILabel!
	@IBOutlet weak var hAccuracyLabel: UILabel!
	@IBOutlet weak var altitudeLabel: UILabel!
	
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	
	@IBOutlet weak var compassView: CompassView!
	
	let compassLayer: CompassLayer = CompassLayer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		view.layer.addSublayer(compassLayer)
		
		let preferenceOrder: [Accuracy] = [
			.any,
//			.city,
//			.neighborhood,
//			.block,
			.navigation
		]
		
		let requestSuccess: LocObserver.onSuccess = { request, location in
			self.update(location)
		}
		let requestFail: LocObserver.onError = { request, location, error in
			request.cancel()
			logger.error(error)
		}
		
		for accuracy in preferenceOrder {
			let request = Location.getLocation(
					accuracy: accuracy,
					frequency: .continuous,
					success: requestSuccess,
					error: requestFail)
			request.name = accuracy.description
		}

		do {
			try Location.getContinousHeading(filter: 0.2, success: { heading in
				logger.debug("New heading value \(heading)")
				self.compassView.updateCompass(heading: heading.1)
			}) { error in
				logger.error("Failed to update heading \(error)")
			}
		} catch {
			logger.error("Cannot start heading updates: \(error)")
		}
	}

	func updateCompass(heading: CLHeading) {
		let radians = heading.magneticHeading.toRadians
		let animation = CABasicAnimation(keyPath: "transform.rotation")
		animation.toValue = radians
		animation.duration = 0.5
		compassLayer.add(animation, forKey: nil)
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		logger.debug(view.bounds);
		compassLayer.frame = view.bounds
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func update(_ location: CLLocation) {
		let coordinate = location.coordinate
		let altitude = location.altitude
		
		let hAccuracy = location.horizontalAccuracy
		let vAccuracy = location.verticalAccuracy
		
		let speed = location.speed
		let course = location.course
		
		latitudeLabel.text = coordinate.latitudeDegreeDescription
		longitudeLabel.text = coordinate.longitudeDegreeDescription
		
		let formatter = MeasurementFormatter()
		
		let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.meters);
		let hAccuracyMeasurement = Measurement(value: hAccuracy, unit: UnitLength.meters);
		let vAccuracyMeasurement = Measurement(value: vAccuracy, unit: UnitLength.meters);
		let speedMeasurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond);
		
		formatter.unitOptions = .naturalScale
		formatter.unitStyle = .short
		
		altitudeLabel.text = formatter.string(from: altitudeMeasurement)
		hAccuracyLabel.text = formatter.string(from: hAccuracyMeasurement)
		vAccuracyLabel.text = formatter.string(from: vAccuracyMeasurement)
		speedLabel.text = formatter.string(from: speedMeasurement)
		courseLabel.text = "\(abs(course))°"
	}
	
	
}

