//
//  VoiceRecorderListTableViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class VoiceRecorderListTableViewController: UITableViewController{
    
    var statusView : DeletePopupView = {
        let statusView = DeletePopupView()
        statusView.translatesAutoresizingMaskIntoConstraints = false
        return statusView
    }()
    
    var addButton: UIBarButtonItem = {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action:nil)
        return addButton
    }()
    
    let firebaseStorageManger = FirebaseStorageManager()
    var voiceRecordListViewModel : VoiceRecordListViewModel = VoiceRecordListViewModel(voiceRecordList: [])
    var selectRecord : VoiceRecordViewModel?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUp()
        updateTableViewList()
        configureRefreshControl()
    }
    
    func setUp(){
        navigationItem.title = "Voice Memos"
        setAddBarButton()
        setTableView()
    }
    
    @objc func updateTableViewList(){
        firebaseStorageManger.fetchRecordList { result in
            if let result = result{
                self.voiceRecordListViewModel = VoiceRecordListViewModel(voiceRecordList: result)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.isUserInteractionEnabled = true
                }
            }
        }
        
    }
    
    func setAddBarButton(){
        addButton.target = self
        addButton.action = #selector(tabAddButton)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func tabAddButton(){
        self.performSegue(withIdentifier: "RecordVoice", sender: self)
    }
    
    func setTableView(){
        tableView.register(VoiceRecordTableViewCell.self, forCellReuseIdentifier: VoiceRecordTableViewCell.g_identifier)
        tableView.rowHeight = CNS.size.tableViewRowHeight
    }
    
    func configureRefreshControl(){
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(updateTableViewList), for: .valueChanged)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int{
        return self.voiceRecordListViewModel.numOfList()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)->UITableViewCell{
        let voiceRecodeFile = voiceRecordListViewModel.ListAtIndex(index: indexPath.row)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceRecordTableViewCell.g_identifier, for: indexPath) as? VoiceRecordTableViewCell else {
            fatalError()
        }
        cell.createVoiceRecordDateLable.text = voiceRecodeFile.fileName
        cell.voiceRecordLengthLabel.text = voiceRecodeFile.fileLength
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        let voiceRecodeFile = voiceRecordListViewModel.ListAtIndex(index: indexPath.row)
        if editingStyle == .delete {
            self.firebaseStorageManger.deleteRecord(fileName : voiceRecodeFile.fileName, fileLength: voiceRecodeFile.fileLength) {
                tableView.isUserInteractionEnabled = false
                self.updateTableViewList()
                
                self.statusView.completeDelete(){
                    self.view.viewWithTag(102)?.removeFromSuperview()
                }
            }
            view.addSubview(statusView)
            statusView.tag = 102
            print(statusView.bounds.height)
            statusView.showView()
            
            NSLayoutConstraint.activate([
                statusView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
                statusView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                statusView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            ])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectRecord = voiceRecordListViewModel.ListAtIndex(index: indexPath.row)
        self.performSegue(withIdentifier: "PlayVoice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "PlayVoice"{
            let vc = segue.destination as! PlayVoiceViewController
            if let selectRecord = selectRecord {
                vc.playVoiceViewModel = PlayVoiceViewModel(selectedPitch: .normal, voiceRecordViewModel: selectRecord)
                vc.firebaseDownloadManager = FirebaseStorageDownloadManager(fileName: selectRecord.fileName, fileLength: selectRecord.fileLength)
            }
        }
        else if segue.identifier == "RecordVoice"{
            let vc = segue.destination as! RecordVoiceViewController
            vc.delegate = self
            vc.playVoiceManager = PlayVoiceManager()
            vc.recordVoiceManager = RecordVoiceManager()
            vc.drawWaveFormManager = DrawWaveFormManager()
        }
    }
}

extension VoiceRecorderListTableViewController : RecordVoiceDelegate{
    func updateList() {
        print("Update List")
        updateTableViewList()
    }
}
