//
//  LocationNow.swift
//  Walking
//
//  Created by Dennis Schmidt on 14/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import Foundation

class LocationNow: NSObject {
    
    @objc var id: String!
    @objc var journeyID: String
    @objc var latitude: Double
    @objc var longitude: Double
    
    init (journeyID: String, latitude: Double, longitude: Double) {
        
        self.journeyID = journeyID
        self.latitude = latitude
        self.longitude = longitude
        
    }

}
