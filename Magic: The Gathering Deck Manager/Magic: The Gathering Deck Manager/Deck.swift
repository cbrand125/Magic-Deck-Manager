//
//  Deck.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 11/21/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import Foundation
import CoreData

class Deck: NSManagedObject {

    //returns the first letter of the name of this Deck or nil if the name is empty
    func firstLetter() -> String? {
        let name = self.name!
        return name.firstLetter()
    }
    
}
