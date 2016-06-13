//
//  LocationManager.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/7/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    init(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    var onLocationFix: (Coordinate -> Void)?
    var onDeniedLocationUse: (Void -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = 1000
        manager.distanceFilter = 1000
        manager.startUpdatingLocation()
    }
    
    func getPermission() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        } else if status == .Denied {
            if let onDeniedLocationUse = onDeniedLocationUse {
                onDeniedLocationUse()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
//        manager.stopUpdatingLocation()
        let coordinate = Coordinate(location: location)
        if let onLocationFix = onLocationFix {
            onLocationFix(coordinate)
        }
    }
}



























