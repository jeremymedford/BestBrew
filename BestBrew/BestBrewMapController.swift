//
//  BestBrewMapController
//  BestBrew
//
//  Created by Jeremy Medford on 6/12/16.
//  Copyright © 2016 JM Inc. All rights reserved.
//

import UIKit
import MapKit

class BestBrewMapController: UIViewController, MKMapViewDelegate {

    var coordinate: Coordinate?
    let foursquareClient = FoursquareClient(clientID: "WCUA33DB0DCX5W1YSCBVEVKEZ24PJ3DN3AV14XZGOB4KNDMM", clientSecret: "N3EMAXQZMEXECDQMBY4YBGXHNU1LHVMHW1RYMNGYS25RVJTI")
    let manager = LocationManager()
    
    @IBOutlet weak var mapView: MKMapView?
    
    var venues: [Venue] = [] {
        didSet {
            addAnnotations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        manager.getPermission()
        manager.onLocationFix = { [weak self] coordinate in
            
            self?.coordinate = coordinate
            self?.updateMapCenter()
            self?.foursquareClient.fetchCoffeeShopsFor(coordinate, category: .Coffee, limit: 15) { result in
                switch result {
                case .Success(let venues):
                    print("Success returning venues")
                    self?.venues = venues
                case .Failure(let error):
                    print(error)
                    self?.displayFetchError(error as NSError)
                }
            }
        }
        
        manager.onDeniedLocationUse = { [ weak self] in
            
            self?.displayLocationUseWarning()
            
        }
    }

    @IBAction func refreshVenues(sender: AnyObject) {
        if let coordinate = self.coordinate {
            self.foursquareClient.fetchCoffeeShopsFor(coordinate, category: .Coffee, limit: 15) { result in
                switch result {
                case .Success(let venues):
                    print("\(venues)")
                    self.venues = venues
                case .Failure(let error):
                    print(error)
                    self.displayFetchError(error as NSError)
                }
            }
        }
    }
    
    func displayLocationUseWarning() {
        if presentedViewController == nil {
            let alertController = UIAlertController(title: "Wait!", message: "The app is much more useful when it can automatically share coffee shops nearby. Consider changing the setting in the Settings App.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (UIAlertAction) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
            
            alertController.addAction(okAction)
            alertController.addAction(settingsAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func displayFetchError(error: NSError?) {
        if presentedViewController == nil {
            var message = "We mixed something up!! Hopefully we'll resolve the issues soon."
            if let error = error {
                if error.code == MissingHTTPResponseError {
                    message = "There seems to be some trouble connecting to the internet. Check your connection and try again."
                }
            }
            let alertController = UIAlertController(title: "Sorry!", message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(action)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func displaySearchAlert() {
        if presentedViewController == nil {
            
            let alertController = UIAlertController(title: "Sorry!", message: "Unable to find a matching location. Please try you search again.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(action)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func addAnnotations() {
        var annotations = [CoffeeShopAnnotation]()

        for venue in venues {
            if let coordinate = venue.location?.coordinate,
                let address = venue.location?.streetAddress {
                let point = CoffeeShopAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude,
                        longitude: coordinate.longitude),
                    venueId: venue.id,
                    title: venue.name, address: address)
                annotations.append(point)
            }
        }
        mapView?.addAnnotations(annotations)
    }
    
    func removeMapAnnotations() {
        if mapView?.annotations.count != 0 {
            for annotation in (mapView?.annotations)! {
                mapView?.removeAnnotation(annotation)
            }
        }
    }
    
    func updateMapCenter() {
        var region = MKCoordinateRegion()
        if let coordinate = coordinate {
            region.center = CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                   longitude: coordinate.longitude)
            region.span.latitudeDelta = 0.03
            region.span.longitudeDelta = 0.03
            
            mapView?.setRegion(region, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationView") {
            pinView.annotation = annotation
            return pinView
        } else {
            let newPinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            newPinView.image = UIImage(named: "coffee_annotation_view")
            newPinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            newPinView.canShowCallout = true
            
            return newPinView
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? CoffeeShopAnnotation {
            mapView.deselectAnnotation(annotation, animated: true)
            performSegueWithIdentifier("ShowVenueDetails", sender: annotation)
        }
        
        
    }

    // MARK: UISearchBarDelegate Methods

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(searchBar.text!){ [weak self] (placemarks, error) in
            
            if let error = error {
                print("Error in geocoding \(searchBar.text), error: \(error.localizedDescription)")
                self?.displaySearchAlert()
            } else {
                
                if let placemark = placemarks!.first {
                    if let location = placemark.location {
                        let coordinate = Coordinate(location: location)
                        self?.coordinate = coordinate
                        self?.updateMapCenter()
                        self?.foursquareClient.fetchCoffeeShopsFor(coordinate, category: .Coffee, limit: 15) { result in
                            switch result {
                            case .Success(let venues):
                                self?.venues = venues
                            case .Failure(let error):
                                self?.displayFetchError(error as NSError)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let annotation = sender as? CoffeeShopAnnotation,
            let venueId = annotation.venueId {
            if let venue = self.venues.filter({$0.id == venueId}).first,
                let detailsViewController = segue.destinationViewController as? VenueDetailsViewController {
                detailsViewController.venue = venue
            }
        }
    }


}

