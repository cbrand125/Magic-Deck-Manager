//
//  DataSource.swift
//  US States
//
//  Created by John Hannan on 7/2/15.
//  Copyright (c) 2015 John Hannan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol DataSourceCellConfigurer {
    func configureCell(cell:UITableViewCell, withObject object:NSManagedObject) -> Void
    func cellIdentifierForObject(object: NSManagedObject) -> String
    func editTableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
}

class DataSource : NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var tableView : UITableView! {
        didSet {
           fetchedResultsController.delegate = self 
        }
    }
    
    let dataManager = DataManager.sharedInstance
    var delegate : DataSourceCellConfigurer?
    let fetchRequest : NSFetchRequest
    var fetchedResultsController : NSFetchedResultsController
    
    init(entity:String, sortKeys:[String], predicate:NSPredicate?, sectionNameKeyPath:String?, delegate:DataManagerDelegate) {
        
        let dataManager = DataManager.sharedInstance
        dataManager.delegate = delegate
        
        var sortDescriptors : [NSSortDescriptor] = Array()
        for key in sortKeys {
            let descriptor = NSSortDescriptor(key: key, ascending: true)
            sortDescriptors.append(descriptor)
        }
        
        fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.managedObjectContext!, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        var error: NSError? = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
        }
    }
    
    func sortDescriptorsFromStrings(sortKeys:[String]) -> [NSSortDescriptor] {
        var sortDescriptors : [NSSortDescriptor] = Array()
        for key in sortKeys {
            let descriptor = NSSortDescriptor(key: key, ascending: true)
            sortDescriptors.append(descriptor)
        }
        return sortDescriptors
    }
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = self.fetchedResultsController.sections?.count ?? 0
        return count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let managedObject = objectAtIndexPath(indexPath)
        let cellIdentifier = delegate!.cellIdentifierForObject(managedObject)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
        
        delegate?.configureCell(cell, withObject: managedObject)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchedResultsController.sections![section]
        let name = sectionInfo.name
        do {
            let regex = try NSRegularExpression(pattern: "[A-Za-z]+", options: [])
            let nsString = name as NSString
            let results = regex.matchesInString(name, options: [], range: NSMakeRange(0, nsString.length))
            let array = results.map { nsString.substringWithRange($0.range) }
            var header = ""
            for word in array {
                header = header + word + " "
            }
            return header
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.editTableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    //MARK: Manage Updates from fetched results controller
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let object = objectAtIndexPath(indexPath!)
            delegate?.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: object)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    //MARK: Methods for table view controller
    func objectAtIndexPath(indexPath: NSIndexPath) -> NSManagedObject {
        let obj = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        return obj
    }
    
    func indexPathForObject(object: NSManagedObject) -> NSIndexPath {
        let indexPath = fetchedResultsController.indexPathForObject(object)
        return indexPath!
    }
    
    func deleteRowAtIndexPath(indexPath: NSIndexPath) {
        let obj = objectAtIndexPath(indexPath)
        fetchedResultsController.managedObjectContext.deleteObject(obj)
    }
    
    func update() {
        var error: NSError? = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            //abort()
        }
    }
    
    func updateWithPredicate(predicate:NSPredicate) {
        fetchedResultsController.fetchRequest.predicate = predicate
        update()
    }
    
    func updateWithSortDescriptors(sortKeys:[String], keyPath:String) {
        fetchRequest.sortDescriptors = sortDescriptorsFromStrings(sortKeys)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.managedObjectContext!, sectionNameKeyPath: keyPath, cacheName: nil)
        update()
    }
    
    func fetchedObjects() -> [AnyObject]? {
        return fetchedResultsController.fetchedObjects
    }

}