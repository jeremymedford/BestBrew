//
//  FoursquareClient.swift
//
//
//  Original code from Treehouse Course projects. Modified with permission.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

enum Foursquare: Endpoint {
    
    
    case Venues(VenueEndpoint)
    
    enum VenueEndpoint: Endpoint {
        
        case Tips(clientID: String, clientSecret: String, venueId: String, sort: SortType?, limit: Int?, offset: Int?)
        case Photos(clientID: String, clientSecret: String, venueId: String, limit: Int?, offset: Int?) // not using group parameter for now.
        case Search(clientID: String, clientSecret: String, coordinate: Coordinate, category: Category, query: String?, searchRadius: Int?, limit: Int?)
        
        enum SortType: String {
            case Popular = "popular"
            case Recent = "recent"
            case Friends = "friends"
        }
        
        enum Category: CustomStringConvertible {
            case Food([FoodCategory]?)
            
            case Coffee
            
            enum FoodCategory: String {
                case Afghan = "503288ae91d4c4b30a586d67"
            }
            
            
            
            var description: String {
                switch self {
                case .Food(let categories):
                    if let categories = categories {
                        let commaSeparatedString = categories.reduce("") { categoryString, category in
                            "\(categoryString),\(category.rawValue)"
                        }
                        
                        return commaSeparatedString.substringFromIndex(commaSeparatedString.startIndex.advancedBy(1))
                    } else {
                        return "4d4b7105d754a06374d81259"
                    }
                case .Coffee:
                    return "4bf58dd8d48988d1e0931735"
                }
            }
        }
        
        // MARK: Venue Endpoint - Endpoint
        
        var baseURL: String {
            return "https://api.foursquare.com"
        }
        
        var path: String {
            switch self {
            case .Search: return "/v2/venues/search"
            case .Tips( _, _, let venueId, _, _, _):
                return "/v2/venues/\(venueId)/tips"
            case .Photos( _, _, let venueId, _, _):
                return "/v2/venues/\(venueId)/photos"
            }
            
        }
        
        private struct ParameterKeys {
            static let clientID = "client_id"
            static let clientSecret = "client_secret"
            static let version = "v"
            static let category = "categoryId"
            static let location = "ll"
            static let query = "query"
            static let limit = "limit"
            static let searchRadius = "radius"
            static let sort = "sort"
            static let offset = "offset"
        }
        
        private struct DefaultValues {
            static let version = "20160301"
            static let limit = "50"
            static let searchRadius = "2000"
            static let sort = "recent"
        }
        
        var parameters: [String : AnyObject] {
            switch self {
            case .Search(let clientID, let clientSecret, let coordinate, let category, let query, let searchRadius, let limit):
                
                var parameters: [String: AnyObject] = [
                    ParameterKeys.clientID: clientID,
                    ParameterKeys.clientSecret: clientSecret,
                    ParameterKeys.version: DefaultValues.version,
                    ParameterKeys.location: coordinate.description,
                    ParameterKeys.category: category.description
                ]
                
                if let searchRadius = searchRadius {
                    parameters[ParameterKeys.searchRadius] = searchRadius
                } else {
                    parameters[ParameterKeys.searchRadius] = DefaultValues.searchRadius
                }
                
                if let limit = limit {
                    parameters[ParameterKeys.limit] = limit
                } else {
                    parameters[ParameterKeys.limit] = DefaultValues.limit
                }
                
                if let query = query {
                    parameters[ParameterKeys.query] = query
                }
                
                return parameters
            case .Tips(let clientID, let clientSecret, _, let sort, let limit, let offset):
                
                var parameters: [String: AnyObject] = [
                    ParameterKeys.clientID: clientID,
                    ParameterKeys.clientSecret: clientSecret,
                    ParameterKeys.version: DefaultValues.version
                ]
                
                if let sort = sort {
                    parameters[ParameterKeys.sort] = sort.rawValue
                } else {
                    parameters[ParameterKeys.sort] = DefaultValues.sort
                }
                
                if let limit = limit {
                    parameters[ParameterKeys.limit] = limit
                } else {
                    parameters[ParameterKeys.limit] = DefaultValues.limit
                }
                
                if let offset = offset {
                    parameters[ParameterKeys.offset] = offset
                }
                
                return parameters
                
            case .Photos(let clientID, let clientSecret, _, let limit, let offset):
                
                var parameters: [String: AnyObject] = [
                    ParameterKeys.clientID: clientID,
                    ParameterKeys.clientSecret: clientSecret,
                    ParameterKeys.version: DefaultValues.version
                ]
                
                if let limit = limit {
                    parameters[ParameterKeys.limit] = limit
                } else {
                    parameters[ParameterKeys.limit] = DefaultValues.limit
                }
                
                if let offset = offset {
                    parameters[ParameterKeys.offset] = offset
                }
                
                return parameters
            }
            
            
        }
    }
    
