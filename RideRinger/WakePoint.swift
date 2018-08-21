//
//  WakePoint.swift
//  RideRinger
//
//  Created by Skyler Bala on 8/18/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import UserNotifications


enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

var NotificationSounds: [String: UNNotificationSound] = [
    "Firetruck": UNNotificationSound.init(named: "firetruck.wav"),
    "Alarm": UNNotificationSound.init(named: "firetruck.wav")
]

class WakePoint: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var note: String
    var radius: CLLocationDistance
    var eventType: EventType
    var identifier: String
    var notificationSound: UNNotificationSound
    // var active or not var
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    var overlay: MKCircle? {
        let circle = MKCircle(center: coordinate, radius: radius)
        return circle
    }
    
    var region: CLCircularRegion? {
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
        return region
    }
    
    init(coordinate: CLLocationCoordinate2D, note: String, radius: CLLocationDistance, eventType: EventType, identifier: String, notificationSound: UNNotificationSound) {
        self.coordinate = coordinate
        self.note = note
        self.radius = radius
        self.eventType = eventType
        self.identifier = identifier
        self.notificationSound = notificationSound
    }
}
