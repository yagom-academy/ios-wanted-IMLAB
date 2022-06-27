//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController {

    @IBOutlet weak var recordFileListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordFileListTableView.delegate = self
        recordFileListTableView.dataSource = self
        // Do any additional setup after loading the view.
    }


}

extension VoiceMemoListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}

extension VoiceMemoListViewController : UITableViewDelegate {
    
}
