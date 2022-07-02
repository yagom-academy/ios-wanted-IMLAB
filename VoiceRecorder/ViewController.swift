//
//  ViewController.swift
//  VoiceRecorder
//
import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var filemanager = AudioFileManager()
    
    var firebaseManager = FirebaseStorageManager(FireStorageService.baseUrl)
    
    
    lazy var createFileButton: UIButton = {
        var button = UIButton()
        button.setTitle("create", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var getFileButton: UIButton = {
        var button = UIButton()
        button.setTitle("get", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        createFileButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        
        getFileButton.addTarget(self, action: #selector(getFile), for: .touchUpInside)
        
       
        
    }
    
    func setLayout() {
        
        view.backgroundColor = .white
        
        createFileButton.translatesAutoresizingMaskIntoConstraints = false
        getFileButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(createFileButton)
        view.addSubview(getFileButton)
        
        NSLayoutConstraint.activate([
            createFileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            createFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).constraintWithMultiplier(0.5),
            createFileButton.widthAnchor.constraint(equalToConstant: 100),
            
            getFileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            getFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).constraintWithMultiplier(1.5),
            getFileButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    
    
    @objc func plusButtonClicked() {
        filemanager.createVoiceFile(fileName: "test_file.txt")
        
    }
    @objc func getFile() {
    }
}
