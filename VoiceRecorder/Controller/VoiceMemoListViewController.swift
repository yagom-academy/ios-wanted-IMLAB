//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController, FinishRecord {
    
    @IBOutlet weak var recordFileListTableView: UITableView!
    
    var voiceMemoList: [RecordModel] = [RecordModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFirebaseStorageFileList()
        recordFileListTableView.delegate = self
        recordFileListTableView.dataSource = self
    }
    func finsihRecord(fileName: String, totalTime: String) {
        let fileName = subStringFileName(filePath:fileName)
        let recordModel = RecordModel(recordFileName: fileName, recordTime: totalTime)
        
        DispatchQueue.main.async {
            self.voiceMemoList.append(recordModel)
            self.recordFileListTableView.reloadData()
        }
    }
    
    func getFirebaseStorageFileList() {
        FirebaseStorage.shared.getFileList { result in
            switch result {
            case .success(let fileList) :
                var count = 0
                if fileList.count == 0 { return }
                for fileName in fileList {
                    FirebaseStorage.shared.getFileMetaData(fileName: fileName) { result in
                        switch result {
                        case .success(let totalTime) :
                            count += 1
                            let subFileName = self.subStringFileName(filePath: fileName, true)
                            
                            self.voiceMemoList.append(RecordModel(recordFileName: subFileName, recordTime: totalTime))
                            if count == fileList.count {
                                DispatchQueue.main.async {
                                    self.recordFileListTableView.reloadData()
                                }
                            }
                        case .failure(let error) :
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    func subStringFileName(filePath: String,_ isFirabse : Bool = false) -> String {
        var fileName = ""
        
        if isFirabse{
            fileName = subString(subString(filePath, "/"),"_")
        } else {
            fileName = subString(filePath, "_")
        }
        
        return fileName
    }
    
    func subString(_ fileName: String, _ character: Character) -> String{
        let index = fileName.firstIndex(of: character) ?? fileName.startIndex
        let range = fileName.index(after: index)..<fileName.endIndex
        return String(fileName[range])
    }
    
    @IBAction func addRecordMemo(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordingViewController") as? RecordingViewController else { return }
        vc.delegate = self
        present(vc, animated: true)
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
