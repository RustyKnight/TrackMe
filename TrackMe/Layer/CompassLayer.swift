//
// Created by Shane Whitehead on 14/5/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import UIKit

class CompassLayer: CALayer {
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}
	
	override init() {
		super.init()
		configure()
	}
	
	func configure() {
		needsDisplayOnBoundsChange = true
	}
	
//	/*
//	Override initWithLayer: to copy the properties into the new layer. This method gets called for each
//	frame of animation. Core Animation makes a copy of the presentationLayer for each frame of the animation.
//	By overriding this method we make sure our custom properties are correctly transferred to the copied-layer.
//	*/
//	override init(layer: Any) {
//		super.init(layer: layer)
//		if let layer = layer as? CompassLayer {
//			angle = layer.angle
//		}
//	}
//
//	/*
//	Override actionForKey: and return a CAAnimation that prepares the animation for that property.
//	In our case, we will return an animation for the startAngle and endAngle properties.
//	*/
//	override func action(forKey event: String) -> CAAction? {
//		var action: CAAction?
//		if event == "angle" {
//			action = self.animation(forKey: event)
//		} else {
//			action = super.action(forKey: event)
//		}
//		return action
//	}
//
//	/*
//	Finally we also need to override needsDisplayForKey: to tell Core Animation that changes to our
//	startAngle and endAngle properties will require a redraw.
//	*/
//	override class func needsDisplay(forKey key: String) -> Bool {
//		var needsDisplay = false
//		if key == "angle" {
//			needsDisplay = true
//		} else {
//			needsDisplay = super.needsDisplay(forKey: key)
//		}
//		return needsDisplay
//	}
	
	/*
	Here we draw the slice just the way we did earlier. Instead of using UIBezierPath, we now go with the
	Core Graphics calls. Since the startAngle and endAngle properties are animatable and also marked for
	redraw, this layer will be rendered each frame of the animation. This will give us the desired animation
	when the slice changes its inscribed angle.
	*/
	override func draw(in ctx: CGContext) {
		let viewableBounds: CGRect = bounds
		let center = CGPoint(x: viewableBounds.width / 2, y: viewableBounds.height / 2)
		
		ctx.saveGState()
		
		// The intention here is to rotate the context to the "start angle" position
		ctx.translateBy(x: center.x, y: center.y)
		ctx.rotate(by: -90.0.toRadians.toCGFloat)
		
		// But we need to reset the origin
		ctx.translateBy(x: -center.x, y: -center.y)
		
		let size = min(viewableBounds.width, viewableBounds.height)
		let x = (viewableBounds.width - size) / 2
		let y = (viewableBounds.height - size) / 2
		let compassBounds = CGRect(x: x, y: y, width: size, height: size)
		TrackMe.drawCompass(frame: compassBounds)

//		CGContextRestoreGState(ctx)
		ctx.restoreGState()
		
	}
	
//	open func startAnimation(withDurationOf duration: Double, withDelegate: AnyObject?) {
//		removeAnimation(forKey: "progress")
//		removeAnimation(forKey: "fillEffect")
//
//		if let colorBand = colorBand {
//			let keyFrameAnim = CAKeyframeAnimation(keyPath: "fillColor")
//
//			var colors: [UIColor] = []
//			var locations: [Double] = []
//			for i in stride(from: 0.0, to: 1.0, by: 0.01) {
//				colors.append(colorBand.colorAt(i))
//				locations.append(i)
//			}
//
////			for colorBandEntry in colorBand.entries {
////				colors.append(colorBandEntry.color)
////				locations.append(colorBandEntry.location)
////			}
//
//			keyFrameAnim.values = colors
//			keyFrameAnim.keyTimes = locations as [NSNumber]
//			keyFrameAnim.duration = duration
//			add(keyFrameAnim, forKey: "fillEffect")
//		}
//
//		let anim = CABasicAnimation(keyPath: "progress")
//		anim.delegate = withDelegate as! CAAnimationDelegate
//
//		anim.fromValue = 0
//		anim.toValue = 1.0
//		anim.duration = duration
//		add(anim, forKey: "progress")
//	}
//
//	open func stopAnimation(andReset reset: Bool = false) {
//		removeAnimation(forKey: "progress")
//		removeAnimation(forKey: "fillEffect")
//		if (reset) {
//			progress = 0.0
//		}
//	}
	
}
