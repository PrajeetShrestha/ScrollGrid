//
//  GridLabel.swift
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/7/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

import UIKit

@objc class GridLabel: UILabel {    
    @objc convenience init(labelTitle: String, frame:CGRect) {
        self.init(frame:frame)
        textColor = UIColor.groupTableViewBackgroundColor()
        //        clipsToBounds = true
        text = "\(labelTitle)"
        sizeToFit()
        backgroundColor = UIColor(red: 97/255, green: 128/255, blue: 185/255, alpha: 1)
        layer.cornerRadius = 5.0
        clipsToBounds = true
//        var path:UIBezierPath = UIBezierPath(rect:bounds)
//        layer.shadowColor = UIColor.whiteColor().CGColor
//        layer.shadowOffset = CGSize(width:2,height:2)
//        layer.shadowOpacity = 0.6
//        layer.shadowPath = path.CGPath
    }

}
