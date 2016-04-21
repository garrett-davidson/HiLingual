//
//  InlargeImageViewController.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/20/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class InlargeImageViewController: UIViewController {
    var image: UIImage!
    
    @IBOutlet weak var imageInView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageInView.image = image
        imageInView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2));

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
