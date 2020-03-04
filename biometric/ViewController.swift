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

class ViewController: UIViewController {
    
    @IBOutlet weak var authView: UIView!
    
    let authAppleProvider = ASAuthorizationAppleIDProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //authenticationWithTouchID()
        setupAppleAuthorization()
    }

    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

        var authorizationError: NSError?
        let reason = "Authentication required to access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                
                if success {
                    DispatchQueue.main.async() {
                        let alert = UIAlertController(title: "Success", message: "Authenticated succesfully!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    // Failed to authenticate
                    guard let error = evaluateError else {
                        return
                    }
                    print(error)
                
                }
            }
        } else {
            
            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }
    
    func setupAppleAuthorization() {
        setupProviderLoginView()
    }
    
    func setupProviderLoginView() {
        let button = ASAuthorizationAppleIDButton()
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
            }
        }
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

