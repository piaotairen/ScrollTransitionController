//
//  CBContainerViewController.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

/// 屏幕宽
let kScreenWidth = UIScreen.main.bounds.size.width

/// 屏幕高
let kScreenHeight = UIScreen.main.bounds.size.height

class CBContainerViewController: UIViewController {
    
    //MARK: Normal Property
    fileprivate let kScrollTabBarHeight: CGFloat = 80.0
    
    fileprivate let kButtonMaxDiameter: CGFloat = 61.0
    
    fileprivate let kButtonMinDiameter: CGFloat = 48.0
    
    fileprivate let privateContainerView = UIView()
    
    let containerTabBar = UIView()
    
    fileprivate var buttonTitles: [String] = []
    
    //MARK: Property for Transition
    var interactive = false
    
    weak var containerTransitionDelegate: ContainerViewControllerDelegate?
    
    fileprivate var containerTransitionContext: CBContainerTransitionContext?
    
    //MARK: Property like UITabBarController
    //set viewControllers need more code and test, so keep this private in this demo.
    fileprivate(set) var viewControllers: [UIViewController]?
    
    fileprivate(set) var buttonIcons: [String] = []
    
    fileprivate var shouldReserve = false
    
    fileprivate var priorSelectedIndex: Int = NSNotFound
    
    var homeIndex: Int = NSNotFound
    
    var selectedIndex: Int = NSNotFound {
        willSet {
            if shouldReserve {
                shouldReserve = false
            } else {
                transitionViewControllerFromIndex(selectedIndex, toIndex: newValue)
            }
        }
    }
    
    var selectedViewController: UIViewController? {
        get {
            if self.viewControllers == nil || selectedIndex < 0 || selectedIndex >= viewControllers!.count {
                return nil
            }
            return self.viewControllers![selectedIndex]
        }
        set {
            if viewControllers == nil{
                return
            }
            if let index = viewControllers!.index(of: selectedViewController!){
                selectedIndex = index
            } else {
                print("The view controller is not in the viewControllers")
            }
        }
    }
    
    //MARK: Class Life Method
    init(viewControllers: [UIViewController], icons:[String]) {
        assert(viewControllers.count > 0, "can't init with 0 child VC")
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        self.buttonIcons = icons
        
        for childVC in viewControllers {
            let title = childVC.title != nil ? childVC.title! : "Lazy"
            buttonTitles.append(title)
            //适应屏幕旋转的最简单的办法，在转场开始前设置子 view 的尺寸为容器视图的尺寸。
            childVC.view.translatesAutoresizingMaskIntoConstraints = true
            childVC.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: CBContainerTransitionEndNotification), object: nil, queue: nil, using: { _ in
            self.containerTransitionContext = nil
            self.containerTabBar.isUserInteractionEnabled = true
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't support init from storyboar in this demo")
        //super.init(coder: aDecoder)
    }
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor.black
        rootView.isOpaque = true
        self.view = rootView
        
        privateContainerView.translatesAutoresizingMaskIntoConstraints = false
        privateContainerView.backgroundColor = UIColor.black
        privateContainerView.isOpaque = true
        rootView.addSubview(privateContainerView)
        
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .width, relatedBy: .equal, toItem: rootView, attribute: .width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .height, relatedBy: .equal, toItem: rootView, attribute: .height, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .left, relatedBy: .equal, toItem: rootView, attribute: .left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: 0))
        
        containerTabBar.translatesAutoresizingMaskIntoConstraints = false
        containerTabBar.backgroundColor = UIColor.clear
        containerTabBar.tintColor = UIColor.clear
        rootView.addSubview(containerTabBar)
        
        rootView.addConstraint(NSLayoutConstraint(item: containerTabBar, attribute: .width, relatedBy: .equal, toItem: privateContainerView, attribute: .width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: containerTabBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: kScrollTabBarHeight))
        rootView.addConstraint(NSLayoutConstraint(item: containerTabBar, attribute: .centerX, relatedBy: .equal, toItem: privateContainerView, attribute: .centerX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: containerTabBar, attribute: .bottom, relatedBy: .equal, toItem: privateContainerView, attribute: .bottom, multiplier: 1, constant: 0))
        
        addChildViewControllerButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Setting this property in other method before this one will make a bug: when you go back to this initial selectedIndex, no transition animation.
        if viewControllers != nil && viewControllers!.count > 0 && selectedIndex == NSNotFound {
            selectedIndex = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Restore data and change button appear
    func restoreSelectedIndex() {
        shouldReserve = true
        selectedIndex = priorSelectedIndex
    }
    
    //Only work in interactive transition
    func graduallyChangeTabButtonAppearWith(_ fromIndex: Int, toIndex: Int, percent: CGFloat) {
        let middleButton: UIButton = containerTabBar.subviews[fromIndex] as! UIButton
        let middleMargin = middleTranslationX()
        let changeIndex = CGFloat(homeIndex - fromIndex);
        if fromIndex < toIndex {
            //👈-》👉
            let middleBounds = kButtonMaxDiameter * (1.0 - ((kButtonMaxDiameter - kButtonMinDiameter) / kButtonMaxDiameter) * percent)
            middleButton.bounds = CGRect(x: 0, y: 0, width: middleBounds, height: middleBounds)
            let rightButton = containerTabBar.subviews[toIndex] as! UIButton
            let rightBounds = kButtonMinDiameter * (1.0 + ((kButtonMaxDiameter - kButtonMinDiameter) / kButtonMinDiameter) * percent)
            rightButton.bounds = CGRect(x: 0, y: 0, width: rightBounds, height: rightBounds)
            
            for (index, _) in buttonIcons.enumerated() {
                let button = containerTabBar.subviews[index] as! UIButton
                button.transform = CGAffineTransform(translationX: middleMargin * (changeIndex - percent), y: 0)
            }
        } else {
            //👉-》👈
            let middleBounds = kButtonMaxDiameter * (1.0 - ((kButtonMaxDiameter - kButtonMinDiameter) / kButtonMaxDiameter) * percent)
            middleButton.bounds = CGRect(x: 0, y: 0, width: middleBounds, height: middleBounds)
            let leftButton = containerTabBar.subviews[toIndex] as! UIButton
            let leftBounds = kButtonMinDiameter * (1.0 + ((kButtonMaxDiameter - kButtonMinDiameter) / kButtonMinDiameter) * percent)
            leftButton.bounds = CGRect(x: 0, y: 0, width: leftBounds, height: leftBounds)
            
            for (index, _) in buttonIcons.enumerated() {
                let button = containerTabBar.subviews[index] as! UIButton
                button.transform = CGAffineTransform(translationX:  middleMargin * (changeIndex + percent), y: 0)
            }
        }
    }
    
    //Only work in containerTabBar button tap
    func changeTabButtonAnimateWith(_ fromIndex: Int, toIndex: Int) {
        UIView.animate(withDuration: 0.3) {
            self.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 1)
        }
    }
    
    //MARK: Private Helper Method
    fileprivate func middleTranslationX() -> CGFloat {
        return (kScreenWidth - 2 * kButtonMinDiameter - kButtonMaxDiameter) / 3 + (kButtonMinDiameter + kButtonMaxDiameter) / 2
    }

