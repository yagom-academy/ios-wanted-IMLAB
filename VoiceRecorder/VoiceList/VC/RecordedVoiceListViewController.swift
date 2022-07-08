//
//  ViewController.swift
//  VoiceRecorder
//
import UIKit
import AVKit
import AVFoundation

class RecordedVoiceListViewController: UIViewController {
    
    private let firestorageManager = FirebaseStorageManager()
    private let fileManager = AudioFileManager()
    private var audioMetaDataList: [AudioMetaData] = []
    
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
        
        fileManager.delegate = self
        initializeFirebaseAudioFiles()
        setNavgationBarProperties()
        configureRecordedVoiceListLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNotification(notification:)), name: .dismissVC, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dismissVC, object: nil)
    }
    
    private func initializeFirebaseAudioFiles() {
        firestorageManager.downloadAllRef { [self] result in
            switch result {
            case .success(let data) :
                firestorageManager.downloadMetaData(filePath: data) { [self] metaResult in
                    switch metaResult {
                    case .success(let metaDataList) :
                        audioMetaDataList = metaDataList
                        sortAudioFiles()
                        recordedVoiceTableView.reloadData()
                    case .failure(let error) :
                        print(error)
                    }
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortAudioFiles() {
        audioMetaDataList.sort { data1, data2 in
            return data1.title > data2.title
        }
    }
    
    private func setNavgationBarProperties() {
        let navItem = UINavigationItem(title: "Voice Recorder")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewVoiceRecordButtonAction))
        
        navItem.rightBarButtonItem = doneItem

        navigationBar.setItems([navItem], animated: false)
    }
    
    private func configureRecordedVoiceListLayout() {
        
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
    
    @objc func createNewVoiceRecordButtonAction() {
        let recorderVC = RecordViewController()
        self.present(recorderVC, animated: true)
    }
    
    // TODO: - local에서 추가
    @objc func dismissNotification(notification: NSNotification) {
        audioMetaDataList.removeAll()
        initializeFirebaseAudioFiles()
    }
}

extension RecordedVoiceListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioMetaDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordedVoiceTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordedVoiceTableViewCell
        cell.fetchAudioLabelData(data: audioMetaDataList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voicePlayVC = VoicePlayingViewController() // init시 타이틀 넘김
        voicePlayVC.setTitle(title: audioMetaDataList[indexPath.item].title)
        
        let path = audioMetaDataList[indexPath.item].url
        let filePath = fileManager.getAudioFilePath(fileName: path)
        
        firestorageManager.downloadAudio(path, to: filePath) { url in
            voicePlayVC.fetchRecordedDataFromMainVC(dataUrl: filePath)
        }
        
        self.present(voicePlayVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        firestorageManager.deleteAudio(urlString: audioMetaDataList[indexPath.row].url)
        fileManager.deleteLocalAudioFile(fileName: audioMetaDataList[indexPath.row].url)
        audioMetaDataList.remove(at: indexPath.row)
        recordedVoiceTableView.reloadData()
    }
}

extension RecordedVoiceListViewController: FileStatusReceivable {
    
    func fileManager(_ fileManager: FileManager, error: FileError) {
        let alert = UIAlertController(title: "파일 에러", message: error.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
