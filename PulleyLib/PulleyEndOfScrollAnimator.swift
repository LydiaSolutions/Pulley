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
    var springBehavior: UIAttachmentBehavior!

    
    var lastPointBeforeMaximumOffset: CGPoint = .zero
    var scrollViewCenter: CGPoint = .zero {
        didSet {
            let newContentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollViewCenter.y )

            addSpringIfNeeded(for: newContentOffset)
            
            scrollView.setContentOffset( newContentOffset, animated: false)
        }
    }
    
    var scrollView: UIScrollView {
        return referenceView as! UIScrollView
    }
    
    // MARK: - instance methods
    
    func animateEndOfScroll(for velocity: CGPoint) {
        guard decelerationBehavior == nil else { return }
        
        let updatedVelocity = CGPoint(x: -velocity.x, y: -velocity.y)
        scrollItem.center = scrollView.contentOffset

        decelerationBehavior = UIDynamicItemBehavior(items: [scrollItem])
        decelerationBehavior.addLinearVelocity(updatedVelocity, for: scrollItem)
        decelerationBehavior.resistance = 2
        decelerationBehavior.action = { [weak self] in
            self?.scrollViewCenter = self!.scrollItem.center
        }
        addBehavior(decelerationBehavior)
    }
    
    fileprivate func addSpringIfNeeded(for contentOffset: CGPoint) {
        guard decelerationBehavior != nil && springBehavior == nil && contentOffset.y > scrollView.maxContentOffset.y else { return }
        decelerationBehavior.resistance = 15
        
        springBehavior = UIAttachmentBehavior(item: scrollItem, attachedToAnchor: CGPoint(x: 1, y: scrollView.maxContentOffset.y))
        springBehavior.length = 0
        springBehavior.damping = 1
        springBehavior.frequency = 2
        
        addBehavior(springBehavior)
    }
    
    override func removeAllBehaviors() {
        super.removeAllBehaviors()
        decelerationBehavior = nil
        springBehavior = nil
    }
}
