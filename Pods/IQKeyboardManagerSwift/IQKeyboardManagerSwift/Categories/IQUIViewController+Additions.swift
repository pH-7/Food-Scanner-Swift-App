//
//  IQUIViewController+Additions.swift
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


private var kIQLayoutGuideConstraint = "kIQLayoutGuideConstraint"


public extension UIViewController {

    /**
    To set customized distance from keyboard for textField/textView. Can't be less than zero

     @deprecated    Due to change in core-logic of handling distance between textField and keyboard distance, this layout contraint tweak is no longer needed and things will just work out of the box regardless of constraint pinned with safeArea/layoutGuide/superview
    */
    @available(*,deprecated, message: "Due to change in core-logic of handling distance between textField and keyboard distance, this layout contraint tweak is no longer needed and things will just work out of the box regardless of constraint pinned with safeArea/layoutGuide/superview.")
    @IBOutlet @objc public var IQLayoutGuideConstraint: NSLayoutConstraint? {
        get {

            return objc_getAssociatedObject(self, &kIQLayoutGuideConstraint) as? NSLayoutConstraint
        }

        set(newValue) {
            objc_setAssociatedObject(self, &kIQLayoutGuideConstraint, newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
