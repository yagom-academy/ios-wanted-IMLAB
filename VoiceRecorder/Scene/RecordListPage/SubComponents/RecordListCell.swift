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
    private var action: ((_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> Void)?

    private let labelContainer = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)

        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white

        return label
    }()

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

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
    }

    func setData(data: FileData) {
        titleLabel.text = data.filename
        durationLabel.text = data.duration
    }

    func addTapGesture(action: @escaping (_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> Void) {
        if isSetGesture == false {
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
        let toCenterPoint = CGPoint(x: pointAtCell.x - frame.width / 2, y: pointAtCell.y - frame.height / 2)
        action?(sender, toCenterPoint)
    }

    private func attribute() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor

        contentView.backgroundColor = YagomColor.two.uiColor
        contentView.layer.cornerRadius = 10

        titleLabel.textColor = .white

        swipeTapView.tintColor = YagomColor.three.uiColor
    }

    private func layout() {
        [titleLabel, durationLabel].forEach {
            labelContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 20).isActive = true

        durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor).isActive = true

        [labelContainer, swipeTapView].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        labelContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        swipeTapView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        swipeTapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        swipeTapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        swipeTapView.widthAnchor.constraint(equalTo: swipeTapView.heightAnchor).isActive = true
    }
}