    // MARK: Foursquare - Endpoint
    
    var baseURL: String {
        switch self {
        case .Venues(let endpoint):
            return endpoint.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .Venues(let endpoint):
            return endpoint.path
        }
    }
    
    var parameters: [String : AnyObject] {
        switch self {
        case .Venues(let endpoint):
            return endpoint.parameters
        }
    }
}

final class FoursquareClient: APIClient {
    
    let configuration: NSURLSessionConfiguration
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
    }()
    
    let clientID: String
    let clientSecret: String
    
    init(configuration: NSURLSessionConfiguration, clientID: String, clientSecret: String) {
        self.configuration = configuration
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    convenience init(clientID: String, clientSecret: String) {
        self.init(configuration: .defaultSessionConfiguration(), clientID: clientID, clientSecret: clientSecret)
    }
    
    func fetchRestaurantsFor(location: Coordinate, category: Foursquare.VenueEndpoint.Category, query: String? = nil, searchRadius: Int? = nil, limit: Int? = nil, completion: APIResult<[Venue]> -> Void) {
        
        let searchEndpoint = Foursquare.VenueEndpoint.Search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
        let endpoint = Foursquare.Venues(searchEndpoint)
        
        fetch(endpoint, parse: { json -> [Venue]? in
            
            guard let venues = json["response"]?["venues"] as? [[String: AnyObject]] else { return nil }
            
            return venues.flatMap { venueDict in
                return Venue(JSON: venueDict)
            }
            
            
            }, completion: completion)
    }
    
    func fetchCoffeeShopsFor(location: Coordinate, category: Foursquare.VenueEndpoint.Category, query: String? = nil, searchRadius: Int? = nil, limit: Int? = nil, completion: APIResult<[Venue]> -> Void) {
        
        let searchEndpoint = Foursquare.VenueEndpoint.Search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
        let endpoint = Foursquare.Venues(searchEndpoint)
        
        fetch(endpoint, parse: { json -> [Venue]? in
            guard let venues = json["response"]?["venues"] as? [[String: AnyObject]] else { return nil }
            return venues.flatMap { venueDict in
                return Venue(JSON: venueDict)
            }
            
            
            }, completion: completion)
    }
    
    func fetchTipsFor(venueId: String, sort: Foursquare.VenueEndpoint.SortType? = nil, limit: Int? = nil, offset: Int? = nil, completion: APIResult<[Tip]> -> Void) {
        
        let tipsEndpoint = Foursquare.VenueEndpoint.Tips(clientID: self.clientID, clientSecret: self.clientSecret, venueId: venueId, sort: sort, limit: limit, offset: offset)
        let endpoint = Foursquare.Venues(tipsEndpoint)
        
        fetch(endpoint, parse: { json -> [Tip]? in
            
            guard let tips = json["response"]?["tips"]?!["items"] as? [[String: AnyObject]] else { return nil }
            
            return tips.flatMap { tipDict in
                return Tip(JSON: tipDict)
            }
            
            }, completion: completion)
    }
    
    func fetchPhotosFor(venueId: String, limit: Int? = 1, offset: Int? = nil, completion: APIResult<[VenuePhoto]> -> Void) {
        
        let photosEndpoint = Foursquare.VenueEndpoint.Photos(clientID: self.clientID, clientSecret: self.clientSecret, venueId: venueId, limit: limit, offset: offset)
        let endpoint = Foursquare.Venues(photosEndpoint)
        
        fetch(endpoint, parse: { json -> [VenuePhoto]? in
            
            guard let photos = json["response"]?["photos"]?!["items"] as? [[String: AnyObject]] else { return nil }
            return photos.flatMap { photoDict in
                return VenuePhoto(JSON: photoDict)
            }
            }, completion: completion)
        
    }
    
}






















