//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController {
    
    // MARK: - Properties
    let pathFinder: PathFinder!
    let audioManager: AudioManager!
    let firebaseManager: FirebaseStorageManager!
    
    weak var coordinator: AppCoordinator?
    
    private var voiceMemoListAllData: [String] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonPressed))
        return button
    }()
    
    // MARK: - Life Cycle
    
    init(pathFinder: PathFinder, audioManager: AudioManager, firebaseManager: FirebaseStorageManager) {
        self.pathFinder = pathFinder
        self.audioManager = audioManager
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchFirebaseListAll()
        createObservers()
    }
}

extension VoiceMemoListViewController {
    // MARK: - Method
    
    private func configureUI() {
        view.backgroundColor = .white
        self.navigationItem.title = "Voice Memos"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightButton
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
    }
    
    private func configureTableView() {
        tableView.register(VoiceMemoCell.self, forCellReuseIdentifier: VoiceMemoCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchFirebaseListAll() {
        firebaseManager.listAll { result in
            switch result {
            case .success(let voiceMemoList):
                
                self.voiceMemoListAllData = voiceMemoList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func convertSecToMin(time: String) ->
    String {
        guard let time = Int(time) else { return ""}
        
        let min = String(format: "%02d", time / 60)
        let sec = String(format: "%02d", time % 60)
        return "\(min):\(sec)"
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(recordViewUploadComplete(_:)), name: .recordViewUploadComplete, object: nil)
    }
    
    // MARK: - Action Method
    @objc private func buttonPressed() {
        self.coordinator?.presentRecordView()
    }
    
    @objc func recordViewUploadComplete(_ sender: NSNotification) {
        DispatchQueue.main.async {
            self.fetchFirebaseListAll()
        }
    }
}

extension VoiceMemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceMemoListAllData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoCell.identifier, for: indexPath) as! VoiceMemoCell
        let name = voiceMemoListAllData[indexPath.row].description
        
        firebaseManager.getMetaData(fileName: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let time):
                    let convertTime  = self.convertSecToMin(time: time)
                    cell.fileTimeLabel.text = convertTime
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        }
        
        cell.fileNameLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let target = voiceMemoListAllData[indexPath.row]
        var targetSliced = target.components(separatedBy: "/")
        targetSliced.removeFirst()
        let  joinTarget = targetSliced.joined(separator: "/")
        print("join!" ,joinTarget)
        let isExist = pathFinder.checkLocalIsExist(fileName: joinTarget)
        
        if !isExist {
            firebaseManager.fetchVoiceMemoAtFirebase(with: joinTarget, localPath: pathFinder.getPath(fileName: joinTarget)) { result in
                switch result {
                case .success(_):
                    self.coordinator?.presentPlayView(selectedFile: joinTarget)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            self.coordinator?.presentPlayView(selectedFile: joinTarget)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let target = voiceMemoListAllData[indexPath.row]
        var targetSliced = target.components(separatedBy: "/")
        targetSliced.removeFirst()
        let  joinTarget = targetSliced.joined(separator: "/")
        let isExist = pathFinder.checkLocalIsExist(fileName: joinTarget)
        
        if editingStyle == .delete {
            voiceMemoListAllData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            firebaseManager.removeVoiceMemoInFirebase(with: joinTarget) { result in
                switch result {
                case .success(_):
                    if isExist {
                        self.pathFinder.deleteLocalFile(fileName: joinTarget)
                    } else {
                        print("실패")
                    }
                case .failure(let error):
                    print(error.localizedDescription, "삭제실패")
                    
                }
            }
        }
    }
}