//    fileprivate func middleTranslationX() -> CGFloat {
//        
//    }
    
    fileprivate func addChildViewControllerButtons() {
        for (index, buttonIcon) in buttonIcons.enumerated() {
            let button = UIButton(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
            button.backgroundColor = UIColor.clear
            button.setImage(UIImage(named:buttonIcon), for: UIControlState.normal)
            button.imageView?.contentMode = UIViewContentMode.scaleAspectFit;
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(CBContainerViewController.TabButtonTapped(_:)), for: .touchUpInside)
            containerTabBar.addSubview(button)
            
            var buttonDiameter: CGFloat
            if index == selectedIndex {
                buttonDiameter = kButtonMaxDiameter
            } else {
                buttonDiameter = kButtonMinDiameter
            }
            let middleMargin = (kScreenWidth - 2 * kButtonMinDiameter - kButtonMaxDiameter) / 3 + (kButtonMinDiameter + kButtonMaxDiameter) / 2
            let centerX = CGFloat(index - selectedIndex) * middleMargin;
            containerTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonDiameter))
            containerTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonDiameter))
            containerTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: containerTabBar, attribute: .centerX, multiplier: 1, constant: centerX))
            containerTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: containerTabBar, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
    
    @objc
    fileprivate func TabButtonTapped(_ button: UIButton) {
        if let tappedIndex = containerTabBar.subviews.index(of: button), tappedIndex != selectedIndex {
            changeTabButtonAnimateWith(selectedIndex, toIndex: tappedIndex)
            selectedIndex = tappedIndex
        }
    }
    
    fileprivate func changeTabButtonAppearAtIndex(_ selectedIndex: Int) {
        for (index, subView) in containerTabBar.subviews.enumerated() {
            let button = subView as! UIButton
            if index != selectedIndex {
                button.setTitleColor(UIColor.white, for: UIControlState())
            } else {
                button.setTitleColor(UIColor.red, for: UIControlState())
            }
        }
    }
    
    fileprivate func transitionViewControllerFromIndex(_ fromIndex: Int, toIndex: Int) {
        if viewControllers == nil || fromIndex == toIndex || fromIndex < 0 || toIndex < 0 || toIndex >= viewControllers!.count || (fromIndex >= viewControllers!.count && fromIndex != NSNotFound) {
            return
        }
        //called when init
        if fromIndex == NSNotFound {
            let selectedVC = viewControllers![toIndex]
            addChildViewController(selectedVC)
            privateContainerView.addSubview(selectedVC.view)
            selectedVC.didMove(toParentViewController: self)
            changeTabButtonAppearAtIndex(toIndex)
            return
        }
        if containerTransitionDelegate != nil {
            containerTabBar.isUserInteractionEnabled = false
            
            let fromVC = viewControllers![fromIndex]
            let toVC = viewControllers![toIndex]
            containerTransitionContext = CBContainerTransitionContext(containerViewController: self, containerView: privateContainerView, fromViewController: fromVC, toViewController: toVC)
            
            if interactive {
                priorSelectedIndex = fromIndex
                containerTransitionContext?.startInteractiveTranstionWith(containerTransitionDelegate!)
            } else {
                containerTransitionContext?.startNonInteractiveTransitionWith(containerTransitionDelegate!)
                changeTabButtonAppearAtIndex(toIndex)
            }
        } else {
            //Transition Without Animation
            let priorSelectedVC = viewControllers![fromIndex]
            priorSelectedVC.willMove(toParentViewController: nil)
            priorSelectedVC.view.removeFromSuperview()
            priorSelectedVC.removeFromParentViewController()
            
            let newSelectedVC = viewControllers![toIndex]
            addChildViewController(newSelectedVC)
            privateContainerView.addSubview(newSelectedVC.view)
            newSelectedVC.didMove(toParentViewController: self)
            
            changeTabButtonAppearAtIndex(toIndex)
        }
    }
}
