//
//  CBPercentDrivenInteractiveTransition.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

class CBPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    weak var containerTransitionContext: CBContainerTransitionContext?
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? CBContainerTransitionContext {
            containerTransitionContext = context
            containerTransitionContext?.activateInteractiveTransition()
        } else {
            fatalError("\(transitionContext) is not class or subclass of ContainerTransitionContext")
        }
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat){
        containerTransitionContext?.updateInteractiveTransition(percentComplete)
    }
    
    func cancelInteractiveTransition(){
        containerTransitionContext?.cancelInteractiveTransition()
    }
    
    func finishInteractiveTransition(){
        containerTransitionContext?.finishInteractiveTransition()
    }
}
