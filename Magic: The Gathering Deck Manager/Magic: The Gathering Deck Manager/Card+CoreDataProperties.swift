//
//  Card+CoreDataProperties.swift
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

extension Card {

    @NSManaged var artist: String?
    @NSManaged var cmc: NSNumber?
    @NSManaged var colors: NSObject?
    @NSManaged var flavor: String?
    @NSManaged var id: String?
    @NSManaged var layout: String?
    @NSManaged var legalities: NSObject?
    @NSManaged var loyalty: NSNumber?
    @NSManaged var manaCost: String?
    @NSManaged var multiverseid: NSNumber?
    @NSManaged var name: String?
    @NSManaged var names: NSObject?
    @NSManaged var power: String?
    @NSManaged var printings: NSObject?
    @NSManaged var rarity: String?
    @NSManaged var subtypes: NSObject?
    @NSManaged var supertypes: NSObject?
    @NSManaged var text: String?
    @NSManaged var toughness: String?
    @NSManaged var types: NSObject?
    @NSManaged var decks: NSSet?
    
    @NSManaged func addDecksObject(deck: CardQuantity)
    @NSManaged func removeDecksObject(deck: CardQuantity)

}
