//
//  ViewController.swift
//  RideRinger
//
//  Created by Skyler Bala on 8/17/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    private let mapView: MKMapView = MKMapView()
    private let locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D!
    private var addAnnotationGesture: UITapGestureRecognizer!
    
    // Done Once
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        configureGestures()
    }
    
    // Done everytime the view loads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureGestures() {
        addAnnotationGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotation(sender:)))
        addAnnotationGesture.delegate = self
        
        mapView.addGestureRecognizer(addAnnotationGesture)
    }
    
    private func setUpMapView() {
        let leftMargin: CGFloat = 10
        let topMargin: CGFloat = 60
        let mapWidth: CGFloat = view.frame.size.width-20
        let mapHeight: CGFloat = 300
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        view.addSubview(mapView)
    }
    
    private func configureUNCenter() {
        
        
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    private func startUpdatingLocation() {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private func zoomToLocation(with coordinate: CLLocationCoordinate2D) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    private func pushNotification(with annotation: MKPointAnnotation) {
        //Trigger
        let region = CLCircularRegion(center: annotation.coordinate, radius: 5000, identifier: "newPoint")
        region.notifyOnEntry = true
        region.notifyOnExit = false
    
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        print(trigger.region)
        
        //Content
        let content = UNMutableNotificationContent()
        content.title = "Wake up bitch"
        content.subtitle = "wake upppppppp"
        content.body = "really wake up"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "newPoint", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
            else {
                
            }
        }
    }
    
    @objc private func addAnnotation(sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let locationCoordinates = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoordinates
        annotation.title = "Gang"
        annotation.subtitle = "Super gang store buhh"
        
        pushNotification(with: annotation)
        
        mapView.addAnnotation(annotation)
    }

}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        if currentLocation == nil {
            zoomToLocation(with: latestLocation.coordinate)
        }
        
        currentLocation = latestLocation.coordinate
        
        print("user latitude = \(currentLocation.latitude)")
        print("user longitude = \(currentLocation.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        <#code#>
    }
}

//shuttlesnooze, rideringer, sleeptrain, trainsleeper

