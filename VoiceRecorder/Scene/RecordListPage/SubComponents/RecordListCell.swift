//
//  RecordListCell.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListCell: UITableViewCell {
    static let identifier = "RecordListCell"

    private var isSetSwapGesture: Bool = false
    private var swapGestureAction: ((_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> Void)?
    private var isSetFavoriteMarkAction: Bool = false

    private let container = UIStackView()
    
    private let favoriteMark = UIButton()
    
    private let labelContainer = UIStackView()
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()

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

    func addFavoriteMarkAction() {
        if isSetFavoriteMarkAction == false {
            isSetFavoriteMarkAction = true
//            self.favoriteMark.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        }
    }
    
    func addSwapCellTapGesture(action: @escaping (_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) -> Void) {
        if isSetSwapGesture == false {
            isSetSwapGesture = true
            self.swapGestureAction = action
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
        swapGestureAction?(sender, toCenterPoint)
    }

    private func attribute() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor

        contentView.backgroundColor = YagomColor.two.uiColor
        contentView.layer.cornerRadius = 10

        container.axis = .horizontal
        container.distribution = .equalSpacing
        container.alignment = .center
        
        labelContainer.axis = .vertical
        labelContainer.distribution = .equalCentering
        
        favoriteMark.setTitle("☆", for: .normal)
        favoriteMark.titleLabel?.font = .systemFont(ofSize: 25)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18)
        
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 15)

        swipeTapView.tintColor = YagomColor.three.uiColor
    }

    private func layout() {
        self.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        [titleLabel, durationLabel].forEach {
            labelContainer.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let leftPadding = UIView()
        let rightPadding = UIView()
        
        [leftPadding, favoriteMark, labelContainer, swipeTapView, rightPadding].forEach {
            container.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        leftPadding.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.01).isActive = true
        
        favoriteMark.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.1).isActive = true
        
        labelContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.7).isActive = true

        swipeTapView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.1).isActive = true
        swipeTapView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.5).isActive = true

        rightPadding.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.01).isActive = true
    }
}
