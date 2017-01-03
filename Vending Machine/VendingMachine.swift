//
//  VendingMachine.swift
//  Vending Machine
//
//  Created by Muhammad Moaz on 1/3/17.
//  Copyright © 2017 Muhammad Moaz. All rights reserved.
//

import UIKit

enum VendingSelection: String {
    case soda, dietSoda, chips, cookie, sandwich, wrap, candyBar, popTart, water, fruitJuice, sportsDrink, gum
    
    func icon() -> UIImage {
        guard let image = UIImage(named: self.rawValue.capitalized) else {
            return #imageLiteral(resourceName: "Default")
        }
        
        return image
    }
}

enum InventoryError: Error {
    case invalidResource, conversionFailure, invalidSelection
}

enum VendingMachineError: Error {
    case outOfStock, insufficientFunds(required: Double), invalidSelection
}

protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}

protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    func vend(selection: VendingSelection, quantity: Int) throws
    func deposit(_ amount: Double)
}

struct Item: VendingItem {
    let price: Double
    var quantity: Int
}

class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else { throw InventoryError.invalidResource }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else { throw InventoryError.conversionFailure }
        
        return dictionary
    }
}

class InventoryUnarchiver {
    static func vendingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [VendingSelection: VendingItem] {
        var inventory: [VendingSelection: VendingItem] = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                let item = Item(price: price, quantity: quantity)
                guard let selection = VendingSelection(rawValue: key) else { throw InventoryError.invalidSelection }
                inventory.updateValue(item, forKey: selection)
            }
        }
        return inventory
    }
}

class FoodVendingMaching: VendingMachine {
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .sandwich, .wrap, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(selection: VendingSelection, quantity: Int) throws {
        guard var item = inventory[selection] else { throw VendingMachineError.invalidSelection }
        guard item.quantity >= quantity else { throw VendingMachineError.outOfStock }
        
        let totalPrice = item.price * Double(quantity)
        
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            item.quantity -= quantity
            inventory.updateValue(item, forKey: selection)
        } else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFunds(required: amountRequired)
        }
    }
    
    func deposit(_ amount: Double) {
    }
}
