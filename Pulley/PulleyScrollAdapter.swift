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

    var drawerScrollViewInitialOffsetForDrawer: CGFloat = 0
    var childScrollViewInitialOffsetForDrawer: CGFloat = 0
    var drawerScrollViewInitialOffsetForChild: CGFloat = 0
    var childScrollViewInitialOffsetForChild: CGFloat = 0
    
    //constants
    
    // MARK: - init
    
    init(drawerScrollView: UIScrollView,childScrollView: UIScrollView) {
        self.drawerScrollView = drawerScrollView
        self.childScrollView = childScrollView
        super.init()
        
        configure()
    }
    
    // MARK: - instance methods
    
    func configure() {
        self.drawerScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleDrawerScrollViewGesture(_:)))
        self.childScrollView.panGestureRecognizer.addTarget(self, action: #selector(handleChildScrollViewGesture(_:)))

    }
    
    // MARK: - action
    
    @objc fileprivate func handleDrawerScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            drawerScrollViewGestureStarted = true
            drawerScrollViewInitialOffsetForDrawer = drawerScrollView.contentOffset.y
            childScrollViewInitialOffsetForDrawer = childScrollView.contentOffset.y
            
        case .changed:
            guard drawerScrollViewGestureStarted && drawerScrollView.contentOffset.y == 559 else { return }
            print("translation \(gesture.translation(in: gesture.view!)) velocity \(gesture.velocity(in: gesture.view!))")

            drawerScrollViewGestureChanged = true
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + drawerScrollView.contentOffset.y - drawerScrollViewInitialOffsetForDrawer
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: childScrollViewInitialOffsetForDrawer - padding), animated: false)
            
        default:
            guard drawerScrollViewGestureStarted else { return }
            drawerScrollViewInitialOffsetForDrawer = 0
            childScrollViewInitialOffsetForDrawer = 0
            drawerScrollViewGestureStarted = false
            
            guard drawerScrollViewGestureChanged else { return }
            drawerScrollViewGestureChanged = false
            print("drawerScrollViewGestureChanged translation \(gesture.translation(in: gesture.view!)) velocity \(gesture.velocity(in: gesture.view!))")

            let velocity = gesture.translation(in: gesture.view!)
            
            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: childScrollView.contentOffset.y - velocity.y), animated: true)
        }
    }
    
    @objc fileprivate func handleChildScrollViewGesture(_ gesture: UIPanGestureRecognizer) {
//        print(childScrollView.contentOffset.y)
        switch gesture.state {
        case .began:
            childScrollViewGestureStarted = true
            childScrollViewInitialOffsetForChild = childScrollView.contentOffset.y
            drawerScrollViewInitialOffsetForChild = drawerScrollView.contentOffset.y
            
        case .changed:
            guard childScrollViewGestureStarted && childScrollView.contentOffset.y == 0 else { return }
            childScrollViewGestureChanged = true
            
            let translation = gesture.translation(in: gesture.view!)
            let padding = translation.y + childScrollView.contentOffset.y - childScrollViewInitialOffsetForChild
            drawerScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: drawerScrollViewInitialOffsetForChild - padding), animated: false)
            
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
