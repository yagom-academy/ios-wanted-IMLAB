//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var recordListTableView: UITableView!
    
    var recordList = [RecordModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecordListTableView()
        StorageManager.shared.get { result in
            switch result {
            case .success(let recordFile):
                self.recordList.append(recordFile)
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "RecordListTableViewCell", for: indexPath) as? RecordListTableViewCell else { return UITableViewCell() }
            cell.setUpView(recordFile: recordList[indexPath.row])
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let playVC = storyboard?.instantiateViewController(withIdentifier: "PlayViewController")
                as? PlayViewController else { return }
        playVC.recordFile = recordList[indexPath.row]
        self.present(playVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StorageManager.shared.delete(fileName: recordList[indexPath.row].name) { result in
                switch result {
                case .success(_ ):
                    self.recordList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
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
        recordList = []
        StorageManager.shared.get { result in
            switch result {
            case .success(let recordFile):
                self.recordList.append(recordFile)
                self.recordListTableView.reloadData()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🐸")
            }
        }
    }
}
