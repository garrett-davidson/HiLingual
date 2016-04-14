//
//  BubbleView.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class BubbleView: UIView {
    override func drawRect(rect: CGRect) {
            
            var bubbleSpace = CGRectMake(rect.origin.x - 5, rect.origin.y, rect.width + 10, rect.height)
            let bubblePath1 = UIBezierPath(roundedRect: bubbleSpace, byRoundingCorners: [.TopLeft,.TopRight,.BottomRight,.BottomLeft], cornerRadii: CGSize(width: 20.0, height: 20.0))
            
            let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 5.0)
            
            UIColor.orangeColor().setStroke()
            UIColor.orangeColor().setFill()
            bubblePath.stroke()
            bubblePath.fill()

    }

}
