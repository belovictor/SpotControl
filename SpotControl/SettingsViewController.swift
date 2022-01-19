//
//  SettingsViewController.swift
//  SpotControl
//
//  Created by Victor Belov on 18.01.2022.
//

import UIKit
import OSLog

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsViewController viewDidLoad")
        let orientationValue = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if UserDefaults.standard.string(forKey: "hostname") != nil {
            self.hostTextField.text = UserDefaults.standard.string(forKey: "hostname")
        }
        if UserDefaults.standard.string(forKey: "hostport") != nil {
            self.portTextField.text = UserDefaults.standard.string(forKey: "hostport")
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        print("Cancel button pressed")
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("Save button pressed")
        if self.hostTextField.text?.isEmpty ?? true || self.portTextField.text?.isEmpty ?? true {
            errorLabel.text = "Hostname and port fields should not be empty"
            return
        }
        UserDefaults.standard.set(self.hostTextField.text, forKey: "hostname")
        UserDefaults.standard.set(self.portTextField.text, forKey: "hostport")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return;
        }
        self.view.frame.origin.y = 0 - keyboardSize.height / 2
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
}

