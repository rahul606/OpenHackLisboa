//
//  ViewController.swift
//  OpenHack
//
//  Created by Rahul Tomar on 06/02/2017.
//  Copyright © 2017 TMFAction Week. All rights reserved.
//

import UIKit
import Stormpath

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var ssn: UITextField!
    @IBOutlet weak var country: UIPickerView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var selectedCountry: UILabel!
    
    
    let countries = NSLocale.isoCountryCodes.map { (code:String) -> String in
        let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
        return NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.country.isHidden = true
        // get the localized country name (in my case, it's US English)
        let englishLocale : NSLocale = NSLocale.init(localeIdentifier :  "en_US")
        
        // get the current locale
        let currentLocale = NSLocale.current
        
        let theEnglishName : String? = englishLocale.displayName(forKey: NSLocale.Key.identifier, value: currentLocale.identifier)
        if let theEnglishName = theEnglishName
        {
            let countryName = theEnglishName.slice(from: "(", to: ")")
            selectedCountry.text = countryName
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction(recognizer:)))
        selectedCountry.addGestureRecognizer(tap)
        
        self.hideKeyboardWhenTappedAround()
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)*/
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func tapFunction(recognizer:UITapGestureRecognizer) {
        self.country.isHidden = false
        self.country.dataSource = self
        self.country.delegate = self
        self.selectedCountry.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func register(_ sender: UIButton) {
        let url = URL(string: "https://store.lab.fiware.org/DSPartyManagement/api/partyManagement/v2/individual")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer RfJyC03rpUnWFBUSyTLKCiig4eMYRh", forHTTPHeaderField: "Authorization")
        request.httpBody = "{\n  \"id\": \"bringx-fi-omt\",\n  \"birthDate\": \"\",\n  \"countryOfBirth\": \"\",\n  \"familyName\": \"Tomar\",\n  \"gender\": \"\",\n  \"givenName\": \"Rahul\",\n  \"maritalStatus\": \"\",\n  \"nationality\": \"\",\n  \"placeOfBirth\": \"\",\n  \"title\": \"\",\n  \"contactMedium\": [\n    {\n      \"type\": \"Email\",\n      \"preferred\": \"false\",\n      \"medium\": {\n        \"emailAddress\": \"rtomar@bringx.com\"\n      }\n    }\n  ]\n}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response, let data = data {
                print(response)
                print(String(data: data, encoding: .utf8) ?? "No Data")
            } else {
                print(error ?? "Error")
            }
        }
        
        task.resume()
    }
    
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry.text = countries[row]
        self.country.isHidden = true
        self.selectedCountry.isHidden = false
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

