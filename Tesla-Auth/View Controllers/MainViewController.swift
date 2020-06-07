//
//  MainViewController.swift
//  Tesla-Auth
//
//  Created by Nick Sparks on 07/06/2020.
//  Copyright © 2020 Nick Sparks. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var txtEmail: NSTextField!
    @IBOutlet weak var txtPassword: NSSecureTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var btnSubmit: NSButton!
    @IBOutlet weak var lblError: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    
    @IBAction func onClick(_ sender: NSButton) {
        self.progressIndicator.isHidden = false
        self.progressIndicator.startAnimation(self)
        self.updateLableVisibilityAndText(newText: "", isHidden: true)
        
        AuthDataSource.shared.registerUser(username: self.txtEmail.stringValue, password: self.txtPassword.stringValue, success: {() -> Void in
            print("auth success")
            DispatchQueue.main.async {
                self.stopProgressIndicator()
                self.btnSubmit.isEnabled = false
                self.txtEmail.isEnabled = false
                self.txtPassword.isEnabled = false
                self.updateLableVisibilityAndText(newText: "Well done - woooo! :)", isHidden: false, colour: NSColor.green)
            }
        }, failure: {() -> Void in
            print("auth failure")
            DispatchQueue.main.async {
                self.stopProgressIndicator()
            self.updateLableVisibilityAndText(newText: "Ahhh shucks, your username/password is wrong", isHidden: false)
            }
        })
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        // If authentication has already been complete - there is no need to validate
        if (AuthDataSource.shared.authToken != nil) {
            return
        }
        
        var formIsValid = true
        var message = ""
        
        (formIsValid, message) = validate(txtEmail)
        (formIsValid, message) = validate(txtPassword)

        btnSubmit.isEnabled = formIsValid
        self.updateLableVisibilityAndText(newText: message, isHidden: formIsValid)
    }
    
    private func validate(_ textField: NSTextField) -> (Bool, String) {
        let text = textField.stringValue
        
        return (text.count > 0, "You need to enter text an email AND password! (please)")
    }
    
    private func updateLableVisibilityAndText(newText: String, isHidden: Bool, colour: NSColor = NSColor.red) {
        self.lblError.stringValue = newText
        self.lblError.isHidden = isHidden
        self.lblError.textColor = colour
    }
    
    private func stopProgressIndicator() {
        self.progressIndicator.stopAnimation(self)
        self.progressIndicator.isHidden = true
    }
}
