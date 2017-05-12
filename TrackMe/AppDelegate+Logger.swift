//
//  AppDelegate+Logger.swift
//  TrackMe
//
//  Created by Shane Whitehead on 12/5/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import XCGLogger

extension AppDelegate {
	func configureLogger() {
		// Create a destination for the system console log (via NSLog)
		let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
		
		// Optionally set some configuration options
		systemDestination.outputLevel = .debug
		systemDestination.showLogIdentifier = false
		systemDestination.showFunctionName = true
		systemDestination.showThreadName = true
		systemDestination.showLevel = true
		systemDestination.showFileName = true
		systemDestination.showLineNumber = true
		systemDestination.showDate = true
		
		// Add the destination to the logger
		logger.add(destination: systemDestination)
		
//		// Create a file log destination
//		let fileDestination = FileDestination(writeToFile: "/path/to/file", identifier: "advancedLogger.fileDestination")
//		
//		// Optionally set some configuration options
//		fileDestination.outputLevel = .debug
//		fileDestination.showLogIdentifier = false
//		fileDestination.showFunctionName = true
//		fileDestination.showThreadName = true
//		fileDestination.showLevel = true
//		fileDestination.showFileName = true
//		fileDestination.showLineNumber = true
//		fileDestination.showDate = true
//		
//		// Process this destination in the background
//		fileDestination.logQueue = XCGLogger.logQueue
//		
//		// Add the destination to the logger
//		log.add(destination: fileDestination)
		
		// Add basic app info, version info etc, to the start of the logs
		logger.logAppDetails()
	}
}
