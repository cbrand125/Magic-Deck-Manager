//
//  MasterViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 11/21/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, DataSourceCellConfigurer, UIPopoverPresentationControllerDelegate, AddCardViewControllerDelegate {
    
    let model = Model.sharedInstance
    
    //deck will eventually be set by the view that presents this view
    var deck : Deck? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var dataSource : DataSource?
    
    func configureView() {
        self.navigationItem.title = deck!.name
        
        //get all cards belonging to this deck
        dataSource = DataSource(entity: "CardQuantity", sortKeys: ["card.types"], predicate: NSPredicate(format: "ANY deck.name == %@", self.deck!.name!), sectionNameKeyPath: "card.types", delegate: self.model)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = Array(arrayLiteral: self.splitViewController!.displayModeButtonItem(), self.editButtonItem())
        self.navigationItem.leftItemsSupplementBackButton = true
        
        //if the deck has been set, enable error-causing buttons and set delegates, otherwise disable them
        if let _ = dataSource {
            dataSource!.delegate = self
            tableView.dataSource = dataSource
            self.tableView.userInteractionEnabled = true
            self.navigationItem.leftBarButtonItems![1].enabled = true
            for button in self.navigationItem.rightBarButtonItems! {
                button.enabled = true
            }
        } else {
            self.tableView.userInteractionEnabled = false
            self.navigationItem.leftBarButtonItems![1].enabled = false
            for button in self.navigationItem.rightBarButtonItems! {
                button.enabled = false
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    func addNewCardForNameWithCount(card: String, count: Int) {
        //get the card for the input name
        let filteredArray = model.allCards.filter { $0.name!.caseInsensitiveCompare(card) == NSComparisonResult.OrderedSame }
        if let card = filteredArray.first {
            //see if card is in deck.  If so, increment that card count, otherwise add the card
            let cardArray = deck?.cards?.allObjects as! [CardQuantity]
            let filteredCardArray = cardArray.filter() { $0.card == card }
            if let cardCount = filteredCardArray.first {
                model.incrementCardQuantityByCount(cardCount, count: count)
            } else {
                model.addCardtoDeck(deck!, card: card, count: count)
                dataSource!.update()
            }
            tableView.reloadData()
        }
    }
    
    
    @IBAction func copyButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Clipboard Notice", message: "This deck has been copied to the clipboard.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        var clipboardText = ""
        var cards = [CardQuantity]()
        if deck != nil {
            cards = deck?.cards?.allObjects as! [CardQuantity]
        }
        for card in cards {
            clipboardText = clipboardText + String(card.number!) + " " + (card.card?.name)! + "\n"
        }
        UIPasteboard.generalPasteboard().string = clipboardText
        
    }
    
    //MARK: Data Source Cell Configurer
    func cellIdentifierForObject(object: NSManagedObject) -> String {
        return "CardCell"
    }
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let cardCount = object as! CardQuantity
        if let card = cardCount.card {
            cell.textLabel!.text = card.name
            cell.detailTextLabel!.text = String(cardCount.number!)
            let customStepper = CardQuantityUIStepper()
            customStepper.card = cardCount
            customStepper.value = Double(Int(cardCount.number!))
            customStepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            cell.editingAccessoryView = customStepper
        }
    }
    
    func stepperValueChanged(sender: CardQuantityUIStepper!) {
        let card = sender.card!
        //make sure the card quantity matches the stepper and delete the card upon stepping to 0
        if sender.value > 0 {
            model.setCardQuantity(card, count: Int(sender.value))
        } else {
            model.removeCardFromDeck(deck!, card: card.card!)
            dataSource!.update()
        }
        tableView.reloadData()
    }

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = dataSource!.objectAtIndexPath(indexPath) as! CardQuantity
                let controller = segue.destinationViewController as! DetailViewController
                controller.detailItem = object.card
            }
        } else if segue.identifier == "addCard" {
            let controller = segue.destinationViewController as! AddCardViewController
            controller.delegate = self
            controller.preferredContentSize = CGSize(width: self.preferredContentSize.width/2, height: self.preferredContentSize.height/2)
            
            let popController = controller.popoverPresentationController
            popController!.permittedArrowDirections = UIPopoverArrowDirection.Any
            popController!.barButtonItem = self.navigationItem.rightBarButtonItem
            popController!.delegate = self
        } else if segue.identifier == "showDeckDetail" {
            let controller = segue.destinationViewController as! DeckDetailViewController
            controller.deck = self.deck
        }
    }

    // MARK: - Table View
    func editTableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let cardCount = dataSource!.objectAtIndexPath(indexPath) as! CardQuantity
            let card = cardCount.card
            model.removeCardFromDeck(deck!, card: card!)
            dataSource!.update()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

}