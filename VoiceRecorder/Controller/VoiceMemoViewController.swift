//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
    }

    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    func configureTableView() {
        voiceMemoTableView.register(VoiceMemoTableViewCell.self, forCellReuseIdentifier: "VoiceMemoTableViewCell")
        
        voiceMemoTableView.delegate = self
        voiceMemoTableView.dataSource = self
    }
    
    
}

extension VoiceMemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMemoTableViewCell", for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }
        
        cell.timelineLabel.text = "test"
        cell.durationLabel.text = "duration"
        return cell
    }
    
    
}

extension VoiceMemoViewController: UITableViewDelegate {
    
}

