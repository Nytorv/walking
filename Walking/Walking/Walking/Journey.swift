//
//  Journey.swift
//  Walking
//
//  Created by Dennis Schmidt on 14/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import Foundation

class Journey: NSObject {
    
    @objc var id: String!
    @objc var title: String!
    @objc var starting: Date!
    @objc var ending: Date?
    @objc var note: String!
    var distance: Double

    init(title: String, starting: Date, ending: Date, note: String) {
    
        self.title = title
        self.starting = starting
        self.ending = ending
        self.note = note
        self.distance = 0
        
    }
    
}
