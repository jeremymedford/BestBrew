//
//  NSDate+BBExtensions.swift
//  JMSampleFourSquare
//
//  Created by Jeremy Medford on 6/11/16.
//  Copyright © 2016 Vintage Robot. All rights reserved.
//

import Foundation

public extension NSDate {
    
    func standardFormat() -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(self)
    }
    
}