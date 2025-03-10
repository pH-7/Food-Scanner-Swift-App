//
//  LoginVCViewController.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginVC: UIViewController {
    
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.setLeftPaddingPoints(10)
        txtPassword.setLeftPaddingPoints(10)
    }

    //MARK: - Buttons
    @IBAction func buttonBackClicked(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonForgotPasswordClicked(_ sender: Any) {
        pushViewController(Storyboard: StoryBoardLogin, ViewController: idForgotPasswordVC, animation: true)
    }

    @IBAction func buttonSignInClicked(_ sender: Any) {

        if ValidateField(){
            if Connectivity.isConnectedToInternet
            {
                showIndicator(view: view)
                let param:NSMutableDictionary = [
                    WS_KEmail_id:self.txtEmail.text!,
                    WS_KPassword:self.txtPassword.text!,
                    WS_KDevice_type:DEVICE_TYPE,
                    WS_KAccess_key:DEFAULT_ACCESS_KEY,
                    WS_KSecret_key:UserDefaults.standard.string(forKey: kTempToken) ?? ""]

                HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APILogin, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in

                    if response != nil
                    {
                        UserDefaults.standard.set(JSON(response!)[WSKUserToken].string, forKey: kUserToken)
                        if JSON(response!)[WSKUser].array? .count != 0 {
                            APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
                            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: KUser)
                            UserDefaults.standard.set(APP_DELEGATE.objUser?.guid.asStringOrEmpty(), forKey: kUserGUID)
                            UserDefaults.standard.set(APP_DELEGATE.objUser?.userId.asStringOrEmpty(), forKey: kUserId)
                            self.getGUID ()
                        }
                    }else {
                        self.hideIndicator(view: self.view)
                        self.generateAlertWithOkButton(text: message!)
                    }
                })
            }
            else
            {
                showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
            }

        }
    }

    func getGUID(){

        let GUID = UserDefaults.standard.value(forKey: kUserGUID)
        let param : NSDictionary = ["guid": GUID.asStringOrEmpty()]
        if Connectivity.isConnectedToInternet
        {
            HttpRequestManager.sharedInstance.postJSONRequestSecurity(endpointurl: APItestEncryption, parameters: param as NSDictionary) { (response, error, message) in
                if (error == nil)
                {
                    if (response != nil && response is NSDictionary)
                    {
                        let dicResp = response as! NSDictionary
                        UserDefaults.standard.set(dicResp.value(forKey: kEncrypted), forKey: kEncrypted)
                        self.hideIndicator(view: self.view)
                        UserDefaults.standard.set(true, forKey: kLogIn)
                        HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
                        self.pushViewController(Storyboard: StoryBoardMain, ViewController: idHomeTabVC, animation: false)
                    }
                }
                self.hideIndicator(view: self.view)
            }
        }else{
            self.generateAlertWithOkButton(text: no_internet_connection)
        }
    }
    func ValidateField() -> Bool {
        if !txtEmail.text!.isValid() {
            showBanner(title: "", subTitle: please_enter_email, bannerStyle: .danger)
        } else if !txtEmail.text!.isValidEmail() {
            showBanner(title: "", subTitle: please_enter_valid_email, bannerStyle: .danger)
        } else if !txtPassword.text!.isValid() {
            showBanner(title: "", subTitle: please_enter_password, bannerStyle: .danger)
        } else {
            return true
        }
        return false
    }
}
