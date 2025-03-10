//
//  IQUIView+Hierarchy.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

/**
UIView hierarchy category.
*/
public extension UIView {

    ///----------------------
    /// MARK: viewControllers
    ///----------------------

    /**
    Returns the UIViewController object that manages the receiver.
    */
    @objc public func viewContainingController()->UIViewController? {

        var nextResponder: UIResponder? = self

        repeat {
            nextResponder = nextResponder?.next

            if let viewController = nextResponder as? UIViewController {
                return viewController
            }

        } while nextResponder != nil

        return nil
    }

    /**
    Returns the topMost UIViewController object in hierarchy.
    */
    @objc public func topMostController()->UIViewController? {

        var controllersHierarchy = [UIViewController]()

        if var topController = window?.rootViewController {
            controllersHierarchy.append(topController)

            while let presented = topController.presentedViewController {

                topController = presented

                controllersHierarchy.append(presented)
            }

            var matchController :UIResponder? = viewContainingController()

            while matchController != nil && controllersHierarchy.contains(matchController as! UIViewController) == false {

                repeat {
                    matchController = matchController?.next

                } while matchController != nil && matchController is UIViewController == false
            }

            return matchController as? UIViewController

        } else {
            return viewContainingController()
        }
    }

    /**
     Returns the UIViewController object that is actually the parent of this object. Most of the time it's the viewController object which actually contains it, but result may be different if it's viewController is added as childViewController of another viewController.
     */
    @objc public func parentContainerViewController()->UIViewController? {

        var matchController = viewContainingController()
        var parentContainerViewController : UIViewController?

        if var navController = matchController?.navigationController {

            while let parentNav = navController.navigationController {
                navController = parentNav
            }

            var parentController : UIViewController = navController

            while let parent = parentController.parent,
                (parent.isKind(of: UINavigationController.self) == false &&
                    parent.isKind(of: UITabBarController.self) == false &&
                    parent.isKind(of: UISplitViewController.self) == false) {

                        parentController = parent
            }

            if navController == parentController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = parentController
            }
        }
        else if let tabController = matchController?.tabBarController {

            if let navController = tabController.selectedViewController as? UINavigationController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = tabController.selectedViewController
            }
        } else {
            while let parentController = matchController?.parent,
                (parentController.isKind(of: UINavigationController.self) == false &&
                    parentController.isKind(of: UITabBarController.self) == false &&
                    parentController.isKind(of: UISplitViewController.self) == false) {

                        matchController = parentController
            }

            parentContainerViewController = matchController
        }

        let finalController = parentContainerViewController?.parentIQContainerViewController() ?? parentContainerViewController

        return finalController

    }

    ///-----------------------------------
    /// MARK: Superviews/Subviews/Siglings
    ///-----------------------------------

    /**
    Returns the superView of provided class type.
    */
    @objc public func superviewOfClassType(_ classType:UIView.Type)->UIView? {

        var superView = superview

        while let unwrappedSuperView = superView {

            if unwrappedSuperView.isKind(of: classType) {

                //If it's UIScrollView, then validating for special cases
                if unwrappedSuperView.isKind(of: UIScrollView.self) {

                    let classNameString = NSStringFromClass(type(of:unwrappedSuperView.self))

                    //  If it's not UITableViewWrapperView class, this is internal class which is actually manage in UITableview. The speciality of this class is that it's superview is UITableView.
                    //  If it's not UITableViewCellScrollView class, this is internal class which is actually manage in UITableviewCell. The speciality of this class is that it's superview is UITableViewCell.
                    //If it's not _UIQueuingScrollView class, actually we validate for _ prefix which usually used by Apple internal classes
                    if unwrappedSuperView.superview?.isKind(of: UITableView.self) == false &&
                        unwrappedSuperView.superview?.isKind(of: UITableViewCell.self) == false &&
                        classNameString.hasPrefix("_") == false {
                        return superView
                    }
                }
                else {
                    return superView
                }
            }

            superView = unwrappedSuperView.superview
        }

        return nil
    }

    /**
    Returns all siblings of the receiver which canBecomeFirstResponder.
    */
    internal func responderSiblings()->[UIView] {

        //Array of (UITextField/UITextView's).
        var tempTextFields = [UIView]()

        //    Getting all siblings
        if let siblings = superview?.subviews {

            for textField in siblings {

                if (textField == self || textField.ignoreSwitchingByNextPrevious == false) && textField._IQcanBecomeFirstResponder() == true {
                    tempTextFields.append(textField)
                }
            }
        }

        return tempTextFields
    }

    /**
    Returns all deep subViews of the receiver which canBecomeFirstResponder.
    */
    internal func deepResponderViews()->[UIView] {

        //Array of (UITextField/UITextView's).
        var textfields = [UIView]()

        for textField in subviews {

            if (textField == self || textField.ignoreSwitchingByNextPrevious == false) && textField._IQcanBecomeFirstResponder() == true {
                textfields.append(textField)
            }

            //Sometimes there are hidden or disabled views and textField inside them still recorded, so we added some more validations here (Bug ID: #458)
            //Uncommented else (Bug ID: #625)
            if textField.subviews.count != 0  && isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 {
                for deepView in textField.deepResponderViews() {
                    textfields.append(deepView)
                }
            }
        }

        //subviews are returning in opposite order. Sorting according the frames 'y'.
        return textfields.sorted(by: { (view1 : UIView, view2 : UIView) -> Bool in

            let frame1 = view1.convert(view1.bounds, to: self)
            let frame2 = view2.convert(view2.bounds, to: self)

            let x1 = frame1.minX
            let y1 = frame1.minY
            let x2 = frame2.minX
            let y2 = frame2.minY

            if y1 != y2 {
                return y1 < y2
            } else {
                return x1 < x2
            }
        })
    }

    private func _IQcanBecomeFirstResponder() -> Bool {

        var _IQcanBecomeFirstResponder = false

        //  Setting toolbar to keyboard.
        if let textField = self as? UITextField {
            _IQcanBecomeFirstResponder = textField.isEnabled
        } else if let textView = self as? UITextView {
            _IQcanBecomeFirstResponder = textView.isEditable
        }

        if _IQcanBecomeFirstResponder == true {
            _IQcanBecomeFirstResponder = isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 && isAlertViewTextField() == false && textFieldSearchBar() == nil
        }

        return _IQcanBecomeFirstResponder
    }

    ///-------------------------
    /// MARK: Special TextFields
    ///-------------------------

    /**
     Returns searchBar if receiver object is UISearchBarTextField, otherwise return nil.
    */
    internal func textFieldSearchBar()-> UISearchBar? {

        var responder : UIResponder? = self.next

        while let bar = responder {

            if let searchBar = bar as? UISearchBar {
                return searchBar
            } else if bar is UIViewController {
                break
            }

            responder = bar.next
        }

        return nil
    }

    /**
    Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
    */
    internal func isAlertViewTextField()->Bool {

        var alertViewController : UIResponder? = viewContainingController()

        var isAlertViewTextField = false

        while let controller = alertViewController, isAlertViewTextField == false {

            if controller.isKind(of: UIAlertController.self) {
                isAlertViewTextField = true
                break
            }

            alertViewController = controller.next
        }

        return isAlertViewTextField
    }

    private func depth()->Int {
        var depth : Int = 0

        if let superView = superview {
            depth = superView.depth()+1
        }

        return depth
    }

}

public extension UIViewController {

    func parentIQContainerViewController() -> UIViewController? {
        return self
    }
}

extension NSObject {

    internal func _IQDescription() -> String {
        return "<\(self) \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}



