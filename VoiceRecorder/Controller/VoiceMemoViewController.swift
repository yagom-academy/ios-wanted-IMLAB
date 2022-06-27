//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    // MARK: - Properties

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
    }
    
    // MARK: - IBActions
    
    @IBAction func moveToRecordDetail(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Methods
    
    func configureTableView() {

        let cell = UINib(nibName: "VoiceMemoTableViewCell", bundle: nil)
        voiceMemoTableView.register(cell, forCellReuseIdentifier: "VoiceMemoTableViewCell")
        
        voiceMemoTableView.delegate = self
        voiceMemoTableView.dataSource = self
    }
    
    
}

// MARK: - Extensions

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

