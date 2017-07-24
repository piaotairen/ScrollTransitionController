//
//  CBContainerViewControllerDelegate.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

@objc protocol ContainerViewControllerDelegate {
    func containerController(_ containerController: CBContainerViewController,  animationControllerForTransitionFromViewController fromVc: UIViewController, toViewController toVc: UIViewController) -> UIViewControllerAnimatedTransitioning?
    @objc optional func containerController(_ containerController: CBContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

class CBContainerViewControllerDelegate: NSObject, ContainerViewControllerDelegate {
    var interactionController = CBPercentDrivenInteractiveTransition()
    func containerController(_ containerController: CBContainerViewController, animationControllerForTransitionFromViewController fromVc: UIViewController, toViewController toVc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fromIndex = containerController.viewControllers!.index(of: fromVc)!
        let toIndex = containerController.viewControllers!.index(of: toVc)!
        let tabChangeDirection: TabOperationDirection = toIndex < fromIndex ? TabOperationDirection.left : TabOperationDirection.right
        let transitionType = CBTransitionType.tabTransition(tabChangeDirection)
        let slideAnimationController = CBSlideAnimationController(type: transitionType, bind:false)
        return slideAnimationController
    }

    func containerController(_ containerController: CBContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
