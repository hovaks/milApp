//
//  CustomPresentAnimationController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let finalFrameForViewController = transitionContext.finalFrame(for: toViewController!)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        toViewController?.view.frame = finalFrameForViewController.offsetBy(dx: 0, dy: bounds.size.height)
        containerView.addSubview((toViewController?.view)!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        fromViewController?.view.alpha = 0.5
                        toViewController?.view.frame = finalFrameForViewController }) {
                            finished in
                            transitionContext.completeTransition(true)
                            fromViewController?.view.alpha = 1.0
        }
    }
    
}
