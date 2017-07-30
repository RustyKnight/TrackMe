//
// Created by Shane Whitehead on 12/6/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import RealmSwift
import Hydra
import UIKit

class Adventure: Object {
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var name: String = ""
	@objc dynamic var localeIdentifiers = ""
}

class Trek: Object {
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var adveture: Adventure!
	@objc dynamic var latitude = 0.0
	@objc dynamic var longitude = 0.0
	@objc dynamic var created = Date()
}

class Note: Object {
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var trek: Trek!
	@objc dynamic var note: String = ""
}

class Photo: Object {
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var trek: Trek!
	@objc dynamic var image: UIImage!
}

class AdventureManager {
	static let shared:AdventureManager = AdventureManager()
	
	func adventures() -> Promise<[Adventure]> {
		return Promise<[Adventure]>(in: .userInitiated) { (fulfill, fail) in
			let realm: Realm = try Realm()
			let results: Results<Adventure> = realm.objects(Adventure.self)
			
			fulfill(Array(results))
		}
	}
}
