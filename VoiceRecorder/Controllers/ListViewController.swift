//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var recordListTableView: UITableView!
    
    var recordList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecordListTableView()
        StorageManager().get { result in
            switch result {
            case .success(let names):
                self.recordList = names
                self.recordListTableView.reloadData()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🐸")
            }
        }
        
    }
    
    @IBAction func didTapShowRecordView(_ sender: UIBarButtonItem) {
        guard let recordVC = storyboard?.instantiateViewController(withIdentifier: "RecordViewController")
                as? RecordViewController else { return }
        recordVC.modalPresentationStyle = .popover
        recordVC.delegate = self
        self.present(recordVC, animated: true)
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = recordListTableView.dequeueReusableCell(
            withIdentifier: "RecordListTableViewCell", for: indexPath) as? RecordListTableViewCell else { return UITableViewCell() }
            cell.setUpView(name: recordList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let playVC = storyboard?.instantiateViewController(withIdentifier: "PlayViewController")
                as? PlayViewController else { return }
        self.present(playVC, animated: true, completion: nil)
    }
}

private extension ListViewController {
    func setupRecordListTableView() {
        recordListTableView.delegate = self
        recordListTableView.dataSource = self
        recordListTableView.register(
            UINib(nibName: "RecordListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RecordListTableViewCell"
        )
    }
}

extension ListViewController: RecordViewControllerDelegate {
    func didFinishRecord() {
        StorageManager().get { result in
            switch result {
            case .success(let names):
                self.recordList = names
                self.recordListTableView.reloadData()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🐸")
            }
        }
    }
    
    
}
