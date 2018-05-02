//
//  CBScrollTabBarViewController.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class CBScrollTabBarViewController: CBContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CBScrollTabBarViewController.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if viewControllers == nil || viewControllers?.count < 2 || containerTransitionDelegate == nil || !(containerTransitionDelegate is CBContainerViewControllerDelegate) {
            return;
        }
        let delegate = containerTransitionDelegate as! CBContainerViewControllerDelegate
        let translationX =  gesture.translation(in: view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        
        switch gesture.state {
        case .began:
            interactive = true
            let velocityX = gesture.velocity(in: view).x
            if velocityX < 0 {
                if selectedIndex < viewControllers!.count - 1 {
                    selectedIndex += 1
                }
            } else {
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
            }
        case .changed:
            delegate.interactionController.updateInteractiveTransition(progress)
        case .cancelled, .ended:
            interactive = false
            if progress > 0.4 {
                delegate.interactionController.finishInteractiveTransition()
            } else {
                delegate.interactionController.cancelInteractiveTransition()
            }
        default: break
        }
    }
}
