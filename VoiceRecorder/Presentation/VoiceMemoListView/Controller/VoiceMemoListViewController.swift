//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let pathFinder: PathFinder!
    private let firebaseManager: FirebaseStorageManager!
    
    weak var coordinator: AppCoordinator?
    private var storageSaveDatas: [String] = []
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var presentRecordViewButton: UIBarButtonItem = {
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentRecordViewButtonTouched))
        return button
    }()
    
    // MARK: - Life Cycle
    
    init(pathFinder: PathFinder, firebaseManager: FirebaseStorageManager) {
        
        self.pathFinder = pathFinder
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureTableView()
        configureViewController()
        fetchFirebaseListAll()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordFileListAll(_:)), name: .recordFileUploadComplete, object: nil)
    }
    
}

extension VoiceMemoListViewController {
    
    // MARK: - Method
    
    private func fetchFirebaseListAll() {
        
        firebaseManager.listAll { result in
            
            switch result {
            case .success(let voiceMemoList):
                self.storageSaveDatas = voiceMemoList
                DispatchQueue.main.async { [unowned self] in
                    
                    tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func convertSecondToMinute(time: String) -> String {
        
        guard let time = Int(time) else { return ""}
        let minute = String(format: "%02d", time / 60)
        let second = String(format: "%02d", time % 60)
        return "\(minute):\(second)"
    }
    
    // MARK: - Objc Method
    
    @objc private func presentRecordViewButtonTouched() {
        
        self.coordinator?.presentRecordView()
    }
    
    @objc func fetchRecordFileListAll(_ sender: NSNotification) {
        
        DispatchQueue.main.async {
            
            self.fetchFirebaseListAll()
        }
    }
    
}

// MARK: - UI Design

extension VoiceMemoListViewController {
    
    private func configureTableView() {
        
        tableView.register(VoiceMemoCell.self, forCellReuseIdentifier: VoiceMemoCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureViewController() {
        
        view.backgroundColor = .systemBackground
        self.navigationItem.title = "Voice Memos"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = presentRecordViewButton
        view.addSubview(tableView)
        setConstraintsOfTableView()
    }
    
    private func setConstraintsOfTableView() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
}

extension VoiceMemoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filePathFromStorage = storageSaveDatas[indexPath.row]
        let fileNameWithoutDirectory = filePathFromStorage.components(separatedBy: "/").dropFirst().joined(separator: "/")
        let isExist = pathFinder.checkLocalIsExist(fileName: fileNameWithoutDirectory)
        
        if !isExist {
            firebaseManager.fetchVoiceMemoAtFirebase(with: fileNameWithoutDirectory,
                                                     localPath: pathFinder.getPath(fileName: fileNameWithoutDirectory)
            ) { result in
                
                switch result {
                case .success(_):
                    self.coordinator?.presentPlayView(selectedFile: fileNameWithoutDirectory)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            self.coordinator?.presentPlayView(selectedFile: fileNameWithoutDirectory)
        }
    }
    
}

extension VoiceMemoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return storageSaveDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoCell.identifier, for: indexPath) as? VoiceMemoCell else {
            return UITableViewCell()
        }
        
        let name = storageSaveDatas[indexPath.row].description
        cell.selectionStyle = .none
        
        firebaseManager.getMetaData(fileName: name) { result in
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let time):
                    let convertTime  = self.convertSecondToMinute(time: time)
                    cell.playTimeLabel.text = convertTime
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        }
        
        cell.fileTitleLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let filePathFromStorage = storageSaveDatas[indexPath.row]
        let fileNameWithoutDirectory = filePathFromStorage.components(separatedBy: "/").dropFirst().joined(separator: "/")
        let isExist = pathFinder.checkLocalIsExist(fileName: fileNameWithoutDirectory)
        
        if editingStyle == .delete {
            
            if isExist {
                self.pathFinder.deleteLocalFile(fileName: fileNameWithoutDirectory)
            }
            
            firebaseManager.removeVoiceMemoInFirebase(with: fileNameWithoutDirectory) { [unowned self] result in
                
                switch result {
                case .success(_):
                    storageSaveDatas.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
