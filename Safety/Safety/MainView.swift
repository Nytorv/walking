//
//  ViewController.swift
//  Safety
//
//  Created by Dennis Schmidt on 16/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainView: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    var positions = [Position]()
    var points = [CLLocationCoordinate2D]()

    //MARK: Initialize
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        print("awakeFromNib")
        
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        mapView.frame = CGRect(x: 20, y: 20, width: screenSize.width - 40, height: 200)
        mapView.layer.borderWidth = 1
        mapView.layer.cornerRadius = 8
        mapView.layer.borderColor = UIColor.ourDarkBrown.cgColor

        tableView.frame = CGRect(x: 20, y: 240, width: screenSize.width - 40, height: CGFloat(self.calculateRowHeight() * 46))
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor.ourDarkBrown.cgColor
        tableView.backgroundColor = UIColor.ourDarkBrown
        
        trackingSwitch.frame = CGRect(x: mapView.frame.origin.x + mapView.bounds.width - 49 - 16, y: mapView.frame.origin.y + mapView.bounds.height - 31 - 16, width: 49, height: 31)
        trackingSwitch.onTintColor = UIColor.ourDarkBrown
        trackingSwitch.tintColor = UIColor.ourDarkBrown
        trackingSwitch.addTarget(self, action: #selector(trackingSwitchChange(sender:)), for: .touchUpInside)
        trackingSwitch.isOn = true

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.fitness
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        tableView.delegate = self

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        print("viewWillTransition")
        
        prepareLayout(to: CGSize(width: size.width, height: size.height))
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        print("viewWillLayoutSubviews")
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        prepareLayout(to: CGSize(width: screenSize.width, height: UIScreen.main.bounds.height))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        
    }
    
    //MARK: Prepare layout
    
    func prepareLayout(to size: CGSize) {
        
        print("prepareLayout")
        
        mapView.frame = CGRect(x: 20, y: 20, width: size.width - 40, height: 200)
        trackingSwitch.frame = CGRect(x: mapView.frame.origin.x + mapView.bounds.width - 49 - 16, y: mapView.frame.origin.y + mapView.bounds.height - 31 - 16, width: 49, height: 31)
        tableView.frame = CGRect(x: 20, y: 240, width: size.width - 40, height: CGFloat(self.calculateRowHeight() * 46))
        tableView.reloadData()
        
    }
    
    //MARK: Location manager
    
    func start() {
        
        if locationManager != nil && CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager?.startUpdatingHeading()
            locationManager?.startUpdatingLocation()
            
        }
        
    }
    
    func stop() {
        
        guard let location = locationManager else { return }
        
        location.stopMonitoringSignificantLocationChanges()
        location.stopUpdatingHeading()
        location.stopUpdatingLocation()
        
        currentLocation = nil
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        start()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("locationManager:didFailWithError \(error)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last
        
        guard let currentLocation = currentLocation else { return }

        let latitude = currentLocation.coordinate.latitude.roundToDecimal(5)
        let longitude = currentLocation.coordinate.longitude.roundToDecimal(5)
        
        positions.append(Position(latitude: latitude, longitude: longitude, backgroundText: ""))
        points.append(CLLocationCoordinate2DMake(latitude, longitude))

        mapView.add(MKPolyline(coordinates: points, count: points.count))
        
        tableView.reloadData()
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            
            guard let first = self.points.first else { return }
            
            let span = MKCoordinateSpanMake(0.0500, 0.0500)
            let region = MKCoordinateRegion(center: first, span: span)
            self.mapView.setRegion(region, animated: true)
            
        })
        
    }
    
    //MARK: Background
    
    func performFetchWithCompletionHandler(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        positions.append(Position(latitude: 0, longitude: 0, backgroundText: "BACKGROUND"))
        
        stop() ; start()
        
        completionHandler(.newData)
        
    }
    
    //MARK: Tracking
    
    @objc func trackingSwitchChange(sender: UISwitch) {
        
        if sender.isOn {

            start()
            
            self.mapView.showsUserLocation = true
            
        } else {
            
            stop()
            
            self.mapView.showsUserLocation = false
            
        }
        
    }
    
    //MARK: Map view
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.ourPolyline
        renderer.lineWidth = 4.0
        
        return renderer
        
    }
    
    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return positions.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 46
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        for view in cell.contentView.subviews {
            
            view.removeFromSuperview()
            
        }
        
        cell.selectionStyle = .none
        
        let position = positions[indexPath.row]
        
        let positionLabel = UILabel(frame: CGRect(x: 6, y: 8, width: tableView.bounds.width - 12 - 58, height: 30))
        positionLabel.font = UIFont.init(name: "HelveticaNeue-Medium", size: 16)
        positionLabel.textColor = .black
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "da_DK")
        f.dateFormat = "yyyy.MM.dd HH:mm:SSSS"
        
        positionLabel.text = "\(f.string(from: position.date)), (\(position.latitude)),(\(position.longitude)), \(position.backgroundText)"
        cell.contentView.addSubview(positionLabel)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        tableView.frame = CGRect(x: 20, y: 240, width: screenSize.width - 40, height: CGFloat(self.calculateRowHeight() * 46))
        
        return cell
        
    }
    
    func calculateRowHeight() -> Int {
        
        var heightFactor: Int = 0
        
        if positions.count > 3 {
            
            heightFactor = 3

        } else {
            
            heightFactor = positions.count

        }
        
        return heightFactor
        
    }
    
}

extension Double {
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        
        let multiplier = pow(10, Double(fractionDigits))
        
        return Darwin.round(self * multiplier) / multiplier
        
    }
    
}
