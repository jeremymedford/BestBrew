//
//  BestBrewTests.swift
//  BestBrewTests
//
//  Created by Jeremy Medford on 6/12/16.
//  Copyright © 2016 JM Inc. All rights reserved.
//

import XCTest
@testable import BestBrew

class BestBrewTests: XCTestCase {
    
    var venue: Venue?
    
    override func setUp() {
        super.setUp()
        let category1 = ["shortName":"testCategory1"]
        let category2 = ["shortName":"testCategory2"]
        
        let stats = ["checkinsCount": 6822, "tipCount": 74, "usersCount": 2113]
        
        let JSONDict = ["id":"12345", "name": "testVenue", "categories": [category1, category2], "stats": stats, "location": ["address": "123 Main", "lat":37.123, "lng": -122.223]]
        
        venue = Venue(JSON: JSONDict as! [String : AnyObject])    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVenueCreation() {
        XCTAssertNotNil(venue, "Venue should not be nil")
    }
    
    func testVenueNameIsCorrect() {
        XCTAssertTrue(venue?.name == "testVenue", "TestVenue should have name testVenue")
    }
    
    func testLocationLatLongCorrect() {
        
        XCTAssertTrue(venue?.location?.coordinate?.latitude == 37.123, "Location latitude should be 37.123")
        XCTAssertTrue(venue?.location?.coordinate?.longitude == -122.223, "Location longitude should be -122.223")
        
    }
    
}
