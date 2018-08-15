//
//  ViewController.swift
//  Walking
//
//  Created by Dennis Schmidt on 13/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit
import MapKit
import SQLite3
import CoreLocation

class MainView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var localizeUserButton: UIButton!
    @IBOutlet weak var dashboardLabel: UILabel!
    @IBOutlet weak var trackingLabel: UILabel!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var journeys = [Journey]()
    var locations = [LocationNow]()
    
    var locationThing: LocationThing!
    
    var userHasBeenLocalized: Bool = false
    var updateRegion: Bool = true
    
    var journey: Journey!
    
    var mapHeadlineLabel: EdgeInsetLabel!
    
    var parentView: AppDelegate!
    
    //MARK: Initialize
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        print("awakeFromNib")
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        mapHeadlineLabel = EdgeInsetLabel()
        mapHeadlineLabel.textInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        mapHeadlineLabel.frame = CGRect(x: 20, y: 30, width: screenSize.width - 40, height: 40)
        mapHeadlineLabel.textColor = UIColor.ourDarkPurple
        mapHeadlineLabel.backgroundColor = UIColor.ourDarkBrown
        mapHeadlineLabel.font = UIFont.init(name: "Helvetica neue", size: 20)
        mapHeadlineLabel.layer.masksToBounds = true
        mapHeadlineLabel.textAlignment = .center
        mapHeadlineLabel.text = String(format: "WALKING")
        
        let path = UIBezierPath(roundedRect: mapHeadlineLabel.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize(width: 8, height:  8))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        mapHeadlineLabel.layer.mask = maskLayer
        self.view.addSubview(mapHeadlineLabel)
        
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.frame = CGRect(x: 20, y: 70, width: screenSize.width - 40, height: 240)

        let pathMap = UIBezierPath(roundedRect: mapView.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height:  8))
        let maskLayerMap = CAShapeLayer()
        maskLayerMap.path = pathMap.cgPath
        mapView.layer.mask = maskLayerMap
        
        trackingSwitch.addTarget(self, action: #selector(trackingSwitchChange(sender:)), for: .touchUpInside)
        trackingSwitch.isOn = false
        
        currentLocationLabel.numberOfLines = 2
        
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor.ourDarkBrown.cgColor
        tableView.backgroundColor = UIColor.ourDarkBrown
        
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
        
        locationThing = LocationThing()
        locationThing.parentView = self
        locationThing.initialize()
        
        localizeUser(self)
        
        loadJourneys()
        loadPositions()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        
    }
    
    //MARK: Prepare layout
    
    func prepareLayout(to size: CGSize) {
        
        print("prepareLayout")
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        
        self.mapHeadlineLabel.frame = CGRect(x: 20, y: self.view.safeAreaInsets.top / 2 + 30, width: self.mapHeadlineLabel.bounds.width, height: self.mapHeadlineLabel.bounds.height)
        self.mapView.frame = CGRect(x: 20, y: self.view.safeAreaInsets.top / 2 + 70, width: self.mapView.bounds.width, height: self.mapView.bounds.height)
        
        localizeUserButton.frame = CGRect(x: size.width - 60 - 20, y: size.height - self.view.safeAreaInsets.bottom - 60 - 20, width: 60, height: 60)
        localizeUserButton.backgroundColor = UIColor.ourDarkBrown
        localizeUserButton.setRadiusWithShadow()
        
        let dashboardLabelWidth = localizeUserButton.frame.origin.x - 20 - 20
        
        dashboardLabel.frame = CGRect(x: 20, y: size.height - self.view.safeAreaInsets.bottom - 140 - 20, width: dashboardLabelWidth, height: 140)
        dashboardLabel.backgroundColor = UIColor.ourDarkBrown
        dashboardLabel.layer.cornerRadius = 8
        dashboardLabel.layer.masksToBounds = true
        dashboardLabel.layer.borderWidth = 1
        dashboardLabel.layer.borderColor = UIColor.ourDarkPurple.cgColor
        
        let trackingLabelY = dashboardLabel.frame.origin.y + dashboardLabel.bounds.height - 8 - 31
        let trackingLabelWidth = dashboardLabel.bounds.width - 16
        
        trackingLabel.frame = CGRect(x: 28, y: trackingLabelY, width: trackingLabelWidth, height: 31)
        trackingLabel.textColor = UIColor.ourDarkPurple
        
        let trackingSwitchX = dashboardLabel.frame.origin.x + dashboardLabel.bounds.width - 49 - 12
        
        trackingSwitch.frame = CGRect(x: trackingSwitchX, y: trackingLabelY, width: 49, height: 31)
        trackingSwitch.onTintColor = UIColor.ourDarkPurple
        trackingSwitch.tintColor = UIColor.ourDarkPurple
        
        let currentLocationLabelY = trackingLabelY - 60
        
        currentLocationLabel.frame = CGRect(x: 28, y: currentLocationLabelY, width: trackingLabelWidth, height: 60)
        currentLocationLabel.textColor = UIColor.ourDarkPurple

        let distanceLabelY = currentLocationLabelY - 30
        
        distanceLabel.frame = CGRect(x: 28, y: distanceLabelY, width: trackingLabelWidth, height: 31)
        distanceLabel.textColor = UIColor.ourDarkPurple
        
        UIView.animate(withDuration: 1.0, animations: {

            if self.journeys.count > 0 {
                
                self.tableView.alpha = 1
                
            } else {
                
                self.tableView.alpha = 0
                
            }
            
        }, completion: { success in
            
            if self.journeys.count > 0 {
                
                self.tableView.isHidden = false
                
            } else {
                
                self.tableView.isHidden = true
                
            }
            
            self.tableView.frame = CGRect(x: 20, y: self.mapView.frame.origin.y + self.mapView.bounds.height + 16, width: size.width - 40, height: CGFloat(self.calculateRowHeight() * 74))
            self.tableView.reloadData()
            
        })
        
        if size.width == 667 || size.width == 736 || size.width == 812 {
            
            self.mapHeadlineLabel.frame = CGRect(x: self.view.safeAreaInsets.left / 2 + 20, y: self.mapHeadlineLabel.frame.origin.y, width: self.mapHeadlineLabel.bounds.width, height: self.mapHeadlineLabel.bounds.height)
            self.mapView.frame = CGRect(x: self.view.safeAreaInsets.left / 2 + 20, y: self.mapView.frame.origin.y, width: self.mapView.bounds.width, height: self.mapView.bounds.height)
            
            let x = self.mapView.frame.origin.x + self.mapView.bounds.width + 20
            let width = size.width - x - 20
            
            dashboardLabel.frame = CGRect(x: x, y: self.mapHeadlineLabel.frame.origin.y, width: width, height: 140)
            
            let trackingLabelY = dashboardLabel.frame.origin.y + dashboardLabel.bounds.height - 8 - 31
            let trackingLabelWidth = dashboardLabel.bounds.width - 16
            
            trackingLabel.frame = CGRect(x: x + 8, y: trackingLabelY, width: trackingLabelWidth, height: 31)
            
            let trackingSwitchX = dashboardLabel.frame.origin.x + dashboardLabel.bounds.width - 49 - 12
            
            trackingSwitch.frame = CGRect(x: trackingSwitchX, y: trackingLabelY, width: 49, height: 31)
            
            let currentLocationLabelY = trackingLabelY - 60
            
            currentLocationLabel.frame = CGRect(x: x + 8, y: currentLocationLabelY, width: trackingLabelWidth, height: 60)
            
            let distanceLabelY = currentLocationLabelY - 30
            
            distanceLabel.frame = CGRect(x: x + 8, y: distanceLabelY, width: trackingLabelWidth, height: 31)
            
            UIView.animate(withDuration: 1.0, animations: {
                
                if self.journeys.count > 0 {
                    
                    self.tableView.alpha = 1
                    
                } else {
                    
                    self.tableView.alpha = 0
                    
                }
                
            }, completion: { success in
                
                if self.journeys.count > 0 {
                    
                    self.tableView.isHidden = false
                    
                } else {
                    
                    self.tableView.isHidden = true
                    
                }
                
                var factor = CGFloat(self.calculateRowHeight())
                    
                if factor > 2 {
                    
                    factor = 1
                    
                }
                
                self.tableView.frame = CGRect(x: x, y: self.dashboardLabel.frame.origin.y + self.dashboardLabel.bounds.height + 16, width: width, height: factor * 74)
                self.tableView.reloadData()
                
            })
            
        }
        
    }
    
    //MARK: Load data
    
    func loadJourneys() {
        
        print("loadJourneys")
        
        tableView.isHidden = true
        
        self.journeys.removeAll()
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(self.parentView.db, "SELECT * FROM journey", -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                let journey = Journey(title: "", starting: Date(), ending: Date(), note: "")
                
                journey.id = String(Int(sqlite3_column_int(stmt, 0)))
                
                if let queryResultCol = sqlite3_column_text(stmt, 1) {
                    
                    journey.title = String(cString: queryResultCol)
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 2) {
                    
                    journey.starting = self.parentView.dateFormatter.date(from: String(cString: queryResultCol))
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 3) {
                    
                    journey.ending = self.parentView.dateFormatter.date(from: String(cString: queryResultCol))
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 4) {
                    
                    journey.distance = Double(String(cString: queryResultCol))!
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 5) {
                    
                    journey.note = String(cString: queryResultCol)
                    
                }
                
                journeys.append(journey)
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        if journeys.count > 0 {
            
            tableView.isHidden = false
            tableView.reloadData()
            
        }
        
        print("Journeys done: \(self.journeys.count)")
        
    }
    
    func loadPositions() {
        
        print("loadPositions")
        
        self.locations.removeAll()
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(self.parentView.db, "SELECT * FROM position", -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                let location = LocationNow(journeyID: "", latitude: 0, longitude: 0)
                
                location.id = String(Int(sqlite3_column_int(stmt, 0)))
                
                if let queryResultCol = sqlite3_column_text(stmt, 1) {
                    
                    location.journeyID = String(cString: queryResultCol)
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 2) {
                    
                    location.latitude = Double(String(cString: queryResultCol))!
                    
                }
                
                if let queryResultCol = sqlite3_column_text(stmt, 3) {
                    
                    location.longitude = Double(String(cString: queryResultCol))!

                }
                
                locations.append(location)
                
            }
            
        }
        
        sqlite3_finalize(stmt)
        
        print("Locations done: \(self.locations.count)")
        
    }
    
    //MARK: Map
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !userHasBeenLocalized {
            
            localizeUser(self)
            
            userHasBeenLocalized = true
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if updateRegion {
            
            localizeUserButton.isHidden = false
            
        } else {
            
            updateRegion = true
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.ourPolyline
        renderer.lineWidth = 4.0
        
        return renderer
        
    }

    @IBAction func localizeUser(_ sender: Any) {
        
        updateRegion = false
        
        localizeUserButton.isHidden = true
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    @objc func trackingSwitchChange(sender: UISwitch) {
        
        if sender.isOn {
            
            self.journey = Journey(title: "Untitled", starting: Date(), ending: Date(), note: "Empty")
            
            if self.parentView.databaseInsert(object: journey) {
                
                self.journeys.append(self.journey)
                
                for overlay in self.mapView.overlays {
                    
                    self.mapView.remove(overlay)
                    
                }
                
                self.locationThing.start()
                
                self.mapView.showsUserLocation = true
                
                self.currentLocationLabel.text = "Current location initiating!"
                
            }
            
        } else {
            
            if self.parentView.databaseUpdate(object: journey) {
                
                self.locationThing.pause()
                
                self.mapView.showsUserLocation = false
                
                self.currentLocationLabel.text = "Current location not tracking!"
                self.distanceLabel.text = "Distance 0 Meter"
                
            }
            
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        prepareLayout(to: CGSize(width: screenSize.width, height: UIScreen.main.bounds.height))
        
    }
    
    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return journeys.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 74
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        for view in cell.contentView.subviews {
            
            view.removeFromSuperview()
            
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.ourTableViewBackground
        
        let journey = journeys[indexPath.row]
        
        let startLabel = UILabel(frame: CGRect(x: 6, y: 8, width: tableView.bounds.width - 12 - 58, height: 30))
        startLabel.font = UIFont.init(name: "HelveticaNeue-Medium", size: 12)
        startLabel.textColor = UIColor.ourDarkPurple
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "da_DK")
        f.dateFormat = "d. MMMM yyyy HH:mm"
        
        var endingDate: String = "NA"

        if let ending = journey.ending {
        
            endingDate = "\(f.string(from: ending))"
            
        }
        
        startLabel.text = "\(f.string(from: journey.starting)) - \(endingDate))"
        cell.contentView.addSubview(startLabel)
        
        let distanceLabel = UILabel(frame: CGRect(x: 6, y: 46, width: tableView.bounds.width - 12 - 58, height: 20))
        distanceLabel.font = UIFont.init(name: "HelveticaNeue-Medium", size: 12)
        distanceLabel.textColor = .black
        distanceLabel.text = "Distance \(journey.distance.roundToDecimal(0)) Meters"
        cell.contentView.addSubview(distanceLabel)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if trackingSwitch.isOn {
            
            if self.parentView.databaseUpdate(object: self.journey) {
                
                self.locationThing.pause()
                
                self.mapView.showsUserLocation = false
                
                self.currentLocationLabel.text = "Current location not tracking!"
                self.distanceLabel.text = "Distance 0 Meter"
                
            }
            
        }
        
        for overlay in self.mapView.overlays {
            
            self.mapView.remove(overlay)
            
        }
        
        let journey = journeys[indexPath.row]
        
        let locations = self.locations.filter { $0.journeyID == journey.id }
        
        var points = [CLLocationCoordinate2D]()
        
        for location in locations {
            
            let point = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            
            points.append(point)
            
        }

        let geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        
        self.mapView.add(geodesic)

        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            
            guard let first = points.first else { return }
            
            let span = MKCoordinateSpanMake(0.0025, 0.0025)
            let region = MKCoordinateRegion(center: first, span: span)
            self.mapView.setRegion(region, animated: true)
            
        })

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: nil, message: "Would you like to delete this tracking?", preferredStyle: .alert)
            
            let noAction = UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
                
                return
                
            })
            
            let yesAction = UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                
                let journey = self.journeys[indexPath.row]
                
                if self.parentView.databaseQuery(query: "DELETE FROM journey WHERE id = \(journey.id!)") {
                    
                    self.journeys = self.journeys.filter { $0.id != journey.id }

                    let locations = self.locations.filter { $0.journeyID == journey.id }
                    
                    for location in locations {
                
                        if self.parentView.databaseQuery(query: "DELETE FROM position WHERE id = \(location.id!)") {
                            
                            self.locations = self.locations.filter { $0.id != location.id }
                            
                        }
                        
                    }

                }
                
                let screenSize: CGRect = UIScreen.main.bounds
                
                self.prepareLayout(to: CGSize(width: screenSize.width, height: UIScreen.main.bounds.height))

            })
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            self.present(alertController, animated: true)
            
        }

    }
    
    func calculateRowHeight() -> Int {
        
        var heightFactor: Int = 0
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        if journeys.count > 3 {

            if screenSize.height == 667 {
                
                heightFactor = 2
                
            } else {
                
                heightFactor = 3
                
            }
            
        } else {
            
            if screenSize.height == 667 {
                
                if journeys.count > 2 {
                    
                    heightFactor = 2
                    
                } else {
                    
                    heightFactor = journeys.count
                    
                }
                
            } else {
                
                heightFactor = journeys.count
                
            }
            
        }
        
        return heightFactor
        
    }
    
}

extension UIView {
    
    func setRadiusWithShadow(_ radius: CGFloat? = nil) {
        
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        
    }
    
}
