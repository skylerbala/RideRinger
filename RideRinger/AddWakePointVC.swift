//
//  AddWakePointVC.swift
//  RideRinger
//
//  Created by Skyler Bala on 8/18/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import MapKit
import Eureka
import UserNotifications

protocol AddWakePointDelegate {
    func addWakePoint(coordinate: CLLocationCoordinate2D, note: String, radius: CLLocationDistance, eventType: EventType, identifier: String, notificationSound: UNNotificationSound)
}

class AddWakePointVC: UIViewController, UIGestureRecognizerDelegate {

    var mapView: MKMapView!
    var containerVC: FormViewController! = FormViewController()
    var locationToAdd: CLLocationCoordinate2D!
    var overlay: MKCircle!
    var delegate: AddWakePointDelegate!
    var panRadiusOverlay: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMap()
        setViews()
        configGestures()
        mapView.zoomToLocation(coordinate: locationToAdd, spanLatitude: 0.01, spanLongitude: 0.01)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToAdd
        overlay = MKCircle(center: annotation.coordinate, radius: 100)
        
        mapView.add(overlay)
        mapView.addAnnotation(annotation)
        
    }
    
    private func configGestures() {
        panRadiusOverlay = UIPanGestureRecognizer(target: self, action: #selector(radiusOverlayResize(_:)))
        panRadiusOverlay.delegate = self
        mapView.addGestureRecognizer(panRadiusOverlay)
    }
    
    @objc func radiusOverlayResize(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: mapView)
        print(point)
        let distance = sqrt(point.x*point.x + point.y*point.y)
        
        let oldRadius = overlay.radius
        self.mapView.remove(self.overlay)
        self.overlay = MKCircle.init(center: self.locationToAdd, radius: oldRadius + Double(distance))
        self.mapView.add(self.overlay)
    }
    
    
    private func setViews() {
        view.addSubview(mapView)
        view.addSubview(containerVC.view)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(confirmAddWakePoint))
        navigationItem.title = "Add WakePoint"
        navigationItem.setRightBarButton(addButton, animated: true)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.5),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: topbarHeight),
        ])
        
        containerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerVC.view.topAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
        
        containerVC.form +++
            Section("Section1")
                <<< SliderRow(){
                    $0.title = "Radius(mi)"
                    $0.value = 100
                    $0.minimumValue = 100
                    $0.maximumValue = 1000
                    $0.add(rule: RuleRequired())
                    $0.add(rule: RuleGreaterThan(min: 100, msg: "Must be at least 100m"))
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                    $0.tag = "radius"
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    self.mapView.remove(self.overlay)
                    self.overlay = MKCircle.init(center: self.locationToAdd, radius: Double(row.value!))
                    self.mapView.add(self.overlay)
                }
                <<< TextAreaRow(){
                    $0.title = "Note"
                    $0.placeholder = "Enter note here"
                    $0.add(rule: RuleMaxLength(maxLength: 100, msg: "Too long"))
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                    $0.tag = "note"
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.backgroundColor = UIColor.red
                        }
                }
                <<< ActionSheetRow<String>(){
                    $0.title = "Sound"
                    $0.options = Array(NotificationSounds.keys)
                    $0.value = NotificationSounds.keys.first
                    $0.tag = "notificationSound"
                }
                <<< CheckRow(){
                    $0.title = "Notify on Entry"
                    $0.value = true
                    $0.tag = "onEntry"
                }
                <<< CheckRow(){
                    $0.title = "Notify on Exit"
                    $0.value = false
                    $0.tag = "onExit"
                }
    }
    
    @objc private func confirmAddWakePoint() {
        let values = containerVC.form.values()
        let uuid = NSUUID().uuidString
        let notifString = values["notificationSound"] as! String
        let notificationSound = NotificationSounds[notifString] as! UNNotificationSound
        let note = values["note"] as! String
        let radius = Double(values["radius"] as! Int) as! CLLocationDistance
        
        
        // entry point hardcoded
        delegate?.addWakePoint(coordinate: locationToAdd, note: note, radius: radius, eventType: .onEntry, identifier: uuid, notificationSound: notificationSound)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func configMap() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = false
    }
    
    
}

extension AddWakePointVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return setOverlayRenderer(overlay: overlay, lineWidth: 1.0, strokeColor: UIColor.blue, fillColor: UIColor.blue.withAlphaComponent(0.5))
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = otherGestureRecognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let point = MKMapPointForCoordinate(locationCoordinate)
        let mapRect = MKMapRectMake(point.x, point.y, 0, 0)
        
        for circle in mapView.overlays {
            if circle.intersects!(mapRect) {
                return true
            }
        }
        
        return false
        
    }
}
