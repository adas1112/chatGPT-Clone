//
//  chatScreenController.swift
//  ChatDemo
//
//  Created by Bilal on 03/01/25.
//
import UIKit

class chatScreenController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    //MARK: - Outlets

    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var promptTxtField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var txtFieldView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawerView: UIView!
    
    //MARK: - Variables

    var responseArr : [ChatMessage] = []
    let apiKey = "dB0hcTdY6HFLNOwZA28C6vck7XxW45IikWjvC1FU"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        promptTxtField.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        updateButtonImage(for: promptTxtField.text)
        promptTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        UserDefaults.standard.set(nil, forKey: "previousContext")
        UserDefaults.standard.removeObject(forKey: "previousContext")
        drawerView.isHidden = true
        txtFieldView.layer.cornerRadius = 4
    }
    
    //MARK: - SetUp UI

    func updateButtonImage(for text: String?) {
        let imageName = (text?.isEmpty ?? true) ? "send" : "sendColor"
        sendBtn.setImage(UIImage(named: imageName), for: .normal)
    }
    
    //MARK: - TextField Delegate Method
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateButtonImage(for: promptTxtField.text)
    }
    
    //MARK: - Button Click Action
    
    @IBAction func drawerBtnClick(_ sender: Any) {
        drawerView.isHidden = false
    }
    
    @IBAction func closeDrawerBtnClick(_ sender: Any) {
        drawerView.isHidden = true
    }
    
    @IBAction func sendBtnClick(_ sender: Any) {
        guard let prompt = promptTxtField.text, !prompt.isEmpty else {
            print("Enter Message")
            return
        }
        tableView.isHidden = false
        sendBtn.setImage(UIImage(named: "send"), for: .normal)
        
        let userMessage = ChatMessage(text: prompt, type: .user)
        responseArr.append(userMessage)
        let userIndexPath = IndexPath(row: responseArr.count - 1, section: 0)
        tableView.insertRows(at: [userIndexPath], with: .automatic)
        scrollToBottom()
        updateContext(newContext: prompt)
        
        generateResponse(prompt: prompt) { response in
            DispatchQueue.main.async {
                if let response = response {
                    print(response)
                    self.animateTypingResponse(response)
                } else {
                    let errorMessage = ChatMessage(text: "Error: No response", type: .response)
                    self.responseArr.append(errorMessage)
                    let errorIndexPath = IndexPath(row: self.responseArr.count - 1, section: 0)
                    self.tableView.insertRows(at: [errorIndexPath], with: .automatic)
                    self.scrollToBottom()
                }
            }
        }
        promptTxtField.text = ""
    }
    
    //MARK: - Tableview Delegate Methods
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = responseArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! questionPromptTableCell
        cell.questionView.backgroundColor = .white
        cell.questionTextView.backgroundColor = .white
        cell.questionTextView.text = message.text
        if message.type == .user{
            cell.icon.image = UIImage(named: "A")
            cell.questionView.backgroundColor = .white
            cell.questionTextView.backgroundColor = .white
        }else{
            cell.icon.image = UIImage(named: "gptIcon")
            cell.questionView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
            cell.questionTextView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
            cell.questionTextView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        cell.questionTextView.sizeToFit()
        cell.questionTextView.isScrollEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = responseArr[indexPath.row]
        let text = message.text
        let font = UIFont.systemFont(ofSize: 17)
        let width = tableView.frame.width - 40
        let height = heightForText(text, font: font, width: width)
        if height >= 25 {
            return height + 20
        }else {
            return height + 25
        }
    }
    
    func heightForText(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    //MARK: - Scroll Bottom Tableview Automatically
    
    func scrollToBottom() {
        let numberOfSections = tableView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        let numberOfRows = tableView.numberOfRows(inSection: numberOfSections - 1)
        guard numberOfRows > 0 else { return }
        
        let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //MARK: - API CAll

    func generateResponse(prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.cohere.ai/generate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let previousContext = getPreviousContext().joined(separator: "\n")
        let fullPrompt = previousContext + "\nUser: \(prompt)"
        
        let parameters: [String: Any] = [
            "model": "command-medium-nightly",
            "prompt": fullPrompt,
            "max_tokens": 1000,
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
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(jsonResponse)
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
    
    //MARK: - Saved Previous Asked Context (Questions)

    func saveContext(previousContext: String) {
        var contextArray = UserDefaults.standard.stringArray(forKey: "previousContext") ?? []
        contextArray.append(previousContext)
        UserDefaults.standard.set(contextArray, forKey: "previousContext")
    }
    
    func getPreviousContext() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "previousContext") ?? []
    }
    
    func updateContext(newContext: String) {
        saveContext(previousContext: newContext)
    }
    
    //MARK: - Typing Animation API Response

    func animateTypingResponse(_ response: String) {
        let responseMessage = ChatMessage(text: "", type: .response)
        self.responseArr.append(responseMessage)
        let responseIndexPath = IndexPath(row: self.responseArr.count - 1, section: 0)
        self.tableView.insertRows(at: [responseIndexPath], with: .none)
        self.scrollToBottom()
        
        let words = response.split(separator: " ")
        var currentText = ""
        
        var wordIndex = 0
        let typingSpeed: TimeInterval = 0.1
        
        let timer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if wordIndex < words.count {
                currentText += (currentText.isEmpty ? "" : " ") + words[wordIndex]
                self.responseArr[self.responseArr.count - 1].text = currentText
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [responseIndexPath], with: .none)
                }
                self.scrollToBottom()
                wordIndex += 1
            } else {
                timer.invalidate() // Stop the timer when all words are added
            }
        }
        timer.fire()
    }
}

//MARK: - Struct for Type of Response

struct ChatMessage {
    var text: String
    let type: MessageType
}

enum MessageType {
    case user
    case response
}

