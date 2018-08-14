//
//  ViewController.swift
//  Walking
//
//  Created by Dennis Schmidt on 13/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit
import MapKit

class MainView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var localizeUserButton: UIButton!
    
    var locationThing: LocationThing!
    
    var userHasBeenLocalized: Bool = false
    var updateRegion: Bool = true
    
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
        
        let mapHeadlineLabel = EdgeInsetLabel()
        mapHeadlineLabel.textInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        mapHeadlineLabel.frame = CGRect(x: 20, y: 30, width: screenSize.width - 40, height: 40)
        mapHeadlineLabel.textColor = UIColor.white
        mapHeadlineLabel.backgroundColor = UIColor.ourDarkGreen
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
        
        mapView.frame = CGRect(x: 20, y: 70, width: screenSize.width - 40, height: 300)

        let pathMap = UIBezierPath(roundedRect: mapView.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height:  8))
        let maskLayerMap = CAShapeLayer()
        maskLayerMap.path = pathMap.cgPath
        mapView.layer.mask = maskLayerMap
    
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
        locationThing.initialize()
        
        localizeUser(self)
        
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
        
        //mapView.frame = CGRect(x: 20, y: 100, width: size.width - 40, height: size.height * 0.6)
        
        localizeUserButton.frame = CGRect(x: size.width - 60 - 20 - self.view.safeAreaInsets.right, y: size.height - self.view.safeAreaInsets.bottom - 60 - 20, width: 60, height: 60)

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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
//        if annotation is MKUserLocation { return nil }
//
//        if annotation is PlaceMark {
//
//            let identifier = "CRM"
//
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//            if annotationView == nil {
//
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView!.canShowCallout = true
//
//            } else {
//
//                annotationView!.annotation = annotation
//
//            }
//
//            annotationView!.image = UIImage(named: "Map_location_50_3a7bd5")
//
//            configureDetailView(annotationView: annotationView!)
//
//            return annotationView
//
//        }
        
        return nil
        
    }
    
    func configureDetailView(annotationView: MKAnnotationView) {
        
//        guard let customer = (annotationView.annotation as! PlaceMark).customer else { return }
//        
//        let snapshotView = UIView()
//        let views = ["snapshotView": snapshotView]
//        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(300)]", options: [], metrics: nil, views: views))
//        
//        var y: CGFloat = 8
//        
//        if let _ = customer.companyImage {
//            
//            let imageView = UIImageView(frame: CGRect(x: ((300) / 2) - 70, y: y, width: 140, height: 140))
//            snapshotView.addSubview(imageView)
//            
//            DispatchQueue.main.async {
//                
//                imageView.image = customer.companyImage
//                imageView.contentMode = .scaleAspectFill
//                imageView.layer.cornerRadius = imageView.frame.height / 2
//                imageView.clipsToBounds = true
//                imageView.layer.borderWidth = 2
//                imageView.layer.borderColor = UIColor.ourYellow.cgColor
//                
//            }
//            
//            y += 140 + 8
//            
//        }
//        
//        if customer.companyName.count > 0 {
//            
//            let nameLabel = UILabel(frame: CGRect(x: 0, y: y, width: 300, height: 40))
//            nameLabel.font = UIFont.init(name: "Helvetica neue", size: 26)
//            nameLabel.textColor = .darkGray
//            nameLabel.textAlignment = .center
//            nameLabel.text = customer.companyName
//            snapshotView.addSubview(nameLabel)
//            
//            y += 40 + 10
//            
//        }
//        
//        let actionBackgroundLabel = UILabel(frame: CGRect(x: 0, y: y, width: 300, height: 120))
//        actionBackgroundLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
//        snapshotView.addSubview(actionBackgroundLabel)
//        
//        let loadImageView = UIImageView(frame: CGRect(x: 30, y: y + 30, width: 60, height: 60))
//        loadImageView.image = UIImage(named: "Calendar_contact")
//        loadImageView.contentMode = .scaleAspectFill
//        snapshotView.addSubview(loadImageView)
//        
//        let customerButton = CustomerLoadButton(frame: loadImageView.frame)
//        customerButton.customer = customer
//        customerButton.mapView = self
//        snapshotView.addSubview(customerButton)
//        
//        let callImageView = UIImageView(frame: CGRect(x: 120, y: y + 30, width: 60, height: 60))
//        callImageView.image = UIImage(named: "Calendar_phone")
//        callImageView.contentMode = .scaleAspectFill
//        snapshotView.addSubview(callImageView)
//        
//        let callButton = CustomerCallButton(frame: callImageView.frame)
//        callButton.number = customer.contactCellPhone
//        snapshotView.addSubview(callButton)
//        
//        let directionsImageView = UIImageView(frame: CGRect(x: 210, y: y + 30, width: 60, height: 60))
//        directionsImageView.image = UIImage(named: "Calendar_directions")
//        directionsImageView.contentMode = .scaleAspectFill
//        snapshotView.addSubview(directionsImageView)
//        
//        let directionsButton = CustomerDirectionsButton(frame: directionsImageView.frame)
//        directionsButton.customer = customer
//        directionsButton.mapView = self
//        snapshotView.addSubview(directionsButton)
//        
//        y += 120 + 8
//        
//        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(\(y))]", options: [], metrics: nil, views: views))
//        
//        annotationView.detailCalloutAccessoryView = snapshotView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        performSegue(withIdentifier: "showCustomerDetailView", sender: view)
        
    }
    
    @IBAction func localizeUser(_ sender: Any) {
        
        updateRegion = false
        
        localizeUserButton.isHidden = true
        
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
}
