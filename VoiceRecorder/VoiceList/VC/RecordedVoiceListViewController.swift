//
//  ViewController.swift
//  VoiceRecorder
//
import UIKit
import AVKit
import AVFoundation

class RecordedVoiceListViewController: UIViewController {
    
    lazy var navigationBar: UINavigationBar = {
        var navigationBar = UINavigationBar()
        return navigationBar
    }()
    
    lazy var recordedVoiceTableView: UITableView = {
        var tableView = UITableView()
        tableView.register(RecordedVoiceTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavgationBarProperties()
        configureRecordedVoiceListLayout()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view Will Appear")
    }
    
    func setNavgationBarProperties() {

        let navItem = UINavigationItem(title: "Voice Recorder")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getFile))
        
        navItem.rightBarButtonItem = doneItem

        navigationBar.setItems([navItem], animated: false)
    }
    
    func configureRecordedVoiceListLayout() {
        
        view.backgroundColor = .white
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        recordedVoiceTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navigationBar)
        view.addSubview(recordedVoiceTableView)
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44),
            
            recordedVoiceTableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            recordedVoiceTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            recordedVoiceTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordedVoiceTableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
    }
    
    
    @objc func getFile() {
        let recorderVC = VoicePlayingViewController() // bar button 확인용 임시 vc
        self.present(recorderVC, animated: true)
    }
    
    
    
    
}

extension RecordedVoiceListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return audioDataList.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordedVoiceTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordedVoiceTableViewCell
        
        cell.setTableViewCellLayout()
        //cell.fetchAudioLabelData(data: audioDataList[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voicePlayVC = VoicePlayingViewController()
        if let sheet = voicePlayVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        //voicePlayVC.fetchRecordedDataFromMainVC(data: audioDataList[indexPath.row])
        self.present(voicePlayVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
