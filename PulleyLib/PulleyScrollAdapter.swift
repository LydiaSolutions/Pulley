//
//  PulleyScrollAdapter.swift
//  Pulley
//
//  Created by Gautier Gédoux on 20/12/2017.
//  Copyright © 2017 52inc. All rights reserved.
//

import UIKit

class PulleyScrollAdapter {
    
    // MARK: - data
    
    //properties
    let drawerScrollView: UIScrollView
    let childScrollView: UIScrollView
    
    var scrollViewGestureStarted = false
    var scrollViewGestureChanged = false
    
    let topInset: CGFloat
    var drawerScrollViewInitialOffset: CGFloat = 0
    var childScrollViewInitialOffset: CGFloat = 0
    
    let endOfScrollAnimator: PulleyEndOfScrollAnimator
    
    // MARK: - init
    
    init(drawerScrollView: UIScrollView,childScrollView: UIScrollView,topInset: CGFloat) {
        self.drawerScrollView = drawerScrollView
        self.childScrollView = childScrollView
        self.topInset = topInset
        endOfScrollAnimator = PulleyEndOfScrollAnimator(referenceView: childScrollView)
        self.drawerScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleDrawerScrollViewGesture(_:)))
        self.childScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleChildScrollViewGesture(_:)))
    }
    
    // MARK: - instance method
    
    fileprivate func handleGesture(for state: UIGestureRecognizerState,began: () -> Void = { },changed: () -> Void,ended: () -> Void) {
        guard childScrollView.maxContentOffset.y > 0 else { return }
        
        switch state {
        case .began:
            scrollViewGestureStarted = true
            endOfScrollAnimator.removeAllBehaviors()
            drawerScrollViewInitialOffset = drawerScrollView.contentOffset.y
            childScrollViewInitialOffset = childScrollView.contentOffset.y
            began()
            
        case .changed:
            changed()
            
        default:
            guard scrollViewGestureStarted else { return }
            drawerScrollViewInitialOffset = 0
            childScrollViewInitialOffset = 0
            scrollViewGestureStarted = false
            
            guard scrollViewGestureChanged  else { return }
            scrollViewGestureChanged = false
            ended()
        }
    }
    
    // MARK: - action
    
    @objc fileprivate func handleDrawerScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
        guard (gesture.state != .began || drawerScrollView.contentOffset.y != drawerScrollView.maxContentOffset.y - topInset) else { return }
        
        handleGesture(for: gesture.state, began: {
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: childScrollView.contentInset.top), animated: true)
        }, changed: {
            guard scrollViewGestureStarted && drawerScrollView.contentOffset.y >= drawerScrollView.maxContentOffset.y - topInset else { return }
            scrollViewGestureChanged = true
            
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + drawerScrollView.contentOffset.y - drawerScrollViewInitialOffset
            let offset = fmin(childScrollViewInitialOffset - padding, childScrollView.maxContentOffset.y)
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: offset), animated: false)
        }) {
            guard drawerScrollView.contentOffset.y == drawerScrollView.maxContentOffset.y && childScrollView.canScrollDown  else { return }
            
            endOfScrollAnimator.animateEndOfScroll(for: gesture.velocity(in: gesture.view!))
        }
    }
    
    @objc fileprivate func handleChildScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
        handleGesture(for: gesture.state, changed: {
            guard scrollViewGestureStarted && (childScrollView.isAtOrigin || drawerScrollView.canScrollDown) else { return }
            scrollViewGestureChanged = true
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: 0), animated: false)
            
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + childScrollView.contentOffset.y - childScrollViewInitialOffset
            let offset = fmin(drawerScrollView.maxContentOffset.y,drawerScrollViewInitialOffset - padding)
            drawerScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: offset), animated: false)
        }) {
            guard drawerScrollView.contentOffset.y < drawerScrollView.maxContentOffset.y - topInset && childScrollView.isAtOrigin else { return }
            
            let targetContentOffset: UnsafeMutablePointer<CGPoint> = withUnsafeMutablePointer(to: &drawerScrollView.contentOffset) { $0 }
            targetContentOffset.pointee = drawerScrollView.contentOffset
            drawerScrollView.delegate?.scrollViewWillEndDragging?(drawerScrollView, withVelocity: .zero, targetContentOffset: targetContentOffset)
            drawerScrollView.delegate?.scrollViewDidEndDragging?(drawerScrollView, willDecelerate: false)
        }
    }
}

// MARK: - UIScrollView+Extension

extension UIScrollView {
    var maxContentOffset: CGPoint {
        if #available(iOS 11, *) {
            return CGPoint(x: contentSize.width - bounds.width + contentInset.right + safeAreaInsets.right, y: contentSize.height - bounds.height + contentInset.bottom + safeAreaInsets.bottom)
        } else {
            return CGPoint(x: contentSize.width - bounds.width + contentInset.right, y: contentSize.height - bounds.height + contentInset.bottom)
        }
    }
    
    var canScrollDown: Bool {
        return contentOffset.y < maxContentOffset.y
    }
    
    var isAtOrigin: Bool {
        return contentOffset.y + contentInset.top == 0
    }
    
    var isAtMaximumOffset: Bool {
        return contentOffset.y == maxContentOffset.y
    }
}
