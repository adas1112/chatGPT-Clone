//
//  ViewController.swift
//  ChatDemo
//
//  Created by Bilal on 02/01/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 8
        signUpBtn.layer.cornerRadius = 8
        signUpBtn.layer.borderWidth = 1
        signUpBtn.layer.borderColor = UIColor(red: 75/255, green: 162/255, blue: 130/255, alpha: 1).cgColor
    }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "chatScreenController") as! chatScreenController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpBtnClick(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "chatController") as! chatController
        navigationController?.pushViewController(vc, animated: true)
    }
}

