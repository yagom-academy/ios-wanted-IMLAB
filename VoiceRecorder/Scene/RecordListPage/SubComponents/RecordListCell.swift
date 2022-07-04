//
//  RecordListCell.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListCell: UITableViewCell {
    static let identifier = "RecordListCell"
    private var isSetGesture: Bool = false
    private var action: ((_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> ())?
    
    private let titleLabel = UILabel()
    private let swipeTapView = UIImageView(image: UIImage(systemName: "text.justify"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16))
    }
    
    func setData(filename: String) {
        self.titleLabel.text = filename
    }
    
    func addTapGesture(action: @escaping (_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> ()) {
        if (isSetGesture == false) {
            isSetGesture = true
            
            self.action = action
            swipeTapView.isUserInteractionEnabled = true
            let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(connector(with:)))
            longPressedGesture.minimumPressDuration = 0
            //        longPressedGesture.delegate = self
            longPressedGesture.delaysTouchesBegan = true
            swipeTapView.addGestureRecognizer(longPressedGesture)
        }
    }
    
    @objc func connector(with sender: UILongPressGestureRecognizer) {
        let pointAtCell = sender.location(in: self)
        let toCenterPoint = CGPoint(x: pointAtCell.x-self.frame.width/2, y: pointAtCell.y-self.frame.height/2)
        self.action?(sender, toCenterPoint)
    }
    
    private func attribute() {
        self.selectionStyle = .none
        //temp
        self.contentView.backgroundColor = .purple
    }
    
    private func layout() {
        [titleLabel, swipeTapView].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30).isActive = true
        
        swipeTapView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        swipeTapView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
    }
}
