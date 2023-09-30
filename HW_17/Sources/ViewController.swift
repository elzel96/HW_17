//
//  ViewController.swift
//  HW_17
//
//  Created by Helena on 23.09.2023.
//

import UIKit

class ViewController: UIViewController {

    let queue = DispatchQueue(label: "newQueue", attributes: .concurrent)
    
    var generatedPassword = ""
    var isStop = false
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change background color", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var generatePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate password💫", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(generatePassword), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var crackPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Crack password🕵‍♂️", for: .normal)
        button.isEnabled = false
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(crackPassword), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("STOP🕵‍♂️", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(stopSearching), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Type password here"
        passwordField.textAlignment = .center
        passwordField.returnKeyType = .done
        passwordField.clipsToBounds = true
        passwordField.layer.cornerRadius = 12
        passwordField.backgroundColor = .lightGray
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        return passwordField
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        passwordField.delegate = self
    }
    
    // MARK: - Setups

    private func setupHierarchy() {
        view.addSubview(changeColorButton)
        view.addSubview(generatePasswordButton)
        view.addSubview(crackPasswordButton)
        view.addSubview(passwordField)
        view.addSubview(passwordLabel)
        view.addSubview(stopButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            passwordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (0.35 * (view.bounds.height))),
            
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            stopButton.heightAnchor.constraint(equalToConstant: 0.045 * (view.bounds.height)),
            stopButton.widthAnchor.constraint(equalToConstant: 0.3 * (view.bounds.width)),
            
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 10),
            passwordField.heightAnchor.constraint(equalToConstant: 0.05 * (view.bounds.height)),
            passwordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (0.04 * (view.bounds.height))),
            passwordField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: (-0.04 * (view.bounds.height))),
            
            generatePasswordButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (0.04 * (view.bounds.height))),
            generatePasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            generatePasswordButton.heightAnchor.constraint(equalToConstant: 0.05 * (view.bounds.height)),
            generatePasswordButton.widthAnchor.constraint(equalToConstant: 0.4 * (view.bounds.width)),
            
            crackPasswordButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: (-0.04 * (view.bounds.height))),
            crackPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            crackPasswordButton.heightAnchor.constraint(equalToConstant: 0.05 * (view.bounds.height)),
            crackPasswordButton.widthAnchor.constraint(equalToConstant: 0.4 * (view.bounds.width)),
            
            changeColorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeColorButton.heightAnchor.constraint(equalToConstant: 0.05 * (view.bounds.height)),
            changeColorButton.widthAnchor.constraint(equalToConstant: 0.5 * (view.bounds.width)),
            changeColorButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-0.1 * (view.bounds.height)))
        ])
    }
    
    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }
        
        var password: String = ""
        
        let workItem = DispatchWorkItem {
            while password != passwordToUnlock {
                if self.isStop { return }
                password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
                DispatchQueue.main.sync {
                    self.passwordLabel.text = "Is \(password) your password?"
                }
            }
        }
        
        let notifyView = DispatchWorkItem {
            DispatchQueue.main.sync {
                self.generatePasswordButton.isEnabled = true
                if self.isStop {
                    self.isStop.toggle()
                    self.passwordLabel.text = "Search was stopped"
                    return
                }
                self.passwordLabel.text = "Done! Your password is \(password)"
                self.passwordField.isSecureTextEntry = false
            }
        }
        
        workItem.notify(queue: queue) {
            notifyView.perform()
        }

        queue.async(execute: workItem)
    }

    // MARK: - Action
    
    @objc func buttonTapped() {
        isBlack.toggle()
    }
    
    @objc func generatePassword() {
        generatedPassword = generateRandomPassword()
        passwordField.isSecureTextEntry = true
        passwordField.text = generatedPassword
        print(generatedPassword)
    }
    
    @objc func crackPassword() {
        isStop = false
        generatePasswordButton.isEnabled = false
        crackPasswordButton.isEnabled = false
        passwordField.isEnabled = false
        
        queue.async {
            self.bruteForce(passwordToUnlock: self.generatedPassword)
            DispatchQueue.main.sync {
                self.passwordField.isEnabled = true
            }
        }
    }
    
    @objc func stopSearching() {
        isStop = true
        passwordField.isEnabled = true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        crackPasswordButton.isEnabled = false
        textField.isSecureTextEntry = true
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            for char in text {
                if !String().printable.contains(char) {
                    print("You can't use such password")
                    return false
                }
            }
            if text != "" {
                return true
            } else {
                print("Type your password")
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        crackPasswordButton.isEnabled = true
        if let text = textField.text {
            generatedPassword = text
        }
        print(generatedPassword)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
