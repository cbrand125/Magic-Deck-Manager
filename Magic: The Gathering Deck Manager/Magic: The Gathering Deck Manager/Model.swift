//
//  Model.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 11/21/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import Foundation
import CoreData

struct CardKey {
    static let Layout = "layout"
    static let Name = "name"
    static let ManaCost = "manaCost"
    static let CMC = "cmc"
    static let Colors = "colors"
    static let Types = "types"
    static let Subtypes = "subtypes"
    static let Text = "text"
    static let Power = "power"
    static let Toughness = "toughness"
    static let Printings = "printings"
    static let Legalities = "legalities"
    static let ID = "id"
    static let Names = "names"
    static let Supertypes = "supertypes"
    static let Rarity = "rarity"
    static let Flavor = "flavor"
    static let Artist = "artist"
    static let Loyalty = "loyalty"
    static let MultiverseID = "multiverseid"
}

class Model : DataManagerDelegate {
    let filename = "AllCards-x"
    var allCards : [Card]!
    var decks : [Deck]!
    
    let dataManager = DataManager.sharedInstance
    
    static let sharedInstance = Model()
    
    private init() {
        dataManager.delegate = self
        
        allCards = dataManager.fetchManagedObjectsForEntity("Card", sortKeys: ["name"], predicate: nil) as! [Card]
        decks = dataManager.fetchManagedObjectsForEntity("Deck", sortKeys: ["name"], predicate: nil) as! [Deck]
    }
    
    //MARK: Datamanager Protocol
    func xcDataModelName() -> String {
        return "Cards"
    }
    
    func createDatabase() {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(filename, ofType: "json")!
        let data = NSData(contentsOfFile: path)
        
        let cards = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [String:[String:AnyObject]]
        let deckObj = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: dataManager.managedObjectContext!) as! Deck
        deckObj.name = "Default Deck"
        
        var count = 0
        for (_, value) in cards {
            let cardObj = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: dataManager.managedObjectContext!) as! Card
            
            let layout = value[CardKey.Layout] as! String
            let name = value[CardKey.Name] as! String
            let manaCost = value[CardKey.ManaCost] as? String
            let cmc = value[CardKey.CMC] as? NSNumber
            let colors = value[CardKey.Colors] as? [String]
            let types = value[CardKey.Types] as? [String]
            let subtypes = value[CardKey.Subtypes] as? [String]
            let text = value[CardKey.Text] as? String
            let power = value[CardKey.Power] as? String
            let toughness = value[CardKey.Toughness] as? String
            let printings = value[CardKey.Printings] as! [String]
            let legalities = value[CardKey.Legalities] as? [[String:String]]
            let id = value[CardKey.ID] as? String
            let names = value[CardKey.Names] as? [String]
            let supertypes = value[CardKey.Supertypes] as? [String]
            let rarity = value[CardKey.Rarity] as? String
            let flavor = value[CardKey.Flavor] as? String
            let artist = value[CardKey.Artist] as? String
            let loyalty = value[CardKey.Loyalty] as? NSNumber
            let multiverseid = value[CardKey.MultiverseID] as? NSNumber
            
            
            cardObj.toughness = toughness
            cardObj.power = power
            cardObj.layout = layout
            cardObj.name = name
            cardObj.manaCost = manaCost
            cardObj.cmc = cmc
            cardObj.colors = colors
            cardObj.types = types
            cardObj.subtypes = subtypes
            cardObj.text = text
            cardObj.printings = printings
            cardObj.legalities = legalities
            cardObj.id = id
            cardObj.names = names
            cardObj.supertypes = supertypes
            cardObj.rarity = rarity
            cardObj.flavor = flavor
            cardObj.artist = artist
            cardObj.loyalty = loyalty
            cardObj.multiverseid = multiverseid
            
            if count < 60 {
                let cardQuantityObj = NSEntityDescription.insertNewObjectForEntityForName("CardQuantity", inManagedObjectContext: dataManager.managedObjectContext!) as! CardQuantity
                cardQuantityObj.number = 1
                deckObj.addCardsObject(cardQuantityObj)
                cardObj.addDecksObject(cardQuantityObj)
                count++
            }
        }
        
        dataManager.saveContext()
    }
    
    func insertDeckWithName(name: String) -> Deck {
        let deckObj = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: dataManager.managedObjectContext!) as! Deck
        deckObj.name = name
        decks.append(deckObj)
        dataManager.saveContext()
        
        return deckObj
    }
    
    func removeDeck(deck: Deck) {
        let cardArray = deck.cards!.allObjects as! [CardQuantity]
        for card in cardArray {
            deck.removeCardsObject(card)
            card.card?.removeDecksObject(card)
        }
        dataManager.managedObjectContext!.deleteObject(deck)
        dataManager.saveContext()
    }
    
    func removeCardFromDeck(deck: Deck, card: Card) {
        let cardArray = deck.cards!.allObjects as! [CardQuantity]
        let filteredCardArray = cardArray.filter() { $0.card == card }
        if let cardCount = filteredCardArray.first {
            deck.removeCardsObject(cardCount)
            card.removeDecksObject(cardCount)
            dataManager.saveContext()
        }
    }
    
    func addCardtoDeck(deck: Deck, card: Card, count: Int) {
        let cardQuantityObj = NSEntityDescription.insertNewObjectForEntityForName("CardQuantity", inManagedObjectContext: dataManager.managedObjectContext!) as! CardQuantity
        cardQuantityObj.number = count
        deck.addCardsObject(cardQuantityObj)
        card.addDecksObject(cardQuantityObj)
        dataManager.saveContext()
    }
    
    func incrementCardQuantityByCount(cardCount: CardQuantity, count: Int) {
        cardCount.number = cardCount.number!.integerValue + count
        dataManager.saveContext()
    }
    
    func setCardQuantity(cardCount: CardQuantity, count: Int) {
        cardCount.number = count
        dataManager.saveContext()
    }

}