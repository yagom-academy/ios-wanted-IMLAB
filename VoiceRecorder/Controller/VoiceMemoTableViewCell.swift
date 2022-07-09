//
//  VoiceMemoTableViewCell.swift
//  VoiceRecorder
//
//  Created by BH on 2022/06/27.
//

import UIKit

class VoiceMemoTableViewCell: UITableViewCell {
    
    static let identifier: String = "VoiceMemoTableViewCell"

    @IBOutlet weak var timelineLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
