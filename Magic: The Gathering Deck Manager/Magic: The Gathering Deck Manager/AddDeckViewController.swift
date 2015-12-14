//
//  AddDeckViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 12/7/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit

protocol AddDeckViewControllerDelegate {
    func addNewDeckForName(deck: String) -> Deck
}

class AddDeckViewController: UIViewController {
    
    let model = Model.sharedInstance
    
    var delegate : AddDeckViewControllerDelegate?
    
    @IBOutlet weak var deckNameText: UITextField!
    @IBOutlet weak var cardListText: UITextView!
    
    @IBAction func submitPressed(sender: UIButton) {
        if let deckName = deckNameText!.text {
            if let deck = delegate?.addNewDeckForName(deckName) {
                readCardListIntoDeck(deck)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func cancelPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func readCardListIntoDeck(deck: Deck) {
        if let text = cardListText.text {
            let nstext = text as NSString
            let regex = try! NSRegularExpression(pattern: "^.+$", options: NSRegularExpressionOptions.AnchorsMatchLines)
            let matches = regex.matchesInString(text, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, nstext.length))
            for match in matches {
                let line = nstext.substringWithRange(match.range) as NSString
                var number : Int = 0
                var cardName : String = ""
                
                let numberRegex = try! NSRegularExpression(pattern: "^[0-9]+", options: NSRegularExpressionOptions.AnchorsMatchLines)
                if let match = numberRegex.firstMatchInString(line as String, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, line.length)) {
                    let numberString = line.substringWithRange(match.range)
                    number = Int(numberString)!
                }
                
                let cardNameRegex = try! NSRegularExpression(pattern: "^[0-9]+\\s.", options: NSRegularExpressionOptions.AnchorsMatchLines)
                if let match = cardNameRegex.firstMatchInString(line as String, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, line.length)) {
                    cardName = line.substringFromIndex(match.range.length - 1)
                }
                
                addNewCardForNameWithCountIntoDeck(deck, card: cardName, count: number)
            }
        }
    }
    
    func addNewCardForNameWithCountIntoDeck(deck: Deck, card: String, count: Int) {
        //get the card for the input name
        let filteredArray = model.allCards.filter { $0.name!.caseInsensitiveCompare(card) == NSComparisonResult.OrderedSame }
        if let card = filteredArray.first {
            model.addCardtoDeck(deck, card: card, count: count)
        }
    }
}
