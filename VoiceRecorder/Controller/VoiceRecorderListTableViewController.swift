//
//  VoiceRecorderListTableViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class VoiceRecorderListTableViewController: UITableViewController {

    var addButton: UIBarButtonItem = {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: .)
        return addButton
    }()
    
    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
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
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func setTableView() {
        tableView.register(VoiceRecordTableViewCell.self, forCellReuseIdentifier: VoiceRecordTableViewCell.g_identifier)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceRecordTableViewCell.g_identifier, for: indexPath) as? VoiceRecordTableViewCell else {
            fatalError()
        }
        print("123123")
        cell.createVoiceRecordDateLable.text = "hello"
        cell.voiceRecordLengthLabel.text = "hello"
        return cell
    }
    
    @IBAction func tabAddButton() {
        guard let recordVoiceView = self.storyboard?.instantiateViewController(withIdentifier: "RecordVoiceViewController") as? RecordVoiceViewController else {
            fatalError()
        }
        recordVoiceView.modalPresentationStyle = .automatic
        self.present(recordVoiceView, animated: true)
    }
}
