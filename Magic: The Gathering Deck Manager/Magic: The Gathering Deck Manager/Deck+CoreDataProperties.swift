//
//  Deck+CoreDataProperties.swift
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

extension Deck {

    @NSManaged var name: String?
    @NSManaged var cards: NSSet?
    
    @NSManaged func addCardsObject(card: CardQuantity)
    @NSManaged func removeCardsObject(card: CardQuantity)

}
