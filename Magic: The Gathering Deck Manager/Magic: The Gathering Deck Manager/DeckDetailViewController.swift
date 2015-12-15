//
//  DeckDetailViewController.swift
//  Magic: The Gathering Deck Manager
//
//  Created by Cody Brand on 12/13/15.
//  Copyright © 2015 Cody Brand. All rights reserved.
//

import UIKit

class aggregateColorInfo {
    var max : Int
    var CMCofMax : Int
    var totalSymbolCount : Int
    
    init(a: Int, b: Int, c: Int) {
        max = a
        CMCofMax = b
        totalSymbolCount = c
    }
}

class DeckDetailViewController: UIViewController {
    
    let manaMax = 100
    let manaMin = 0
    
    @IBOutlet weak var manaRestrictionLabel: UILabel!
    @IBOutlet weak var pieChartLabel: UILabel!
    @IBOutlet weak var manaCurveLabel: UILabel!
    
    //deck will eventually be set by the view that presents this view
    var deck : Deck? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    //this finds the lowest total mana cost for the highest color requirement for a desired color and saves this
    func analyzeManaForColorRegex(regex: NSRegularExpression, manaCost: String, color: aggregateColorInfo, card: CardQuantity) {
        let nsmanaCost = manaCost as NSString
        if let match = regex.firstMatchInString(manaCost, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, nsmanaCost.length)) {
            color.totalSymbolCount += match.range.length/3
            if match.range.length > color.max {
                color.max = match.range.length
                if let totalCost = card.card?.cmc?.integerValue {
                    if color.CMCofMax < color.max/3 {
                        color.CMCofMax = manaMax
                    }
                    if color.CMCofMax > totalCost {
                        color.CMCofMax = totalCost
                    }
                }
            }
        }
    }
    
    func configureView() {
        var cards = [CardQuantity]()
        if deck != nil {
            cards = deck?.cards?.allObjects as! [CardQuantity]
        }
        
        let blackRegex = try! NSRegularExpression(pattern: "(\\{B\\})+", options: NSRegularExpressionOptions.AnchorsMatchLines)
        let blueRegex = try! NSRegularExpression(pattern: "(\\{U\\})+", options: NSRegularExpressionOptions.AnchorsMatchLines)
        let whiteRegex = try! NSRegularExpression(pattern: "(\\{W\\})+", options: NSRegularExpressionOptions.AnchorsMatchLines)
        let redRegex = try! NSRegularExpression(pattern: "(\\{R\\})+", options: NSRegularExpressionOptions.AnchorsMatchLines)
        let greenRegex = try! NSRegularExpression(pattern: "(\\{G\\})+", options: NSRegularExpressionOptions.AnchorsMatchLines)
        
        let black = aggregateColorInfo(a: manaMin, b: manaMax, c: 0)
        let blue = aggregateColorInfo(a: manaMin, b: manaMax, c: 0)
        let white = aggregateColorInfo(a: manaMin, b: manaMax, c: 0)
        let red = aggregateColorInfo(a: manaMin, b: manaMax, c: 0)
        let green = aggregateColorInfo(a: manaMin, b: manaMax, c: 0)
        var totalMana = [Int](count: manaMax, repeatedValue: 0)
        var maxCMC = 1
        var maxCMCOccurences = 0
        for card in cards {
            if let manaCost = card.card?.manaCost {
                analyzeManaForColorRegex(blackRegex, manaCost: manaCost, color: black, card: card)
                analyzeManaForColorRegex(blueRegex, manaCost: manaCost, color: blue, card: card)
                analyzeManaForColorRegex(whiteRegex, manaCost: manaCost, color: white, card: card)
                analyzeManaForColorRegex(redRegex, manaCost: manaCost, color: red, card: card)
                analyzeManaForColorRegex(greenRegex, manaCost: manaCost, color: green, card: card)
            }
            if let cmc = card.card?.cmc?.integerValue {
                totalMana[cmc]++
                if totalMana[cmc] > maxCMCOccurences {
                    maxCMCOccurences = totalMana[cmc]
                }
                if cmc > maxCMC {
                    maxCMC = cmc
                }
            }
        }
        
        if let label = self.manaRestrictionLabel {
            label.text = ""
            if black.max != manaMin && black.CMCofMax != manaMax {
                label.text = label.text! + "Black: " + String(black.max/3) + " by turn " + String(black.CMCofMax) + "\n"
            }
            if blue.max != manaMin && blue.CMCofMax != manaMax {
                label.text = label.text! + "Blue: " + String(blue.max/3) + " by turn " + String(blue.CMCofMax) + "\n"
            }
            if white.max != manaMin && white.CMCofMax != manaMax {
                label.text = label.text! + "White: " + String(white.max/3) + " by turn " + String(white.CMCofMax) + "\n"
            }
            if red.max != manaMin && red.CMCofMax != manaMax {
                label.text = label.text! + "Red: " + String(red.max/3) + " by turn " + String(red.CMCofMax) + "\n"
            }
            if green.max != manaMin && green.CMCofMax != manaMax {
                label.text = label.text! + "Green: " + String(green.max/3) + " by turn " + String(green.CMCofMax)
            }
        }
        
        if let label = self.pieChartLabel {
            let xPos = label.frame.origin.x - 150
            let yPos = label.frame.origin.y + label.frame.height + 100
            let pieChartView = PieChartView(frame: CGRectMake(xPos, yPos, 300, 200))
            pieChartView.addItem(Float(black.totalSymbolCount), color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            pieChartView.addItem(Float(blue.totalSymbolCount), color: UIColor.blueColor())
            pieChartView.addItem(Float(white.totalSymbolCount), color: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
            pieChartView.addItem(Float(red.totalSymbolCount), color: UIColor.redColor())
            pieChartView.addItem(Float(green.totalSymbolCount), color: UIColor.greenColor())
            pieChartView.bounds = pieChartView.frame
            pieChartView.setNeedsDisplay()
            self.view.addSubview(pieChartView)
        }
        
        if let label = self.manaCurveLabel {
            label.text = ""
            for i in maxCMCOccurences.stride(to: 0, by: -1) {
                var barSwitch = true
                for j in maxCMC.stride(to: 0, by: -1) {
                    if totalMana[j] >= i {
                        if barSwitch {
                            label.text = label.text! + "*****"
                        } else {
                            label.text = label.text! + "-----"
                        }
                    } else {
                        label.text = label.text! + "     "
                    }
                    barSwitch = !barSwitch
                }
                label.text = label.text! + "\n"
            }
            for i in 1...maxCMC {
                label.text = label.text! + "  " + String(i) + "  "
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
