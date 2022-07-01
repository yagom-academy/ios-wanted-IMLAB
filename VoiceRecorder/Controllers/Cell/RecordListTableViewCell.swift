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
        dateTitleLabel.text = "\(StoragePath.voiceRecords.rawValue)_" + recordFile.name.dropLast(4)
        recordTimeLabel.text = recordFile.audioPlayer.duration.toString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
