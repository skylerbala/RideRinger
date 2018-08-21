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
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    private let mapView: MKMapView = MKMapView()
    private let locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private var notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private var addAnnotationGesture: UILongPressGestureRecognizer!
    private var pointIdentifier: Int = 0
    private var updateLocationButtonState: Bool = false
    private var wakePoints: [WakePoint] = [WakePoint]()

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLocationServices()
        configMap()
        configGestures()
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(mapView)
        
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: nil)
        let currentLocationButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-near-me-48"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(updateLocation(sender:)))

        navigationItem.title = "WakePoint"
        navigationItem.setLeftBarButton(addPinButton, animated: true)
        navigationItem.setRightBarButton(currentLocationButton, animated: true)
        
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: topbarHeight)
        ])
    }
    
    @objc private func updateLocation(sender: UITapGestureRecognizer) {
        if updateLocationButtonState == false {
            locationManager.startUpdatingLocation()
            updateLocationButtonState = true
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "icons8-near-me-48")
        }
        else {
            locationManager.stopUpdatingLocation()
            updateLocationButtonState = false
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "icons-near-me-96")

        }
    }
    
    @objc private func pushWakePointForm(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            let addWakePointVC = AddWakePointVC()
            let gesturePoint = sender.location(in: mapView)
            let coordinate = mapView.convert(gesturePoint, toCoordinateFrom: mapView)
            
            addWakePointVC.locationToAdd = coordinate
            addWakePointVC.delegate = self
            navigationController?.pushViewController(addWakePointVC, animated: true)
        }
    }
    
    private func configGestures() {
        addAnnotationGesture = UILongPressGestureRecognizer(target: self, action: #selector(pushWakePointForm(sender:)))
        
        addAnnotationGesture.delegate = self
        
        mapView.addGestureRecognizer(addAnnotationGesture)
    }
    
    private func configMap() {
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
    }
}

extension MapVC: CLLocationManagerDelegate {
    private func configLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        
        if status != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        if currentLocation == nil {
            mapView.zoomToLocation(coordinate: latestLocation.coordinate, spanLatitude: 0.005, spanLongitude: 0.005)
        }
        
        currentLocation = latestLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return setOverlayRenderer(overlay: overlay, lineWidth: 1.0, strokeColor: UIColor.blue, fillColor: UIColor.blue.withAlphaComponent(0.5))
    }
}

extension MapVC: AddWakePointDelegate {
    func addWakePoint(coordinate: CLLocationCoordinate2D, note: String, radius: CLLocationDistance, eventType: EventType, identifier: String, notificationSound: UNNotificationSound) {
        let wakePoint = WakePoint(coordinate: coordinate, note: note, radius: radius, eventType: eventType, identifier: identifier, notificationSound: notificationSound)
        mapView.add(wakePoint.overlay!)
        mapView.addAnnotation(wakePoint)
        wakePoints.append(wakePoint)
        locationManager.startMonitoring(for: wakePoint.region!)
        let content = UNMutableNotificationContent()
        content.title = (wakePoint.title)!
        content.subtitle = (wakePoint.subtitle)!
        content.body = "Alarm"
        content.badge = 1
        content.sound = wakePoint.notificationSound
        
        let trigger = UNLocationNotificationTrigger(region: wakePoint.region!, repeats: true)
        
        let request = UNNotificationRequest(identifier: (wakePoint.region?.identifier)!, content: content, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(request.identifier)")
            }
        })
    }
}
