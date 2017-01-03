//
//  ViewController.swift
//  Vending Machine
//
//  Created by Muhammad Moaz on 1/2/17.
//  Copyright © 2017 Muhammad Moaz. All rights reserved.
//

import UIKit

fileprivate let screenWidth = UIScreen.main.bounds.width

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    fileprivate let vendingMachine: VendingMachine
    fileprivate var currentSelection: VendingSelection?
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "VendingInventory", ofType: "plist")
            let inventory = try InventoryUnarchiver.vendingInventory(fromDictionary: dictionary)
            self.vendingMachine = FoodVendingMaching(inventory: inventory)
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.dataSource = self
        collectionView.delegate = self
        setupCollectionViewCells()
        
        updateDisplayWith(balance: vendingMachine.amountDeposited, totalPrice: 0, itemPrice: 0, itemQuantity: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup
    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView.collectionViewLayout = layout
    }
    
    func updateDisplayWith(balance: Double? = nil, totalPrice: Double? = nil, itemPrice: Double? = nil, itemQuantity: Int? = nil) {
        if let balanceValue = balance {
            balanceLabel.text = "$\(balanceValue)"
        }
        
        if let totalValue = totalPrice {
            totalLabel.text = "$\(totalValue)"
        }
        
        if let priceValue = itemPrice {
            priceLabel.text = "$\(priceValue)"
        }
        
        if let quantityValue = itemQuantity {
            quantityLabel.text = "\(quantityValue)"
        }
    }
    
    func updateTotalPrice(for item: VendingItem) {
        let value = item.price * quantityStepper.value
        updateDisplayWith(totalPrice: value)
    }
    
    // MARK: - Actions
    @IBAction func purchase() {
        guard let currentSelection = currentSelection else {
            return
            // FIXME: Alert user to no selection
        }
        
        do {
            try vendingMachine.vend(selection: currentSelection, quantity: Int(quantityStepper.value))
            updateDisplayWith(balance: vendingMachine.amountDeposited, totalPrice: 0.0, itemPrice: 0, itemQuantity: 1)
        } catch VendingMachineError.outOfStock {
            showAlertWith(title: "Out of stock", message: "This item is unavailable. Please make another selection")
        } catch VendingMachineError.invalidSelection {
            showAlertWith(title: "Invalid Selection", message: "Please make another selection")
        } catch VendingMachineError.insufficientFunds(let required) {
            showAlertWith(title: "Insufficient Funds", message: "You need $\(required) to complete the transaction")
        } catch {
            fatalError("\(error)")
        }
        
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: indexPath, animated: true)
            updateCell(having: indexPath, selected: false)
        }
    }
    
    @IBAction func updateQuantity(_ sender: UIStepper) {
        let quantity = Int(quantityStepper.value)
        updateDisplayWith(itemQuantity: quantity)
        
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            updateTotalPrice(for: item)
        }
    }
}

extension ViewController {
    func showAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: dismissAlert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert(sender: UIAlertAction) -> Void {
        updateDisplayWith(balance: 0, totalPrice: 0, itemPrice: 0, itemQuantity: 0)
    }
}

// MARK: - UICollectionView - DataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vendingMachine.selection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VendingItemCell.reuseIdentifier, for: indexPath) as? VendingItemCell else { fatalError() }
        let item = vendingMachine.selection[indexPath.row]
        cell.iconView.image = item.icon()
        return cell
    }
}

// MARK: - UICollectionView - Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        
        quantityStepper.value = 1
        updateDisplayWith(totalPrice: 0, itemQuantity: 1)
        
        currentSelection = vendingMachine.selection[indexPath.row]
        
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            let totalPrice = item.price * quantityStepper.value
            updateDisplayWith(totalPrice: totalPrice, itemPrice: item.price)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func updateCell(having indexPath: IndexPath, selected: Bool) {
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
        }
    }
}
