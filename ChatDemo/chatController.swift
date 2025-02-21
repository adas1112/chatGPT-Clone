//
//  chatController.swift
//  ChatDemo
//
//  Created by Bilal on 02/01/25.
//

import UIKit

class chatController: UIViewController, UITextViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var questionTxtViewHeight: NSLayoutConstraint!
    @IBOutlet weak var promptTxtView: UITextField!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var responseView: UIView!
    @IBOutlet weak var responseTxtViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    
    let apiKey = "dB0hcTdY6HFLNOwZA28C6vck7XxW45IikWjvC1FU"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextView.delegate = self
        promptTxtView.delegate = self
        questionTextView.translatesAutoresizingMaskIntoConstraints = false
        questionTextView.isScrollEnabled = false
        adjustTextViewHeight()
        questionView.isHidden = true
        responseView.isHidden = true
        promptTxtView.layer.cornerRadius = 4
        updateButtonImage(for: promptTxtView.text)
        promptTxtView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateButtonImage(for: promptTxtView.text)
    }
    
    @IBAction func sendBtnClick(_ sender: Any) {
        guard let prompt = promptTxtView.text, !prompt.isEmpty else {
            print("Enter Message")
            return
        }
        
        self.questionView.isHidden = false
        self.questionTextView.text = prompt
        adjustTextViewHeight()
        
        generateResponse(prompt: prompt) { response in
            DispatchQueue.main.async {
                self.responseView.isHidden = false
                self.responseTextView.text = response ?? "Failed to get a response."
                self.adjustTextViewHeight()
            }
        }
        promptTxtView.text = ""
        responseTextView.text = ""
    }
    
    func updateButtonImage(for text: String?) {
        let imageName = (text?.isEmpty ?? true) ? "send" : "sendColor"
        sendBtn.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func adjustTextViewHeight() {
        // Update the height for the questionTextView
        let questionSize = questionTextView.sizeThatFits(CGSize(width: questionTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        questionTxtViewHeight.constant = questionSize.height
        
        // Update the height for the responseTextView
        let responseSize = responseTextView.sizeThatFits(CGSize(width: responseTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        responseTxtViewHeight.constant = responseSize.height
        
        view.layoutIfNeeded()
    }
    
    func generateResponse(prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.cohere.ai/generate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let parameters: [String: Any] = [
            "model": "command-medium-nightly", // Replace with the correct model available for your API key
            "prompt": trimmedPrompt,
            "max_tokens": 100,
            "temperature": 0.7
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            // Debugging: Print the raw response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Access the "text" field directly
                    if let text = jsonResponse["text"] as? String {
                        completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        print("Unexpected Response Structure: \(jsonResponse)")
                        completion(nil)
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}
