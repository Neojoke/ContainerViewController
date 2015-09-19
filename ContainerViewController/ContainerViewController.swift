//
//  ContainerViewController.swift
//  ContainerViewController
//
//  Created by NEO on 15/9/9.
//  Copyright © 2015年 NEO. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController , UIViewControllerTransitioningDelegate{
    var viewControllers : [UIViewController] = [UIViewController]()
    enum Orientation{
        case Left,Right
    }
    
    @IBOutlet weak var container: ContainerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let first  = self.childViewControllers.first{
            self.viewControllers.append(first)
            for _ in 1...3{
                let contentViewController = UIViewController()
                contentViewController.view.backgroundColor = UIColor.yellowColor()
                viewControllers.append(contentViewController)
                
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //添加一个子视图控制器到容器中，并显示
    func displayContentController(content : UIViewController, frame : CGRect){
        self.addChildViewController(content)
        content.view.frame = frame
        container.addSubview(content.view)
        content.didMoveToParentViewController(self)
    }
    //滑动的手势，处理哪些子视图控制器切换
    @IBAction func swipe(sender: UISwipeGestureRecognizer) {
        var currentIndex : Int
        let currentViewController = self.childViewControllers.first
        if currentViewController != nil {
            currentIndex = self.viewControllers.indexOf(currentViewController!)!
        }
        else
        {
            return
        }
        
        if sender.direction == UISwipeGestureRecognizerDirection.Left{
            if currentIndex == viewControllers.count-1{
                return
            }
            else{
                swipeFromViewController(currentViewController!, ToViewController: viewControllers[currentIndex+1], WithOrientation: Orientation.Left)
            }
        }
        else
        {
            if currentIndex == 0{
                return
            }
            else
            {
                swipeFromViewController(currentViewController!, ToViewController: viewControllers[currentIndex-1], WithOrientation: Orientation.Right)
            }
        }
    }
    //子视图控制器之间的转场切换
    func swipeFromViewController(fromViewController:UIViewController,ToViewController toViewController:UIViewController, WithOrientation orientation:Orientation){
        //fromViewController.willMoveToParentViewController(nil)
//        self.addChildViewController(toViewController)
//        toViewController.view.bounds = container.bounds
//        let endCenter:CGPoint;
//        fromViewController.transitioningDelegate = self;
//        if orientation == Orientation.Left{
//            toViewController.view.center = CGPointMake(self.view.bounds.size.width + toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
//            endCenter = CGPointMake(-self.view.bounds.size.width - toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
//        }
//        else
//        {
//            toViewController.view.center = CGPointMake(-self.view.bounds.size.width - toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
//            endCenter = CGPointMake(self.view.bounds.size.width + toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
//        }
//        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//            toViewController.view.frame = fromViewController.view.frame
//            fromViewController.view.center = endCenter
//            }) { (completion) -> Void in
//                toViewController.didMoveToParentViewController(self)
//                fromViewController.removeFromParentViewController()
//        }

        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        let context = CustomTransitionContext(containerView: container, toViewController: toViewController, fromViewController: fromViewController)
        context.completeHandle = {
            (isComplete : Bool) -> Void in
            toViewController.didMoveToParentViewController(self)
            fromViewController.removeFromParentViewController()
        }
        let animator = CustomTransitionAnimtor(context: context)
        animator.orientaion = orientation
        animator.animateTransition(context)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimtor(context: CustomTransitionContext(containerView: container, toViewController: presenting, fromViewController: presented))
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
@IBDesignable
class ContainerView: UIView {
    @IBInspectable
    var cornerRadius : CGFloat = 0.0{
        didSet{
            
            
        }
    }
    override func layoutSubviews() {
        
        let roundRectLayer = CAShapeLayer()
        roundRectLayer.bounds = self.layer.bounds
        roundRectLayer.frame = self.layer.bounds
        roundRectLayer.path = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: cornerRadius).CGPath
        self.layer.mask = roundRectLayer
        self.clipsToBounds = false
        
    }
}
class CustomTransitionContext: NSObject , UIViewControllerContextTransitioning {
    weak var customContainerView : UIView?
    private weak var toViewController:UIViewController?
    private weak var fromViewController:UIViewController?
    internal var completeHandle : ((isComplete : Bool)->Void)?;
    var animating : Bool = true
    func isAnimated() -> Bool {
        return animating
    }
    func isInteractive() -> Bool {
        return false
    }
    func transitionWasCancelled() -> Bool {
        return false
    }
    func presentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.Custom
    }
    func completeTransition(didComplete: Bool) {
        if let handler = completeHandle {
            animating = false
            handler(isComplete: didComplete)
        }
    }
    func updateInteractiveTransition(percentComplete: CGFloat) {
        
    }
    func finishInteractiveTransition() {
        
    }
    func cancelInteractiveTransition() {
        
    }
    func viewControllerForKey(key: String) -> UIViewController? {
        switch key{
        case UITransitionContextFromViewControllerKey:
            return fromViewController
        case UITransitionContextToViewControllerKey:
            return toViewController
        default:
            return nil
        }
    }
    @available(iOS 8.0,*)
    func viewForKey(key: String) -> UIView? {
        switch key{
        case UITransitionContextFromViewKey:
            return fromViewController?.view
        case UITransitionContextToViewKey:
            return toViewController?.view
        default:
            return nil
        }
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect {
        return CGRectZero
    }
    
    func initialFrameForViewController(vc: UIViewController) -> CGRect {
        return CGRectZero
    }
    func containerView() -> UIView? {
        return self.customContainerView
    }
    
    convenience init(containerView : UIView? ,toViewController : UIViewController , fromViewController : UIViewController){
        self.init()
        self.toViewController = toViewController
        self.fromViewController = fromViewController
        self.customContainerView = containerView
    }
    
    func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }
}

class CustomTransitionAnimtor: NSObject , UIViewControllerAnimatedTransitioning {
    internal var orientaion : ContainerViewController.Orientation = ContainerViewController.Orientation.Left
    var toViewController : UIViewController?
    var fromViewController : UIViewController?
    var privateContext : CustomTransitionContext;
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    init(context : CustomTransitionContext){
        privateContext = context
        super.init()
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = privateContext.containerView()
        let toViewController = privateContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = privateContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        toViewController?.view.bounds = (fromViewController?.view.bounds)!
        var endCenter : CGPoint;
        if orientaion == ContainerViewController.Orientation.Left{
            endCenter = CGPointMake(-(fromViewController?.view.bounds.size.width)!, (containerView?.bounds.size.height)!/2)
            toViewController?.view.center = CGPointMake((containerView?.bounds.size.width)! + (toViewController?.view.bounds.width)!/2, (containerView?.bounds.height)!/2)
        }
        else
        {
            endCenter = CGPointMake((containerView?.bounds.size.width)! + (fromViewController?.view.bounds.size.width)!/2, (containerView?.bounds.size.height)!/2)
            toViewController?.view.center = CGPointMake(-(containerView?.bounds.size.width)! - (toViewController?.view.bounds.width)!/2, (containerView?.bounds.height)!/2)
        }
        containerView?.addSubview((toViewController?.view)!)
        UIView.animateWithDuration(self.transitionDuration(privateContext), animations: { () -> Void in
            toViewController?.view.center = (fromViewController?.view.center)!
            fromViewController?.view.center = endCenter
            }) { (isComplection) -> Void in
                fromViewController?.view.removeFromSuperview()
                self.animationEnded(true)
        }
    }
    func animationEnded(transitionCompleted: Bool) {
        self.privateContext.completeTransition(true)
    }
    
}