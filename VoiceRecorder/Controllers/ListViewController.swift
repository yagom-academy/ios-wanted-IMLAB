//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var recordListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordListTableView.delegate = self
        recordListTableView.dataSource = self
        recordListTableView.register(UINib(nibName: "RecordListTableViewCell", bundle: nil), forCellReuseIdentifier: "RecordListTableViewCell")
        
        
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordListTableView.dequeueReusableCell(withIdentifier: "RecordListTableViewCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let playVC = storyboard?.instantiateViewController(withIdentifier: "PlayViewController") as! PlayViewController
        
        self.present(playVC, animated: true, completion: nil)
    }
    
    
}
