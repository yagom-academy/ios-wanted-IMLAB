//
//  RecordFileCell.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/27.
//

import UIKit

class RecordFileCell: UITableViewCell {

    @IBOutlet weak var fileNameLable: UILabel!
    @IBOutlet weak var recordPlayTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
