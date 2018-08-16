//
//  Position.swift
//  Safety
//
//  Created by Dennis Schmidt on 16/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import Foundation

class Position: NSObject {
    
    @objc var latitude: Double
    @objc var longitude: Double
    @objc var date: Date
    @objc var backgroundText: String
    
    init (latitude: Double, longitude: Double, backgroundText: String) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.backgroundText = backgroundText
        self.date = Date()
        
    }
    
}
