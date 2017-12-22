//
//  PulleyScrollAdapter.swift
//  Pulley
//
//  Created by Gautier Gédoux on 20/12/2017.
//  Copyright © 2017 52inc. All rights reserved.
//

import UIKit

class PulleyScrollAdapter: NSObject {
    
    // MARK: - data
    
    //properties
    let drawerScrollView: UIScrollView
    let childScrollView: UIScrollView
    
    var drawerScrollViewGestureStarted = false
    var drawerScrollViewGestureChanged = false
    var childScrollViewGestureStarted = false
    var childScrollViewGestureChanged = false
    
    let topInset: CGFloat
    var drawerScrollViewInitialOffsetForDrawer: CGFloat = 0
    var childScrollViewInitialOffsetForDrawer: CGFloat = 0
    var drawerScrollViewInitialOffsetForChild: CGFloat = 0
    var childScrollViewInitialOffsetForChild: CGFloat = 0
    
    let endOfScrollAnimator: PulleyEndOfScrollAnimator
    
    // MARK: - init
    
    init(drawerScrollView: UIScrollView,childScrollView: UIScrollView,topInset: CGFloat) {
        self.drawerScrollView = drawerScrollView
        self.childScrollView = childScrollView
        self.topInset = topInset
        endOfScrollAnimator = PulleyEndOfScrollAnimator(referenceView: childScrollView)
        super.init()
        
        self.drawerScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleDrawerScrollViewGesture(_:)))
        self.childScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleChildScrollViewGesture(_:)))
        
    }
    
    // MARK: - action
    
    @objc fileprivate func handleDrawerScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard drawerScrollView.contentOffset.y != drawerScrollView.maxContentOffset.y - topInset else { return }
            drawerScrollViewGestureStarted = true
            endOfScrollAnimator.removeAllBehaviors()
            drawerScrollViewInitialOffsetForDrawer = drawerScrollView.contentOffset.y
            childScrollViewInitialOffsetForDrawer = childScrollView.contentOffset.y
            
        case .changed:
            guard drawerScrollViewGestureStarted && drawerScrollView.contentOffset.y > drawerScrollView.maxContentOffset.y - topInset else { return }
            drawerScrollViewGestureChanged = true
            
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + drawerScrollView.contentOffset.y - drawerScrollViewInitialOffsetForDrawer
            print(padding)
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: childScrollViewInitialOffsetForDrawer - padding), animated: false)
            
        default:
            guard drawerScrollViewGestureStarted else { return }
            drawerScrollViewInitialOffsetForDrawer = 0
            childScrollViewInitialOffsetForDrawer = 0
            drawerScrollViewGestureStarted = false
            
            guard drawerScrollViewGestureChanged else { return }
            drawerScrollViewGestureChanged = false
            
            endOfScrollAnimator.animateEndOfScroll(for: gesture.velocity(in: gesture.view!))
        }
    }
    
    @objc fileprivate func handleChildScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            childScrollViewGestureStarted = true
            endOfScrollAnimator.removeAllBehaviors()
            childScrollViewInitialOffsetForChild = childScrollView.contentOffset.y
            drawerScrollViewInitialOffsetForChild = drawerScrollView.contentOffset.y
            
        case .changed:
            print(drawerScrollView.contentOffset.y)
            guard childScrollViewGestureStarted && (childScrollView.contentOffset.y + childScrollView.contentInset.top == 0 || drawerScrollView.contentOffset.y < drawerScrollView.maxContentOffset.y - topInset) else { return }
            childScrollViewGestureChanged = true
            
            if drawerScrollView.contentOffset.y < drawerScrollView.maxContentOffset.y - topInset && childScrollView.contentOffset.y + childScrollView.contentInset.top != 0 {
                childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: 0), animated: false)
            }
            
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + childScrollView.contentOffset.y - childScrollViewInitialOffsetForChild
            let offset = fmin(drawerScrollView.maxContentOffset.y - topInset,drawerScrollViewInitialOffsetForChild - padding)
            drawerScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: offset), animated: false)
            
        default:
            guard childScrollViewGestureStarted else { return }
            childScrollViewInitialOffsetForChild = 0
            drawerScrollViewInitialOffsetForChild = 0
            childScrollViewGestureStarted = false
            
            guard childScrollViewGestureChanged else { return }
            childScrollViewGestureChanged = false
            
            let targetContentOffset: UnsafeMutablePointer<CGPoint> = withUnsafeMutablePointer(to: &drawerScrollView.contentOffset) { $0 }
            drawerScrollView.delegate?.scrollViewWillEndDragging?(drawerScrollView, withVelocity: .zero, targetContentOffset: targetContentOffset)
            drawerScrollView.delegate?.scrollViewDidEndDragging?(drawerScrollView, willDecelerate: false)
        }
    }
}

