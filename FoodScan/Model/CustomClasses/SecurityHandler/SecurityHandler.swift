//
//  SecurityHandler.swift
//  Swing
//
//  Created by C110 on 21/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation

let kLogIn = "Login"
let kAccessKey = "access_key"
let kSecretKey = "secret_key"
let kTempToken = "tempToken"
let kGlobalPassword = "globalPassword"
let kNoUsername = "nousername"
let kUserGUID = "userGUID"
let kUserID = "userId"
let kUserToken = "userToken"
let kAdminConfig = "adminConfig"
let KKey_iv = "key_iv"
let KGUID = "GUID"
let kEncrypted = "encrypted_value"

func includeSecurityCredentials(processedData:@escaping (_ data: NSDictionary?) -> Void){

    let accessKey : String
    let secretKey : String
    if UserDefaults.standard.bool(forKey: kLogIn) && (UserDefaults.standard.value(forKey: kEncrypted) != nil)
    {
        accessKey = UserDefaults.standard.value(forKey: kEncrypted) as! String
    }else{
        accessKey = kNoUsername
    }

    if UserDefaults.standard.bool(forKey: kLogIn) && (UserDefaults.standard.value(forKey: kUserToken) != nil) {
        secretKey = UserDefaults.standard.value(forKey: kUserToken) as! String
        processedData( [kAccessKey:accessKey, kSecretKey:  secretKey] as NSDictionary)

    }else if UserDefaults.standard.value(forKey: kTempToken) != nil {
        secretKey = UserDefaults.standard.value(forKey: kTempToken) as! String
        processedData( [kAccessKey:accessKey, kSecretKey:  secretKey] as NSDictionary)
    }else {
        getTempToken {
            processedData( [kAccessKey:accessKey, kSecretKey:  UserDefaults.standard.value(forKey: kTempToken)! , "device_type":DEVICE_TYPE /*, kIsdelete : "0"*/] as NSDictionary)
        }
    }
}

func checkSecurity() {
    if UserDefaults.standard.bool(forKey: kLogIn) {
        let isExpired: Bool = isTokenExpired()
        if isExpired {
            callUpdateTokenWS()
        }
    }else if (UserDefaults.standard.value(forKey: kTempToken) == nil) {
        getTempToken {
        }
    }
}

func isTokenExpired() -> Bool {
    return false

    if UserDefaults.standard.bool(forKey: kLogIn) && (UserDefaults.standard.value(forKey: kUserToken) != nil) {
        var secretKey:String = String()
        var accessKey:String = String()
        var dateTimeString:String = String()
        var arrSecretkeyComponents:NSArray = NSArray()

        accessKey = UserDefaults.standard.value(forKey: kUserGUID) as! String
        secretKey = UserDefaults.standard.value(forKey: kUserToken) as! String
        arrSecretkeyComponents = secretKey.components(separatedBy: "_") as NSArray

        if (!(arrSecretkeyComponents.count==2) || (!(arrSecretkeyComponents.object(at: 0) as! String).isValid()) || (!(arrSecretkeyComponents.object(at: 1) as! String).isValid())) {
            return true
        }

        dateTimeString = arrSecretkeyComponents.object(at: 1) as! String
        dateTimeString = FBEncryptorAES.decryptBase64String(dateTimeString, keyString: accessKey)

        let calendar:Calendar = Calendar.current
        let timeZone:TimeZone = TimeZone (abbreviation: "UTC")!

        var dateCurrent:Date = Date()
        let formatter:DateFormatter = DateFormatter()
        formatter.timeZone=timeZone
        formatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        let dateString:String = formatter.string(from: dateCurrent)
        dateCurrent = formatter.date(from: dateString)!

        var comps:DateComponents = DateComponents()
        comps.day = dateTimeString.substring(0, length: 2) as! Int
        comps.month = dateTimeString.substring(2, length: 2) as! Int
    }
    return true
}

func callUpdateTokenWS() {
    let param:NSDictionary = [KGUID:"",
                              kUserId:""]
    HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIUpdateToken, parameters: param, responseData: { (response, error, message) in

        if response != nil
        {
            let dicTemp:NSDictionary = (response as! NSDictionary).object(forKey: WSDATA) as! NSDictionary
            if dicTemp.value(forKey: kTempToken) != nil && dicTemp.object(forKey: kAdminConfig) != nil {
                UserDefaults.standard.set(dicTemp.value(forKey: kUserToken), forKey: kUserToken)
            }
        }else {
        }
    })
}

//MARK:- TempToken
func getTempToken(processedData:@escaping () -> Void) {
    let param:NSDictionary = [kAccessKey:kNoUsername]

    HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIRefreshToken, parameters: param as NSDictionary) { (response, error, message) in
        if (error == nil)
        {
            if (response != nil && response is NSDictionary)
            {
                let dicTemp:NSDictionary = (response as! NSDictionary).object(forKey: WSDATA) as! NSDictionary
                if dicTemp.value(forKey: kTempToken) != nil && dicTemp.object(forKey: kAdminConfig) != nil {
                    let dicConfig:NSDictionary = dicTemp.object(forKey: kAdminConfig) as! NSDictionary
                    UserDefaults.standard.set(dicConfig.value(forKey: kGlobalPassword), forKey: kGlobalPassword)
                    UserDefaults.standard.set(dicTemp.value(forKey: kTempToken), forKey: kTempToken)
                    UserDefaults.standard.set(dicConfig.value(forKey: KKey_iv), forKey: KKey_iv)
                }
                processedData()
            }
            else
            {
                processedData()
            }
        }
        else
        {
            processedData()
        }
    }
}
