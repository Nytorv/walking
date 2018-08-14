//
//  LocationThing.swift
//  Likesharing
//
//  Created by Dennis Schmidt on 18/12/2016.
//  Copyright © 2016 Nytorv. All rights reserved.
//

import Foundation
import CoreLocation

class LocationThing: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitudelow: Float!
    var latitudehigh: Float!
    var longitudelow: Float!
    var longitudehigh: Float!
    
    func initialize() {
        
        latitudelow = 0; latitudehigh = 0; longitudelow = 0; longitudehigh = 0;
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.fitness
        
        if locationManager.responds(to: #selector(locationManager.requestWhenInUseAuthorization)) {
            
            locationManager.requestWhenInUseAuthorization()
            
        }
        
    }
    
    func start() {
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            
        }
        
    }
    
    func pause() {
        
        guard let location = locationManager else { return }
        
        location.stopUpdatingLocation()
        
    }
    
    func refresh() {
        
        latitudelow = 0; latitudehigh = 0; longitudelow = 0; longitudehigh = 0;
        
        currentLocation = nil
        
    }
    
    func isEnabled() -> Bool {
        
        if locationManager != nil && CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("locationManager:didFailWithError \(error)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last
        
    }
    
}
