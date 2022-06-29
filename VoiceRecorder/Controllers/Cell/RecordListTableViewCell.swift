//
//  RecordListTableViewCell.swift
//  VoiceRecorder
//

import UIKit

class RecordListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         
    }
    
    func setUpView(recordFile: RecordModel) {
        dateTitleLabel.text = recordFile.name
        recordTimeLabel.text = recordFile.playTime
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
