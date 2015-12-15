//
//  DeckTableViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 12/6/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit
import CoreData

class DeckTableViewController: UITableViewController, DataSourceCellConfigurer, UIPopoverPresentationControllerDelegate, AddDeckViewControllerDelegate {
    
    let model = Model.sharedInstance
    
    lazy var dataSource : DataSource = DataSource(entity: "Deck", sortKeys: ["name"], predicate: nil, sectionNameKeyPath: "firstLetter", delegate: self.model)
    
    var detailViewController: MasterViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "Decks"
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MasterViewController
        }
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: DeckViewController Delegate
    func addNewDeckForName(deck: String) -> Deck {
        let deck = model.insertDeckWithName(deck)
        dataSource.update()
        tableView.reloadData()
        
        return deck
    }
    
    //MARK: Data Source Cell Configurer
    func cellIdentifierForObject(object: NSManagedObject) -> String {
        return "DeckCell"
    }
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let deck = object as! Deck
        cell.textLabel!.text = deck.name
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDeck" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = dataSource.objectAtIndexPath(indexPath) as! Deck
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MasterViewController
                controller.deck = object
            }
        } else if segue.identifier == "addDeck" {
            let controller = segue.destinationViewController as! AddDeckViewController
            controller.delegate = self
            controller.preferredContentSize = CGSize(width: self.preferredContentSize.width/2, height: self.preferredContentSize.height/2)
            
            let popController = controller.popoverPresentationController
            popController!.permittedArrowDirections = UIPopoverArrowDirection.Any
            popController!.barButtonItem = self.navigationItem.rightBarButtonItem
            popController!.delegate = self
        }
    }
    
    // MARK: - Table View
    func editTableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let deck = dataSource.objectAtIndexPath(indexPath) as! Deck
            model.removeDeck(deck)
            dataSource.update()
            tableView.reloadData()
            
            //disable error-causing buttons for the deleted deck
            if let split = self.splitViewController {
                let controllers = split.viewControllers
                self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MasterViewController
            }
            detailViewController?.tableView.userInteractionEnabled = false
            detailViewController?.navigationItem.leftBarButtonItems![1].enabled = false
            if let buttons = detailViewController?.navigationItem.rightBarButtonItems {
                for button in buttons {
                    button.enabled = false
                }
            } else {
                detailViewController?.navigationItem.rightBarButtonItem!.enabled = false
            }
        }
    }
    
}