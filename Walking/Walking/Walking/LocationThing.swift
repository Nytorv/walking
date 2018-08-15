//
//  LocationThing.swift
//  Likesharing
//
//  Created by Dennis Schmidt on 18/12/2016.
//  Copyright © 2016 Nytorv. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationThing: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var latitudelow: Double!
    var latitudehigh: Double!
    var longitudelow: Double!
    var longitudehigh: Double!
    
    var parentView: MainView!
    
    func initialize() {
        
        latitudelow = 0; latitudehigh = 0; longitudelow = 0; longitudehigh = 0;
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.fitness
        locationManager.requestAlwaysAuthorization()
        
    }
    
    func start() {
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    func pause() {
        
        guard let location = locationManager else { return }
        
        location.stopUpdatingLocation()
        
    }
    
    func refresh() {
        
        latitudelow = 0; latitudehigh = 0; longitudelow = 0; longitudehigh = 0;
        
        currentLocation = nil
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()

        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("locationManager:didFailWithError \(error)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locations.last else { return }
        guard let journey = self.parentView.journey else { return }
        
        let tlatitude = currentLocation.coordinate.latitude.roundToDecimal(5)
        let tlongitude = currentLocation.coordinate.longitude.roundToDecimal(5)
        
        let locationNow = LocationNow(journeyID: journey.id, latitude: tlatitude, longitude: tlongitude)
        
        if self.parentView.parentView.databaseInsert(object: locationNow) {
            
            if self.parentView.locations.count > 0 {
                
                if let last = self.parentView.locations.last {
                    
                    let previous = CLLocation(latitude: last.latitude, longitude: last.longitude)
                    
                    self.parentView.journey.distance += currentLocation.distance(from: previous)
                    
                    self.parentView.distanceLabel.text = "Distance \(self.parentView.journey.distance.roundToDecimal(0)) Meter"
                    
                }
                
            }
            
            self.parentView.locations.append(locationNow)
            
            DispatchQueue.main.async {
                
                guard let last = self.parentView.locations.last else { return }
                
                self.parentView.currentLocationLabel.text = "Current location\n(\(last.latitude)),(\(last.longitude))"
                
                var points = [CLLocationCoordinate2D]()
                
                for location in self.parentView.locations {
                    
                    if location.journeyID == self.parentView.journey.id {
                        
                        let point = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                        
                        points.append(point)
                        
                    }
                    
                }
                
                let geodesic = MKPolyline(coordinates: points, count: points.count)
                
                self.parentView.mapView.add(geodesic)
                
                UIView.animate(withDuration: 1.5, animations: { () -> Void in
                    
                    guard let first = points.first else { return }
                    
                    let span = MKCoordinateSpanMake(0.0025, 0.0025)
                    let region = MKCoordinateRegion(center: first, span: span)
                    self.parentView.mapView.setRegion(region, animated: true)
                    
                })
                
            }
            
        }

    }

}

extension Double {
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        
        let multiplier = pow(10, Double(fractionDigits))
    
        return Darwin.round(self * multiplier) / multiplier
        
    }
    
}
