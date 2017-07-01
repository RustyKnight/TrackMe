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
import BetterSegmentedControl

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
    
    @IBOutlet weak var updateCount: UILabel!
    
    @IBOutlet weak var trackMeStatus: BetterSegmentedControl!
    @IBOutlet weak var accuracySetting: BetterSegmentedControl!
    
    @IBOutlet weak var trueHeading: UILabel!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var primaryLocationStatusView: UIView!
    @IBOutlet weak var compassView: CompassView!
    
    let numberFormatter = NumberFormatter()
    let measurementFormatter = MeasurementFormatter()
    
    var headingRequest: HeadingRequest?
    
    var accuracyMap: [UInt: Accuracy] = [
        0: .any,
//        1: .country,
        1: .city,
        2: .neighborhood,
        3: .block,
        4: .house,
//        6: .room,
        5: .navigation
    ]
    
    var accuracy: Accuracy {
        let index = accuracySetting.index
        return accuracyMap[index]!
    }
    
    var isOn: Bool {
        return trackMeStatus.index == 0
    }
    var locationRequest: LocationRequest?
    
    var updates: Int = 0
    
    var monitorHeading: Bool = true {
        didSet {
            if monitorHeading {
                if let headingRequest = headingRequest {
                    headingRequest.cancel()
                    self.headingRequest = nil
                }
                do {
                    headingRequest = try Location.getContinousHeading(
                            filter: 0.2,
                            success: onHeadingUpdate,
                            failure: onHeadingFailure)
                } catch let error {
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
    
    var pulseCount: Int = 0
    var pulseLimit: Int = 100
    
    var pulseRequest: LocationRequest {
        pulseCount = 0
        return LocationRequest(
                name: accuracy.description,
                accuracy: accuracy,
                frequency: .continuous,
                activity: .fitness,
                onPulseUpdate,
                onLocationFailure)
    }
    
    var standardRequest: LocationRequest {
        return LocationRequest(
                name: accuracy.description,
                accuracy: accuracy,
                frequency: .continuous,
                activity: .fitness,
                minimumDistance: 10.0,
                onLocationUpdate,
                onLocationFailure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Location.displayHeadingCalibration = true
        
        monitorHeading = true
        
        let items = [
            "Any",
            formatDistance(for: accuracyMap[1]),
            formatDistance(for: accuracyMap[2]),
            formatDistance(for: accuracyMap[3]),
            formatDistance(for: accuracyMap[4]),
            "Best",
        ]
        accuracySetting.titles = items
        accuracySetting.addTarget(
                self,
                action: #selector(ViewController.accuracyDidChange(_:)),
                for: .valueChanged)
        accuracySetting.bouncesOnChange = true
        accuracySetting.cornerRadius = 20.0
        accuracySetting.indicatorViewBackgroundColor = UIColor.green.darken(by: 0.5)
        accuracySetting.titleColor = UIColor.white
        accuracySetting.backgroundColor = UIColor.darkGray
        
        let stateItems = [
            "On",
            "Off",
        ]
        trackMeStatus.titles = stateItems
        trackMeStatus.addTarget(
                self,
                action: #selector(ViewController.stateDidChange(_:)),
                for: .valueChanged)
        trackMeStatus.bouncesOnChange = true
        trackMeStatus.cornerRadius = 20.0
        trackMeStatus.indicatorViewBackgroundColor = UIColor.green.darken(by: 0.5)
        trackMeStatus.titleColor = UIColor.white
        trackMeStatus.backgroundColor = UIColor.darkGray
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            try accuracySetting.setIndex(4, animated: false)
        } catch let error {
            log(error: error)
        }
        do {
            try trackMeStatus.setIndex(0, animated: false)
        } catch let error {
            log(error: error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func accuracyDidChange(_ sender: BetterSegmentedControl) {
        log(debug: "Segment = \(sender.index)")
        guard accuracyMap[sender.index] != nil else {
            return
        }
        updateAccuracy()
    }
    
    func updateAccuracy() {
        cancelLocationRequest()
        guard isOn else {
            return
        }
        
        locationRequest = pulseRequest
        locationRequest?.resume()
    }
    
    @objc func stateDidChange(_ sender: BetterSegmentedControl) {
        switch sender.index {
            case 0:
                UIView.animate(withDuration: 0.3) {
                    self.compassView.alpha = 1.0
                    self.primaryLocationStatusView.alpha = 1.0
                    self.trackMeStatus.indicatorViewBackgroundColor = UIColor.green.darken(by: 0.5)
                }
                monitorHeading = true
                updateAccuracy()
            case 1:
                UIView.animate(withDuration: 0.3) {
                    self.compassView.alpha = 0.25
                    self.primaryLocationStatusView.alpha = 0.25
                    self.trackMeStatus.indicatorViewBackgroundColor = UIColor.red.darken(by: 0.5)
                }
//                trackMeSegmentedControl.sliderBackgroundColor = UIColor.red
                monitorHeading = false
                cancelLocationRequest()
                self.update(nil)
            default: break
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
    
    func update(_ location: CLLocation?) {
        guard let location = location else {
            latitudeLabel.text = "Lat = ---"
            longitudeLabel.text = "Lon = ---"
            
            altitudeLabel.text = "Altitude = ---"
            speedLabel.text = "Speed = ---"
            courseLabel.text = "Course ---°"
            return
        }
        let coordinate = location.coordinate
        let altitude = location.altitude
        
        let hAccuracy = location.horizontalAccuracy
        let vAccuracy = location.verticalAccuracy
        
        let speed = location.speed
        let course = location.course
        
        latitudeLabel.text = "Lat = \(coordinate.latitudeDegreeDescription)"
        longitudeLabel.text = "Lon = \(coordinate.longitudeDegreeDescription)"
        
        let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.meters);
//        let hAccuracyMeasurement = Measurement(value: hAccuracy, unit: UnitLength.meters);
//        let vAccuracyMeasurement = Measurement(value: vAccuracy, unit: UnitLength.meters);
        let speedMeasurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond);
        
        measurementFormatter.unitOptions = .naturalScale
        measurementFormatter.unitStyle = .short
        
        altitudeLabel.text = "Altitude = \(measurementFormatter.string(from: altitudeMeasurement))"
        speedLabel.text = "Speed = \(measurementFormatter.string(from: speedMeasurement))"
        courseLabel.text = "Course \(format(double: abs(course)))°"
    }
    
    func formatDistance(for accuracy: Accuracy?) -> String {
        guard let accuracy = accuracy else {
            return "---"
        }
        let measurement = Measurement(value: accuracy.level, unit: UnitLength.meters);
        measurementFormatter.unitOptions = .naturalScale
        measurementFormatter.unitStyle = .short
        
        return measurementFormatter.string(for: measurement) ?? format(double: accuracy.level)
    }
    
}

extension ViewController {
    
    @objc func willEnterForeground(_ notification: NSNotification) {
        log(debug: "In the foreground")
        monitorHeading = true
        cancelLocationRequest()
        locationRequest = pulseRequest
        locationRequest?.resume()
    }
    
    @objc func didEnterBackground(_ notification: NSNotification) {
        log(debug: "In the background")
        monitorHeading = false
        cancelLocationRequest()
        locationRequest = standardRequest
        locationRequest?.resume()
    }
    
}

extension ViewController {
    
    func onHeadingUpdate(_ request: HeadingRequest, _ heading: CLHeading) -> Void {
        if heading.headingAccuracy > 5.0 {
            Location.displayHeadingCalibration = true
        } else {
            Location.displayHeadingCalibration = false
        }
        self.compassView.updateCompass(heading: heading)
        self.trueHeading.text = "True Heading = \(self.format(double: abs(heading.trueHeading)))°"
    }
    
    func onHeadingFailure(_ request: HeadingRequest, _ error: Error) -> Void {
        log(error: "Failed to update heading \(error)")
    }
    
}

extension ViewController {

    func cancelLocationRequest() {
        if let locationRequest = locationRequest {
            log(debug: "Cancel Request")
            locationRequest.cancel()
        }
    }
    
    func onPulseUpdate(_ request: LocationRequest, _ location: CLLocation) -> Void {
        pulseCount += 1
        let accuracy = self.accuracy
        if pulseCount >= pulseLimit || location.horizontalAccuracy >= accuracy.level {
            cancelLocationRequest()
            locationRequest = standardRequest
            locationRequest?.resume()
        }
        onLocationUpdate(request, location)
    }
    
    func onLocationUpdate(_ request: LocationRequest, _ location: CLLocation) -> Void {
        self.update(location)
        self.updates += 1
        self.updateCount.text = String(self.updates)
        let range = self.accuracy.level
        self.compassView.update(
                location: location,
                minimumAcceptableRange: range)
    }
    
    func onLocationFailure(_ request: LocationRequest, _ lastLocation: CLLocation?, _ error: Error) -> Void {
        request.cancel()
        if let locationRequest = locationRequest {
            locationRequest.cancel()
            self.locationRequest = nil
        }
        log(error: error)
    }
    
}
