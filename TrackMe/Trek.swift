//
// Created by Shane Whitehead on 12/6/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import RealmSwift

class Trek: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var localeIdentifiers = ""
}

class TrekPoint: Object {
    @objc dynamic var trip: Trek!
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var created = Date()
}
