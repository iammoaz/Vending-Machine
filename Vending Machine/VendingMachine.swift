//
//  VendingMachine.swift
//  Vending Machine
//
//  Created by Muhammad Moaz on 1/3/17.
//  Copyright © 2017 Muhammad Moaz. All rights reserved.
//

import Foundation

enum VendingSelection {
    case soda, dietSoda, chips, cookie, sandwich, wrap, candyBar, popTart, water, fruitJuice, sportsDrink, gum
}

enum InventoryError: Error {
    case invalidResource, conversionFailure
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
    func vend(_ quantity: Int, _ selection: VendingSelection) throws
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

class FoodVendingMaching: VendingMachine {
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .sandwich, .wrap, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(_ quantity: Int, _ selection: VendingSelection) throws {
    }
    
    func deposit(_ amount: Double) {
    }
}
