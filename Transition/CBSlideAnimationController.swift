//
//  CBSlideAnimationController.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

enum CBTransitionType {
    case navigationTransition(UINavigationControllerOperation)
    case tabTransition(TabOperationDirection)
    case modalTransition(ModalOperation)
}

enum TabOperationDirection {
    case left, right
}

enum ModalOperation {
    case presentation, dismissal
}

class CBSlideAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate var transitionType: CBTransitionType
    fileprivate var transitionBind: Bool
    
    init(type: CBTransitionType, bind:Bool) {
        transitionType = type
        transitionBind = bind
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        let fromView = fromVC.view
        let toView = toVC.view
        var translation = containerView.frame.width
        var toViewTransform = CGAffineTransform.identity
        var fromViewTransform = CGAffineTransform.identity
        
        switch transitionType {
        case .navigationTransition(let operation):
            translation = operation == .push ? translation : -translation
            toViewTransform = CGAffineTransform(translationX: translation, y: 0)
            fromViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .tabTransition(let direction):
            translation = direction == .left ? translation : -translation
            fromViewTransform = CGAffineTransform(translationX: translation, y: 0)
            toViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .modalTransition(let operation):
            translation =  containerView.frame.height
            toViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? translation : 0))
            fromViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? 0 : translation))
        }
        
        switch transitionType {
        case .modalTransition(let operation):
            switch operation {
            case .presentation:
                containerView.addSubview(toView!)
            case .dismissal:
                break
            }
        default:
            containerView.addSubview(toView!)
        }
        
        toView?.transform = toViewTransform
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if (self.transitionBind) {
                fromView?.transform = fromViewTransform
            }
            toView?.transform = CGAffineTransform.identity
        }, completion: { finished in
            fromView?.transform = CGAffineTransform.identity
            toView?.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
