//
//  AddCardViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 11/22/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit

protocol AddCardViewControllerDelegate {
    func addNewCardForNameWithCount(card: String, count: Int)
}

class AddCardViewController: UIViewController {
    
    var delegate : AddCardViewControllerDelegate?

    @IBOutlet weak var cardQuantity: UILabel!
    @IBOutlet weak var cardSearchText: UITextField!
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        cardQuantity.text = String(Int(sender.value))
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        if let cardName = cardSearchText!.text {
            if let cardCount = cardQuantity {
                let count = Int(Double(cardCount.text!)!)
                delegate?.addNewCardForNameWithCount(cardName, count: count)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}
