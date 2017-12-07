//
//  PulleyPassthroughScrollView.swift
//  Pulley
//
//  Created by Brendan Lee on 7/6/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit

protocol PulleyPassthroughScrollViewDelegate: class {
    
    func shouldTouchPassthroughScrollView(scrollView: PulleyPassthroughScrollView, point: CGPoint) -> Bool
    func viewToReceiveTouch(scrollView: PulleyPassthroughScrollView, point: CGPoint) -> UIView
}

public class PulleyPassthroughScrollView: UIScrollView {
    
    weak var touchDelegate: PulleyPassthroughScrollViewDelegate?
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let touchDel = touchDelegate
        {
            if touchDel.shouldTouchPassthroughScrollView(scrollView: self, point: point)
            {
                return touchDel.viewToReceiveTouch(scrollView: self, point: point).hitTest(touchDel.viewToReceiveTouch(scrollView: self, point: point).convert(point, from: self), with: event)
            }
        }
        
        return super.hitTest(point, with: event)
    }
}
