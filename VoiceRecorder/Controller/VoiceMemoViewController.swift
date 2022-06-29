//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    // MARK: - Properties
    
    var items: [String] = ["테스트", "ㅁㅁㅁ", "test", "aaa"]

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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMemoTableViewCell", for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }
        
        cell.timelineLabel.text = "test"
        cell.durationLabel.text = "duration"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension VoiceMemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playingVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayingViewController") as? PlayingViewController else {return}
        present(playingVC, animated: true)
    }
}

