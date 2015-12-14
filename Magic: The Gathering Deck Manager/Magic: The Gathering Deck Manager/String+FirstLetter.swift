//
//  String+FirstLetter.swift
//  US States
//
//  Created by John Hannan on 10/1/15.
//  Copyright © 2015 John Hannan. All rights reserved.
//

import Foundation

extension String {
    
    //returns the first letter of the input string or nil for an empty string
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substringToIndex(self.startIndex.successor()))
    }
}