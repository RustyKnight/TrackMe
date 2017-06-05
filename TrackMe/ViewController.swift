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
import AELog
import AEConsole
import TwicketSegmentedControl

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

	@IBOutlet weak var segmentedControl: TwicketSegmentedControl!
	
	@IBOutlet weak var trueHeading: UILabel!
	
	@IBOutlet weak var courseLabel: UILabel!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var altitudeLabel: UILabel!
	
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	
	@IBOutlet weak var compassView: CompassView!
	
	let numberFormatter = NumberFormatter()
	let measurementFormatter = MeasurementFormatter()
	
	var headingRequest: HeadingRequest?
	
	var accuracyMap: [Int: Accuracy] = [
		0: .any,
		1: .country,
		2: .city,
		3: .neighborhood,
		4: .block,
		5: .house,
		6: .room,
		7: .navigation
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		monitorHeading = true
		
		let items = [
			"Any",
			"Country",
			"City",
			"Neighbourhood",
			"Block",
			"House",
			"Room",
			"Navigation"
		]
		segmentedControl.setSegmentItems(items)
		segmentedControl.move(to: 0)
		
		let preferenceOrder: [Accuracy] = [
			.any,
			.navigation
		]
		
		let requestSuccess: LocObserver.onSuccess = { request, location in
			self.update(location)
			self.compassView.update(location: location)
		}
		let requestFail: LocObserver.onError = { request, location, error in
			request.cancel()
			log(error: error)
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
		
		NotificationCenter.default.addObserver(
				self,
				selector: #selector(willEnterForeground),
				name: NSNotification.Name.UIApplicationWillEnterForeground,
				object: nil)
		NotificationCenter.default.addObserver(
				self,
				selector: #selector(didEnterBackground),
				name: NSNotification.Name.UIApplicationDidEnterBackground,
				object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func willEnterForeground(_ notification: NSNotification) {
		log(debug: "In the foreground")
		monitorHeading = true
	}
	
	func didEnterBackground(_ notification: NSNotification) {
		log(debug: "In the background")
		monitorHeading = false
	}
	
	var monitorHeading: Bool = true {
		didSet {
			if monitorHeading {
				do {
					headingRequest = try Location.getContinousHeading(filter: 0.2, success: { result in
						let heading = result.1
						if heading.headingAccuracy > 5.0 {
							Location.displayHeadingCalibration = true
						} else {
							Location.displayHeadingCalibration = false
						}
						self.compassView.updateCompass(heading: heading)
						self.trueHeading.text = "True Heading = \(self.format(double: abs(heading.trueHeading)))°"
					}) { error in
						log(error: "Failed to update heading \(error)")
					}
				} catch {
					log(error: "Cannot start heading updates: \(error)")
				}
			} else {
				guard let headingRequest = headingRequest else {
					return
				}
				headingRequest.cancel()
				self.headingRequest = nil
			}
		}
	}

	func format(double number: Double) -> String {
		return format(NSNumber(value: number))
	}
	
	func format(_ number: NSNumber) -> String {
		guard let text = self.numberFormatter.string(from: number) else {
			return "\(number)"
		}
		return text
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
		
		let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.meters);
		let hAccuracyMeasurement = Measurement(value: hAccuracy, unit: UnitLength.meters);
		let vAccuracyMeasurement = Measurement(value: vAccuracy, unit: UnitLength.meters);
		let speedMeasurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond);
		
		measurementFormatter.unitOptions = .naturalScale
		measurementFormatter.unitStyle = .short
		
		altitudeLabel.text = "Altitude = \(measurementFormatter.string(from: altitudeMeasurement))"
		speedLabel.text = "Speed = \(measurementFormatter.string(from: speedMeasurement))"
		courseLabel.text = "Course \(format(double: abs(course)))°"
	}
	
}

extension ViewController: TwicketSegmentedControlDelegate {
	public func didSelect(_ segmentIndex: Int) {
	
	}
}
