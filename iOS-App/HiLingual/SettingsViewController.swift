//
//  SettingsViewController.swift
//  HiLingual
//
//  Created by Joseph on 3/2/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit
import StoreKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    var product: SKProduct?
    var productID = "TranslationsCount"
    
    @IBOutlet var purchaseButton: UIBarButtonItem!
    let settings = ["Show Gender".localized, "Show Age".localized, "Show Profile in Matching".localized, "Display Full Name".localized]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseButton.enabled = false;
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        getProductInfo()

        // Do any additional setup after loading the view.
    }
    
    func getProductInfo()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
        } 
    }
    
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            product = products[0] as SKProduct
            purchaseButton.enabled = true
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                self.unlockFeature()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func unlockFeature() {
        
        
        //send request to server
        purchaseButton.enabled = false
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SettingsCell
        cell.titleLabel?.text = settings[indexPath.row]
        let isChecked = NSUserDefaults.standardUserDefaults().boolForKey(settings[indexPath.row])
        cell.`switch`.on = isChecked
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func pressedPurchase(sender: AnyObject) {
        let payment = SKPayment(product: product!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    @IBAction func pressedDone(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

class SettingsCell: UITableViewCell {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func switchChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: (self.titleLabel?.text)!)
    }

}
