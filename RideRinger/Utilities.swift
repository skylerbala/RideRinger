//
//  Utilities.swift
//  RideRinger
//
//  Created by Skyler Bala on 8/18/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    func zoomToLocation(coordinate: CLLocationCoordinate2D, spanLatitude: CLLocationDegrees, spanLongitude: CLLocationDegrees) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(spanLatitude, spanLongitude)
        let location = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        setRegion(region, animated: true)
    }
}

extension UIViewController {
    
    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

extension MKMapViewDelegate {
    func setOverlayRenderer(overlay: MKOverlay, lineWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = lineWidth
            circleRenderer.strokeColor = strokeColor
            circleRenderer.fillColor = fillColor
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MKCircle {
    convenience init(center: CLLocationCoordinate2D, radiusMiles: CLLocationDistance) {
        self.init(center: center, radius: radiusMiles*1609.34)
    }
}
