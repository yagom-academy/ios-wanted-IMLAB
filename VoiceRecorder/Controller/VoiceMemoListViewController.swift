//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController {

    @IBOutlet weak var recordFileListTableView: UITableView!
    
    var voiceMemoList: [RecordModel] = [
        RecordModel(recordFileName: "spring", recordTime: "03:00"),
        RecordModel(recordFileName: "summer", recordTime: "02:11"),
        RecordModel(recordFileName: "winter", recordTime: "04:28")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordFileListTableView.delegate = self
        recordFileListTableView.dataSource = self
        // Do any additional setup after loading the view.
    }


}

extension VoiceMemoListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.voiceMemoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordFileCell", for: indexPath) as? RecordFileCell else { return UITableViewCell() }
        cell.fileNameLable.text = self.voiceMemoList[indexPath.row].recordFileName
        cell.recordPlayTimeLabel.text = self.voiceMemoList[indexPath.row].recordTime
        return cell
    }
    
    
}

extension VoiceMemoListViewController : UITableViewDelegate {
    
}
