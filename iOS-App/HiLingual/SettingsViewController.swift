//
//  SettingsViewController.swift
//  HiLingual
//
//  Created by Joseph on 3/2/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit
import StoreKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    var product: SKProduct?
    var productID = "TranslationsCount"

    @IBOutlet var purchaseButton: UIBarButtonItem!
    let settings = ["Show Gender".localized, "Show Age".localized, "Show Profile in Matching".localized, "Display Full Name".localized]

    override func viewDidLoad() {
        super.viewDidLoad()

        purchaseButton.isEnabled = false
        SKPaymentQueue.default().add(self)
        getProductInfo()

        // Do any additional setup after loading the view.
    }

    func getProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        var products = response.products

        if (products.count != 0) {
            product = products[0] as SKProduct
            purchaseButton.isEnabled = true
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {

            switch transaction.transactionState {

            case SKPaymentTransactionState.purchased:
                self.unlockFeature()
                SKPaymentQueue.default().finishTransaction(transaction)

            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    func unlockFeature() {


        //send request to server
        purchaseButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsCell
        cell.titleLabel?.text = settings[(indexPath as NSIndexPath).row]
        let isChecked = UserDefaults.standard.bool(forKey: settings[(indexPath as NSIndexPath).row])
        cell.`switch`.isOn = isChecked
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

    @IBAction func pressedPurchase(_ sender: AnyObject) {
        let payment = SKPayment(product: product!)
        SKPaymentQueue.default().add(payment)

    }
    @IBAction func pressedDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

class SettingsCell: UITableViewCell {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!

    @IBAction func switchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: (self.titleLabel?.text)!)
    }

}
