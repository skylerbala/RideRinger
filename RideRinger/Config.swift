//
//  Config.swift
//  RideRinger
//
//  Created by Skyler Bala on 8/18/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// MARK: Helper Extensions
extension ViewController  {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func zoomToUserLocation() {  
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        setRegion(region, animated: true)
    }
}

