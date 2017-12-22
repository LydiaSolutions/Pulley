//
//  UIScrollView+Extension.swift
//  Pulley
//
//  Created by Gautier Gédoux on 21/12/2017.
//  Copyright © 2017 52inc. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var maxContentOffset: CGPoint {
        return CGPoint(x: contentSize.width - bounds.width, y: contentSize.height - bounds.height)
    }
    
}
