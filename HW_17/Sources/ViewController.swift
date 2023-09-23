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
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var generatePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate password", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(passwordGenerated), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("STOP searching", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(stopSearching), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Type password here"
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        return passwordField
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Setups

    private func setupHierarchy() {
        view.addSubview(changeColorButton)
        view.addSubview(generatePasswordButton)
        view.addSubview(passwordField)
        view.addSubview(passwordLabel)
        view.addSubview(stopButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            passwordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (0.2 * (view.bounds.height))),
            
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 10),
            
            generatePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generatePasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            
            changeColorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeColorButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-0.1 * (view.bounds.height)))
        ])
    }
    
    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }
        
        var password: String = ""
        
        while password != passwordToUnlock {
            if self.isStop { return }
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            DispatchQueue.main.sync {
                self.passwordLabel.text = "Is \(password) your password?"
            }
        }
        DispatchQueue.main.sync {
            self.generatePasswordButton.isEnabled = true
            if self.isStop {
                self.isStop.toggle()
                self.passwordLabel.text = "Didn't find your password"
                return
            }
            self.passwordLabel.text = "Done! Your password is \(password)"
            self.passwordField.isSecureTextEntry = false
        }
        print(password)
    }

    // MARK: - Action
    
    @objc func buttonTapped() {
        isBlack.toggle()
    }
    
    @objc func passwordGenerated() {
        generatedPassword = generateRandomPassword()
        passwordField.isSecureTextEntry = true
        passwordField.text = generatedPassword
        print(generatedPassword)
        
        generatePasswordButton.isEnabled = false
        
        queue.async {
            self.bruteForce(passwordToUnlock: self.generatedPassword)
        }
    }
    
    @objc func stopSearching() { isStop = true }
}

