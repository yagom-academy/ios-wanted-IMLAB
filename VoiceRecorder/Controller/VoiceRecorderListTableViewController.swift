//
//  VoiceRecorderListTableViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class VoiceRecorderListTableViewController: UITableViewController {

    var addButton: UIBarButtonItem = {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        return addButton
    }()
    
    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUp()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        tableView.register(VoiceRecordTableViewCell.self, forCellReuseIdentifier: "ReusableCell")
        tableView.rowHeight = 60
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? VoiceRecordTableViewCell else {
            fatalError()
        }
        print("123123")
        cell.fileNameLabel.text = "hello"
        cell.timeLabel.text = "hello"
        return cell
    }
    
}
