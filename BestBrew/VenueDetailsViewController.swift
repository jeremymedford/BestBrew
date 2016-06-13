//
//  VenueDetailsViewController.swift
//  BestBrew
//
//  Created by Jeremy Medford on 6/12/16.
//  Copyright © 2016 JM Inc. All rights reserved.
//

import UIKit

class VenueDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tipsTableView: UITableView!
    var dataSource: ArrayDataSource?
    
    let foursquareClient = FoursquareClient(clientID: "WCUA33DB0DCX5W1YSCBVEVKEZ24PJ3DN3AV14XZGOB4KNDMM", clientSecret: "N3EMAXQZMEXECDQMBY4YBGXHNU1LHVMHW1RYMNGYS25RVJTI")
    
    var venue: Venue?
    var photo: VenuePhoto? {
        didSet {
            self.loadPhotoImage()
        }
    }
    
    var tips: [Tip] = [] {
        didSet {
            self.updateList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleImageView = UIImageView(image: UIImage(named: "titleView"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 28)
        titleImageView.contentMode = UIViewContentMode.ScaleAspectFit

        navigationItem.titleView = titleImageView

        tipsTableView.rowHeight = UITableViewAutomaticDimension
        tipsTableView.estimatedRowHeight = 80.0

        configureView()
        
        if let venueId = venue?.id {
            foursquareClient.fetchTipsFor(venueId){ result in
                switch result {
                case .Success(let tips):
                    self.tips = tips
                case .Failure(let error):
                    print(error)
                    self.displayFetchError(error as NSError)
                }
            }
            
            foursquareClient.fetchPhotosFor(venueId){ result in
                switch result {
                case .Success(let photos):
                    self.photo = photos.first
                case .Failure(let error):
                    print(error)
                }
            }
        }
        
        dataSource = ArrayDataSource(items: self.tips, cellIdentifier:"TipCell"){
            (cell, item) -> () in
            if let theCell = cell as? TipsCell {
                if let tip = item as Tip? {
                    theCell.configureForTip(tip)
                }
            }
        }
        tipsTableView?.dataSource = dataSource
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        if let venue = self.venue {
            nameLabel?.text = venue.name
            if let address = venue.location?.streetAddress,
                let city = venue.location?.city {
                addressLabel?.text = address + ", " + city
            }
        }
    }
    
    func updateList() {
        if let dataSource = self.dataSource {
            dataSource.items = tips
        }
        tipsTableView.reloadData()
    }
    
    func loadPhotoImage() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let photoURL = NSURL(string: (self.photo?.photoURLString)!) {
                let image = UIImage(data: NSData(contentsOfURL: photoURL)!)
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageView.image = image
                }
            }
        }
    }
}
