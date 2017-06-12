//
// Created by Shane Whitehead on 12/6/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import RealmSwift

class Trek: Object {
	dynamic var name: String = ""
	dynamic var localeIdentifiers = ""
}

class TrekPoint: Object {
	dynamic var trip: Trek!
	dynamic var latitude = 0.0
	dynamic var longitude = 0.0
	dynamic var created = Date()
}