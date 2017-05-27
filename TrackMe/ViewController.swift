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
	@IBOutlet weak var magneticHeading: UILabel!
	@IBOutlet weak var trueHeading: UILabel!
	@IBOutlet weak var headingAccuracy: UILabel!
	
	@IBOutlet weak var courseLabel: UILabel!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var vAccuracyLabel: UILabel!
	@IBOutlet weak var hAccuracyLabel: UILabel!
	@IBOutlet weak var altitudeLabel: UILabel!
	
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	
	@IBOutlet weak var compassView: CompassView!
	
//	let compassLayer: CompassLayer = CompassLayer()
	
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
		
		Location.displayHeadingCalibration = true
		
		for accuracy in preferenceOrder {
			let request = Location.getLocation(
					accuracy: accuracy,
					frequency: .continuous,
					success: requestSuccess,
					error: requestFail)
			request.name = accuracy.description
		}

		do {
			try Location.getContinousHeading(filter: 0.2, success: { result in
				let heading = result.1
				if heading.headingAccuracy > 5.0 {
					Location.displayHeadingCalibration = true
				} else {
					Location.displayHeadingCalibration = false
				}
				self.compassView.updateCompass(heading: heading)
				self.magneticHeading.text = "Magnetic Heading = \(heading.magneticHeading)"
				self.trueHeading.text = "True Heading = \(heading.trueHeading)"
				self.headingAccuracy.text = "Heading Accuracy = \(heading.headingAccuracy)"
			}) { error in
				logger.error("Failed to update heading \(error)")
			}
		} catch {
			logger.error("Cannot start heading updates: \(error)")
		}
	}
//
//	func updateCompass(heading: CLHeading) {
//		let radians = (heading.magneticHeading).toRadians
//		let animation = CABasicAnimation(keyPath: "transform.rotation")
//		animation.toValue = radians
//		animation.duration = 0.5
//		compassLayer.add(animation, forKey: nil)
//	}
	
//	open override func viewDidLayoutSubviews() {
//		super.viewDidLayoutSubviews()
//		compassLayer.frame = view.bounds
//	}
	
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
		
		latitudeLabel.text = "Lat = \(coordinate.latitudeDegreeDescription)"
		longitudeLabel.text = "Lon = \(coordinate.longitudeDegreeDescription)"
		
		let formatter = MeasurementFormatter()
		
		let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.meters);
		let hAccuracyMeasurement = Measurement(value: hAccuracy, unit: UnitLength.meters);
		let vAccuracyMeasurement = Measurement(value: vAccuracy, unit: UnitLength.meters);
		let speedMeasurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond);
		
		formatter.unitOptions = .naturalScale
		formatter.unitStyle = .short
		
		altitudeLabel.text = "Altitude = \(formatter.string(from: altitudeMeasurement))"
		hAccuracyLabel.text = "H. Accuracy = \(formatter.string(from: hAccuracyMeasurement))"
		vAccuracyLabel.text = "V. Accuracy= \(formatter.string(from: vAccuracyMeasurement))"
		speedLabel.text = "Speed = \(formatter.string(from: speedMeasurement))"
		courseLabel.text = "Course \(abs(course))°"
	}
	
	
}

