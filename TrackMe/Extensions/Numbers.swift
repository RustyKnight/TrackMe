//
// Created by Shane Whitehead on 14/5/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import UIKit

public extension Float {
	public var toRadians : Float {
		return self * Float(Double.pi) / 180.0
	}
	public var toDegrees: Float {
		return self * 180 / Float(Double.pi)
	}
	public var toDouble: Double {
		return Double(self)
	}
}

public extension Double {
	public var toRadians : Double {
		return self * Double.pi / 180.0
	}
	
	public var toDegrees: Double {
		return self * 180 / Double.pi
	}
	
	public var toFloat: Float {
		return Float(self)
	}
}

public extension Float {
	public var toCGFloat: CGFloat {
		return CGFloat(self)
	}
}

public extension Double {
	public var toCGFloat: CGFloat {
		return CGFloat(self)
	}
}

public extension CGFloat {
	public var toRadians : CGFloat {
		return CGFloat(self) * CGFloat(Double.pi) / 180.0
	}
	
	public var toDegrees: CGFloat {
		return self * 180.0 / CGFloat(Double.pi)
	}
	
	public var toDouble: Double {
		return Double(self)
	}
	
	public var toFloat: Float {
		return Float(self)
	}
}

