import UIKit

class DeletePopupView: UIView {
    
    let statusLabel : UILabel = {
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        setUp()
        autoLayOut()
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(){
        backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.00)
        addSubview(statusLabel)
    }
    
    func autoLayOut(){
        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
}

extension DeletePopupView{
    
    func showView(){
        self.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.00)
        self.statusLabel.text = "삭제중"
        self.statusLabel.textColor = .white
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }

    }
    
    func completeDelete(completion : @escaping ()->Void){
        UIView.animate(withDuration: 0.1) {
            self.statusLabel.text = "삭제완료"
            self.statusLabel.textColor = .white
            self.backgroundColor = UIColor(red: 0.10, green: 0.74, blue: 0.61, alpha: 1.00)
        } completion: { _ in
            self.hiddenView {
                completion()
            }
        }
    }
    
    func hiddenView(completion : @escaping ()->Void){
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0.0
        }completion: { _ in
            completion()
        }
    }
}
