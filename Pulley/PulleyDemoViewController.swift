//
//  PulleyDemoViewController.swift
//  Pulley
//
//  Created by Gautier Gédoux on 20/12/2017.
//  Copyright © 2017 52inc. All rights reserved.
//

import UIKit
import Pulley

class PulleyDemoViewController: PulleyViewController {
    
//    var hasStarted = false
//    var scrollViewInitialOffset: CGFloat = 0
//    var childScrollViewInitialOffset: CGFloat = 0
//
//    var childScrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawerAnimationDuration = 0.35
        drawerAnimationSpringDamping = 1
        drawerAnimationOptions = [.allowUserInteraction,.curveEaseInOut]
        shadowOpacity = 0
        backgroundDimmingColor = UIColor.clear
        drawerCornerRadius = 5

        addScrollBehavior(for: (drawerContentViewController as! DrawerContentViewController).tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("drawerScrollView.bounds.height \(drawerScrollView.bounds.height) drawerScrollView.contentSize.height \(drawerScrollView.contentSize.height) self.drawerContentViewController.view.frame.height \(self.drawerContentViewController.view.frame.height) self.drawerScrollView.contentOffset.y \(self.drawerScrollView.contentOffset.y)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        var location = gesture.location(in: presentedViewController?.view?.window)
//        location = location.applying(gesture.view!.transform.inverted())
//
//        let translation = gesture.translation(in: gesture.view!)
//
//
////        print("location \(location) translation \(translation)")
//
////        print("drawerScrollView.contentOffset.y \(drawerScrollView.contentOffset.y) translation \(translation)")
//
//        switch gesture.state {
//        case .began:
//            hasStarted = true
//            scrollViewInitialOffset = drawerScrollView.contentOffset.y
//            childScrollViewInitialOffset = childScrollView.contentOffset.y
//
//        case .changed:
//            guard hasStarted && drawerScrollView.contentOffset.y == 559 else { return }
////            print("translation.y \(translation.y) drawerScrollView.contentOffset.y \(drawerScrollView.contentOffset.y) scrollViewInitialOffset \(scrollViewInitialOffset)")
//            print(translation.y + drawerScrollView.contentOffset.y - scrollViewInitialOffset)
//            let padding = translation.y + drawerScrollView.contentOffset.y - scrollViewInitialOffset
//            childScrollView.setContentOffset(CGPoint(x: childScrollView.contentOffset.x,y: childScrollViewInitialOffset - padding), animated: false)
//
//        default:
//            guard hasStarted else { return }
//            scrollViewInitialOffset = 0
//            childScrollViewInitialOffset = 0
//            hasStarted = false
//
//        }
//    }
}
