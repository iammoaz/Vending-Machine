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
