//
//  CardQuantity+CoreDataProperties.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 12/6/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CardQuantity {

    @NSManaged var number: NSNumber?
    @NSManaged var deck: Deck?
    @NSManaged var card: Card?

}
