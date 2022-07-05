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
    
    // MARK: - Action Method
    @objc private func buttonPressed() {
        self.coordinator?.presentRecordView()
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
                    cell.fileTimeLabel.text = time
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        }
        
        cell.fileNameLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.coordinator?.presentPlayView(selectedFile: "")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            voiceMemoListAllData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
}
