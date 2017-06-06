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

	@IBOutlet weak var trackMeSegmentedControl: TwicketSegmentedControl!
	@IBOutlet weak var accuracySegmentedControl: TwicketSegmentedControl!

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
//		1: .country,
		1: .city,
		2: .neighborhood,
		3: .block,
		4: .house,
//		6: .room,
		5: .navigation
	]

	var accuracy: Accuracy {
		let index = accuracySegmentedControl.selectedSegmentIndex
		return accuracyMap[index]!
	}
	var isOn: Bool {
		return trackMeSegmentedControl.selectedSegmentIndex == 0
	}
	var locationRequest: LocationRequest?

	var accuracyDelegate: ConsolidatedTwicketSegmentedControlDelegate!
	var stateDelegate: ConsolidatedTwicketSegmentedControlDelegate!

	override func viewDidLoad() {
		super.viewDidLoad()

		accuracyDelegate = ConsolidatedTwicketSegmentedControlDelegate(accuracyDidChange)
		stateDelegate = ConsolidatedTwicketSegmentedControlDelegate(stateDidChange)

		monitorHeading = true

		let items = [
			"Any",
//			"Country",
			"~3km",
			"~1km",
			"~100m",
			"~15m",
//			"Room",
			"Best"
		]
		accuracySegmentedControl.setSegmentItems(items)
		accuracySegmentedControl.move(to: 0)
		accuracySegmentedControl.backgroundColor = UIColor.black
		accuracySegmentedControl.isSliderShadowHidden = true
		accuracySegmentedControl.delegate = accuracyDelegate
		accuracyDidChange(0)

		let stateItems = [
			"On",
			"Off",
		]
		trackMeSegmentedControl.setSegmentItems(stateItems)
		trackMeSegmentedControl.move(to: 0)
		trackMeSegmentedControl.backgroundColor = UIColor.black
		trackMeSegmentedControl.isSliderShadowHidden = true
		trackMeSegmentedControl.sliderBackgroundColor = UIColor.green
		trackMeSegmentedControl.delegate = stateDelegate
		stateDidChange(00)

		let preferenceOrder: [Accuracy] = [
			.any,
			.navigation
		]

		Location.displayHeadingCalibration = true

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

	func accuracyDidChange(_ segment: Int) {
		log(debug: "Segment = \(segment)")
		guard let accuracy = accuracyMap[segment] else {
			return
		}
		updateAccuracy()
	}

	func updateAccuracy() {
		if let locationRequest = locationRequest {
			locationRequest.cancel()
		}
		guard isOn else {
			return
		}
		let requestSuccess: LocObserver.onSuccess = { request, location in
			self.update(location)
			self.compassView.update(location: location)
		}
		let requestFail: LocObserver.onError = { request, location, error in
			request.cancel()
			log(error: error)
		}

		locationRequest = Location.getLocation(
				accuracy: accuracy,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)
		locationRequest?.name = accuracy.description
	}

	func stateDidChange(_ segment: Int) {
		switch segment {
		case 0:
			trackMeSegmentedControl.sliderBackgroundColor = UIColor.green
			updateAccuracy()
		case 1:
			trackMeSegmentedControl.sliderBackgroundColor = UIColor.red
			if let locationRequest = locationRequest {
				locationRequest.cancel()
			}
		default: break
		}
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
		log(debug: "\(location)")
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

typealias SegmentSelection = (_ segmentIndex: Int) -> Void

class ConsolidatedTwicketSegmentedControlDelegate: TwicketSegmentedControlDelegate {

	let monitor: SegmentSelection

	init(_ monitor: @escaping SegmentSelection) {
		self.monitor = monitor
	}

	public func didSelect(_ segmentIndex: Int) {
		monitor(segmentIndex)
	}
}
