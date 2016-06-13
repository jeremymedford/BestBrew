//
//  CoffeeShopAnnotation.swift
//  JMSampleFourSquare
//
//  Created by Jeremy Medford on 6/9/16.
//  Copyright © 2016 Vintage Robot. All rights reserved.
//

import Foundation
import MapKit


class CoffeeShopAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let venueId: String?
    
    init(coordinate: CLLocationCoordinate2D, venueId: String, title: String?, address: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = address
        self.venueId = venueId
        super.init()
    }

}