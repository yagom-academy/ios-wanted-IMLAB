//
//  VoiceRecorderListTableViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class VoiceRecorderListTableViewController: UITableViewController {

    var addButton: UIBarButtonItem = {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action:nil)
        return addButton
    }()
    
    let recordVoiceListViewModel = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    func setUp() {
        navigationItem.title = "Voice Memos"
        setAddBarButton()
        setTableView()
    }
    
    func setAddBarButton() {
        addButton.target = self
        addButton.action = #selector(tabAddButton)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func tabAddButton() {
        self.performSegue(withIdentifier: "RecordVoice", sender: self)
    }
    
    func setTableView() {
        tableView.register(VoiceRecordTableViewCell.self, forCellReuseIdentifier: VoiceRecordTableViewCell.g_identifier)
        tableView.rowHeight = 45
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordVoiceListViewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceRecordTableViewCell.g_identifier, for: indexPath) as? VoiceRecordTableViewCell else {
            fatalError()
        }
        cell.createVoiceRecordDateLable.text = "hello"
        cell.voiceRecordLengthLabel.text = "hello"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "PlayVoice", sender: self)
    }
}
