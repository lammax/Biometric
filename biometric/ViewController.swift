//
//  ViewController.swift
//  biometric
//
//  Created by Mac on 29.11.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import AuthenticationServices
import UIKit
import LocalAuthentication

// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
// https://help.apple.com/developer-account/#/devcdfbb56a3
// https://engineering.q42.nl/sign-in-with-apple/
// https://support.apple.com/ru-ru/HT210318
// https://developer.apple.com/videos/play/wwdc2019/706/

class ViewController: UIViewController {
    
    @IBOutlet weak var authView: UIView!
    
    let authAppleProvider = ASAuthorizationAppleIDProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //authenticationWithTouchID()
        //setupAppleAuthorization()
        //setupNotificationCenter()
    }

    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Ввести 5-значный пароль"

        var authorizationError: NSError?
        let reason = "Приложите палец чтобы войти в приложение"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                
                var title = "Success"
                var message = "Authenticated succesfully!"
                
                if !success {
                    // Failed to authenticate
                    guard let error = evaluateError else {
                        return
                    }
                    title = "Error"
                    message = error.localizedDescription
                }
                
                DispatchQueue.main.async() {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            
            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }
    
    func setupNotificationCenter() {
        let center = NotificationCenter.default
        //let name = NSNotification.Name.creden
        //KeychainItem
    }
    
    //Apple SignIn
    func setupAppleAuthorization() {
        setupProviderLoginView()
    }

    func setupProviderLoginView() {
        //Apple login button 1st variant
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.authView.addSubview(button)
    }
    @objc func handleAuthorizationAppleIDButtonPress() {
        let request = authAppleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func setupProviderCallBack(userIdentifier: String) {
        authAppleProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("AppleID is valid")
            case .revoked:
                print("AppleID revoked")
            case .notFound:
                print("AppleID not found")
            case .transferred:
                print("AppleID transferred")
            @unknown default:
                break
            }
        }
    }
    @IBAction func appleSignInPressed(_ sender: UIButton) {
        //Apple login button 2nd variant
        //handleAuthorizationAppleIDButtonPress()
        authenticationWithTouchID()
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = credential.user
            let identityToken = credential.identityToken
            let authCode = credential.authorizationCode
            let realUserStatus = credential.realUserStatus
            let userEmail = credential.email
            
            print(userIdentifier, identityToken, authCode, realUserStatus, userEmail)

            setupProviderCallBack(userIdentifier: userIdentifier)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

