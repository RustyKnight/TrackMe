//
//  CompassView.swift
//  TrackMe
//
//  Created by Shane Whitehead on 24/5/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import UIKit
import MapKit

class CompassView: UIView {
	
	var accuracy: Double = 0.0
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}
	
	func configure() {
	}
	
	func updateCompass(heading: CLHeading) {
		let direction = -heading.trueHeading
		let radians = direction.toRadians// + delta.toRadians
		accuracy = heading.headingAccuracy
		UIView.animate(withDuration: 0.5) {
			self.transform = CGAffineTransform(rotationAngle: radians.toCGFloat)
		}
		setNeedsDisplay()
	}

	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		guard let ctx = UIGraphicsGetCurrentContext() else {
			return
		}
		defer {
			UIGraphicsPopContext()
			ctx.restoreGState()
		}
		ctx.saveGState()
		UIGraphicsPushContext(ctx)

		let viewableBounds: CGRect = bounds
		let center = CGPoint(x: viewableBounds.width / 2, y: viewableBounds.height / 2)

		// The intention here is to rotate the context to the "start angle" position
		//		ctx.translateBy(x: center.x, y: center.y)
		//		ctx.rotate(by: -90.0.toRadians.toCGFloat)
		//
		//		// But we need to reset the origin
		//		ctx.translateBy(x: -center.x, y: -center.y)
		
		let startAt = ((360.0 - (accuracy / 2.0)) - 90.0).toCGFloat
		let endAt = ((accuracy / 2.0) - 90.0).toCGFloat
		
		logger.debug("Accuracy = \(accuracy); Range = \(startAt)-\(endAt)")
		
		let size = min(viewableBounds.width, viewableBounds.height)
		let radius = size / 2.0
		let path = CGMutablePath()
		path.addArc(
				center: center,
				radius: radius,
				startAngle: startAt.toRadians,
				endAngle: endAt.toRadians,
				clockwise: false)
		
		ctx.addPath(path)
		ctx.setStrokeColor(UIColor.red.cgColor)
		ctx.setLineWidth(3.0)
		ctx.drawPath(using: .stroke)

		let x = (viewableBounds.width - size) / 2
		let y = (viewableBounds.height - size) / 2
		let compassBounds = CGRect(x: x, y: y, width: size, height: size)
		logger.debug(compassBounds)
		TrackMe.drawCompass(frame: compassBounds)
	}

}
