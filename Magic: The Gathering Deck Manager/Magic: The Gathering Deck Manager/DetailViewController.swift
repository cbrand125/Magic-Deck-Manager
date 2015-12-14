//
//  DetailViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 11/21/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var flavorLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var manacostLabel: UILabel!
    @IBOutlet weak var powerToughnessLabel: UILabel!
    
    var detailItem: AnyObject? {
        didSet {
            //Update the view.
            self.configureView()
        }
    }

    func configureView() {
        //Update the user interface for the detail item.
        if let detail = self.detailItem as? Card {
            if let cardName = detail.name {
                self.navigationItem.title = cardName
                if let cardNameEscaped = cardName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) {
                    if let image = self.cardImage {
                        image.downloadedFrom(link: "http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=" + cardNameEscaped, contentMode: .ScaleAspectFit)
                        image.hidden = false
                    }
                }
            }
            
            if let text = detail.text {
                if let label = self.detailDescriptionLabel {
                    label.text = text
                    label.hidden = false
                }
            }
            
            if let flavor = detail.flavor {
                if let label = self.flavorLabel {
                    label.text = flavor
                    label.hidden = false
                }
            }
            
            if let label = self.typesLabel {
                var typesString = ""
                
                if let supertypes = detail.supertypes as? [String] {
                    for supertype in supertypes {
                        typesString = typesString + " " + supertype
                    }
                }
                
                if let types = detail.types as? [String] {
                    for type in types {
                        typesString = typesString + " " + type
                    }
                }
                
                if let subtypes = detail.subtypes as? [String] {
                    typesString = typesString + " -"
                    for subtype in subtypes {
                        typesString = typesString + " " + subtype
                    }
                }
                
                label.text = typesString
                label.hidden = false
            }
            
            if let manacost = detail.manaCost {
                if let label = self.manacostLabel {
                    label.text = manacost
                    label.hidden = false
                }
            }
            
            if let power = detail.power, toughness = detail.toughness {
                if let label = self.powerToughnessLabel {
                    label.text = power + "/" + toughness
                    label.hidden = false
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

