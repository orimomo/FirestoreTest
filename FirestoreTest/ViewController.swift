//
//  ViewController.swift
//  FirestoreTest
//
//  Created by 折田桃子 on 2020/01/12.
//  Copyright © 2020 Momoko Orita. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    let collectionName = "message"
    var messageBox: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        
        setListenMessage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func postMessage(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let message = textField.text else { return }
        if message.isEmpty {
            return
        }
        
        let postData: [String: Any] = [
            "message": message,
            "created_at": Date()
        ]
        
        var ref: DocumentReference? = nil
        
        ref = db.collection(collectionName).addDocument(data: postData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        textField.text = ""
    }
    
    func setListenMessage() {
        db.collection(collectionName).addSnapshotListener { (snapShot, error) in
            guard let data = snapShot else {
                print("data is nil")
                return
            }
            data.documentChanges.forEach { new in
                if (new.type == .added){
                    self.db.collection(self.collectionName)
                        .order(by: "created_at", descending: true)
                        .getDocuments { [weak self] snapshot, error in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            } else {
                                self?.messageBox = snapshot?.documents.map { $0.data() } ?? []
                                self?.tableView.reloadData()
                            }
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageBox.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        cell.textLabel?.text = messageBox[indexPath.row]["message"] as? String
        return cell
    }
}

// MARK: - Table view delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
