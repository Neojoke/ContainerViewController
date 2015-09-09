//
//  ContainerViewController.swift
//  ContainerViewController
//
//  Created by NEO on 15/9/9.
//  Copyright © 2015年 NEO. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
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
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        toViewController.view.bounds = container.bounds
        let endCenter:CGPoint;
        if orientation == Orientation.Left{
            toViewController.view.center = CGPointMake(self.view.bounds.size.width + toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
            endCenter = CGPointMake(-self.view.bounds.size.width - toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
        }
        else
        {
            toViewController.view.center = CGPointMake(-self.view.bounds.size.width - toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
            endCenter = CGPointMake(self.view.bounds.size.width + toViewController.view.bounds.size.width/2, self.view.bounds.size.height/2)
        }
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            toViewController.view.frame = fromViewController.view.frame
            fromViewController.view.center = endCenter
            }) { (completion) -> Void in
                toViewController.didMoveToParentViewController(self)
                fromViewController.removeFromParentViewController()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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