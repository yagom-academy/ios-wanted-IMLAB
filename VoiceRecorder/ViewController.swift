//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.view.backgroundColor = .white
        self.title = " 녹음기 "
        
        let barButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton))
        self.navigationItem.rightBarButtonItem = barButton
        
        //temp
        self.tableView.backgroundColor = .blue
    }
    
    private func layout() {
        [tableView].forEach {
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
    }
    
    @objc func didTapRightBarButton() {
        self.navigationController?.pushViewController(RecordViewController(), animated: true)
    }
}

