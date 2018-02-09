//
//  PulleyEndOfScrollAnimator.swift
//  Pulley
//
//  Created by Gautier Gédoux on 21/12/2017.
//  Copyright © 2017 52inc. All rights reserved.
//

import UIKit

class PulleyEndOfScrollAnimator: UIDynamicAnimator {
    
    // MARK: - class
    
    class PulleyScrollItem: NSObject, UIDynamicItem {
        var center: CGPoint
        var bounds: CGRect
        var transform: CGAffineTransform
        
        override init() {
            center = .zero
            bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
            transform = .identity
        }
    }
    
    // MARK: - data
    
    //properties
    let scrollItem = PulleyScrollItem()
    
    var decelerationBehavior: UIDynamicItemBehavior!
    
    var lastPointBeforeMaximumOffset: CGPoint = .zero
    var scrollViewCenter: CGPoint = .zero {
        didSet {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollViewCenter.y ), animated: false)
        }
    }
    
    var scrollView: UIScrollView {
        return referenceView as! UIScrollView
    }
    
    // MARK: - instance methods
    
    func animateEndOfScroll(for velocity: CGPoint) {
        guard decelerationBehavior == nil && fabs(velocity.y) > 100 else { return }
        
        let updatedVelocity = CGPoint(x: -velocity.x, y: -velocity.y)
        scrollItem.center = referenceView?.center ?? .zero
        
        decelerationBehavior = UIDynamicItemBehavior(items: [scrollItem])
        decelerationBehavior.addLinearVelocity(updatedVelocity, for: scrollItem)
        decelerationBehavior.resistance = 2
        decelerationBehavior.action = { [weak self] in
            guard let strongSelf = self else { return }
            let minOffsetY = fmin(strongSelf.scrollItem.center.y,strongSelf.scrollView.maxContentOffset.y)
            strongSelf.scrollViewCenter = CGPoint(x: strongSelf.scrollViewCenter.x, y: minOffsetY)
        }
        addBehavior(decelerationBehavior)
    }
    
    override func removeAllBehaviors() {
        super.removeAllBehaviors()
        decelerationBehavior = nil
    }
}
