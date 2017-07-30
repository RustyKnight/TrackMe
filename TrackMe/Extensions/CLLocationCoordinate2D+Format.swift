//
// Created by Shane Whitehead on 12/5/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {

	var latitudeDegreeDescription: String {
		return fromDecToDeg(self.latitude) + " \(self.latitude >= 0 ? "N" : "S")"
	}
	var longitudeDegreeDescription: String {
		return fromDecToDeg(self.longitude) + " \(self.longitude >= 0 ? "E" : "W")"
	}
	private func fromDecToDeg(_ input: Double) -> String {
		var inputSeconds = Int(input * 3600)
		let inputDegrees = inputSeconds / 3600
		inputSeconds = abs(inputSeconds % 3600)
		let inputMinutes = inputSeconds / 60
		inputSeconds %= 60
		return "\(abs(inputDegrees))°\(inputMinutes)'\(inputSeconds)''"
	}
}