//
//  EditProfileVC.swift
//  FoodScan
//
//  Created by C110 on 12/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

class EditProfileVC: UIViewController {

    @IBOutlet var txtFullName: UITextField!
    @IBOutlet var txtEmailId: UITextField!
    var objUser: WSUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtFullName.setLeftPaddingPoints(10)
        txtEmailId.setLeftPaddingPoints(10)
        objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
        txtFullName.text = objUser.firstName
        txtEmailId.text = objUser.email
    }

    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonSaveClicked(_ sender: Any) {
        if ValidateField(){
            if Connectivity.isConnectedToInternet
            {
                showIndicator(view: view)
                let param:NSMutableDictionary = [
                    WS_KFirst_name:self.txtFullName.text!,
                    WS_KEmail_id:self.txtEmailId.text!,
                    WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]

                includeSecurityCredentials {(data) in
                    let data1 = data as! [AnyHashable : Any]
                    param.addEntries(from: data1)
                }

                HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIEditProfile, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                    self.hideIndicator(view: self.view)
                    if response != nil
                    {
                        if JSON(response!)[WSKUser].array? .count != 0 {
                            APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
                            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: KUser)
                            UserDefaults.standard.set(APP_DELEGATE.objUser?.userId, forKey: kUserId)
                        }
                        showBanner(title: "", subTitle: profile_change_success, bannerStyle: .success)
                    } else {
                        showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                    }
                })
            }
            else
            {
                self.generateAlertWithOkButton(text: no_internet_connection)
            }
        }
    }

    func ValidateField() -> Bool {
        if !txtFullName.text!.isValid() {
            self.generateAlertWithOkButton(text: please_enter_full_name)
        } else if !txtEmailId.text!.isValidEmail() {
            self.generateAlertWithOkButton(text: please_enter_email)
        } else if !txtEmailId.text!.isValidEmail() {
            self.generateAlertWithOkButton(text: please_enter_valid_email)
        } else {
            return true
        }
        return false
    }

}
