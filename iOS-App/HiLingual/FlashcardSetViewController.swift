//
//  FlashcardSetViewController.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/15/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

class FlashcardSetViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    var flashcards = [HLFlashCard]()
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        return UIView()
        
    }
    override func viewDidLoad() {
        print(flashcards)
    }
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 0
    }
}
