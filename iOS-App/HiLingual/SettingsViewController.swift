//
//  SettingsViewController.swift
//  HiLingual
//
//  Created by Joseph on 3/2/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settings = ["Show Gender".localized, "Show Age".localized, "Show Profile in Matching".localized, "Display Full Name".localized]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
