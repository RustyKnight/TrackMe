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

class ViewController: UIViewController {

	@IBOutlet weak var courseLabel: UILabel!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var vAccuracyLabel: UILabel!
	@IBOutlet weak var hAccuracyLabel: UILabel!
	@IBOutlet weak var altitudeLabel: UILabel!

	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		let requestSuccess: LocObserver.onSuccess = { request, location in
			self.update(location)
			logger.debug(location)
		}
		let requestFail: LocObserver.onError = { request, location, error in
			request.cancel()
			logger.error(error)
		}

		Location.getLocation(
				accuracy: .any,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)
		Location.getLocation(
				accuracy: .city,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)
		Location.getLocation(
				accuracy: .neighborhood,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)
		Location.getLocation(
				accuracy: .block,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)
		Location.getLocation(
				accuracy: .navigation,
				frequency: .continuous,
				success: requestSuccess,
				error: requestFail)

//		do {
//			try Location.getContinousHeading(filter: 0.2, success: { heading in
//				logger.debug("New heading value \(heading)")
//			}) { error in
//				logger.error("Failed to update heading \(error)")
//			}
//		} catch {
//			logger.error("Cannot start heading updates: \(error)")
//		}
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

		altitudeLabel.text = formatter.string(from: altitudeMeasurement)
		hAccuracyLabel.text = formatter.string(from: hAccuracyMeasurement)
		vAccuracyLabel.text = formatter.string(from: vAccuracyMeasurement)
		speedLabel.text = formatter.string(from: speedMeasurement)
		courseLabel.text = "\(abs(course))°"
	}


}

