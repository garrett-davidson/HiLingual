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
    var random = [HLFlashCard]()
    var flipped = [Bool]()
    var isRandom = false
    @IBOutlet weak var refresh: UIBarButtonItem!

    @IBOutlet weak var shuffle: UIBarButtonItem!
    @IBOutlet weak var carousel: iCarousel!

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        var view: FlashcardTile
        let width = self.view.frame.width - 50
        let height = self.view.frame.height - 150
        view = FlashcardTile(frame: CGRect(x: 0, y: 0, width: width, height: height))

        let tap = UITapGestureRecognizer(target: self, action: #selector(FlashcardSetViewController.handleTap(_:)))
        view.tag = index
        view.addGestureRecognizer(tap)
        if isRandom {
            if flipped[index] == false {
                view.flashcardView.label.text = random[index].frontText
            } else {
                view.flashcardView.label.text = random[index].backText
            }
        } else {
            if flipped[index] == false {
                view.flashcardView.label.text = flashcards[index].frontText
            } else {
                view.flashcardView.label.text = flashcards[index].backText
            }
        }
        return view

    }
    func handleTap(_ sender: AnyObject) {

        let index = sender.view.tag
        //transtion here when I figure it out
        //UIView.transitionFromView(sender.view, toView: sender.view, duration: 0.5, options: .TransitionFlipFromLeft) { finished in}

        if flipped[index] == true {
            flipped[index] = false
        } else {
            flipped[index] = true
        }
        carousel.reloadItem(at: index, animated: true)
    }
    override func viewDidLoad() {
        for _ in 0 ..< flashcards.count {
            flipped.append(false)
        }
        random = flashcards
        shuffle.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "fontAwesome", size: 24)!], for: UIControlState())
        shuffle.title = "\u{f074}"
        //self.navigationItem.rightBarButtonItem?.title = "\u{f074}"
        refresh.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "fontAwesome", size: 24)!], for: UIControlState())
        refresh.title = "\u{f021}"

        carousel.bounceDistance = 0.1
        carousel.decelerationRate = 0.2
        carousel.reloadData()

    }
    func numberOfItems(in carousel: iCarousel) -> Int {
        return flashcards.count
    }

    @IBAction func refresh(_ sender: AnyObject) {
        if isRandom {
            isRandom = false
            carousel.reloadData()
        }
    }

    @IBAction func shuffles(_ sender: AnyObject) {
        isRandom = true
        random.shuffleInPlace()
        carousel.reloadData()

    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault defaultValue: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            return 1.05

        default:
            return defaultValue
        }
    }
}
extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in 0..<count.advanced(by: -1).toIntMax() {
            let j = Int(arc4random_uniform(UInt32(count.toIntMax() - i))) + i
            guard i != j else { continue }
            swap(&self[Int(i)], &self[Int(j)])
        }
    }
}
class FlashcardTile: UIView {
    var flashcardView: FlashcardView

    override init(frame: CGRect) {
        self.flashcardView = FlashcardView(decoder: nil, frame: frame)
        super.init(frame: frame)
        self.addSubview(flashcardView)

    }

    required init?(coder aDecoder: NSCoder) {
        //We're never using this method to so fuck it 😁
        fatalError("init(coder:) has not been implemented")
    }

}
