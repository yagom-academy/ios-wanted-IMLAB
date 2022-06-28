//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class VoiceMemoListViewController: UIViewController {
    

    // MARK: - Properties
    
    let voiceMemoData: [VoiceData] = [
        VoiceData(title: "2022. 05. 08 12:33:44", time: "01:33"),
        VoiceData(title: "2022. 05. 08 12:38:44", time: "02:11"),
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonPressed))
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
    }
}


extension VoiceMemoListViewController {
    // MARK: - Method
    private func configureUI() {
        view.backgroundColor = .white
        self.navigationItem.title = "Voice Memos"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightButton
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])
        
    }
    
    private func configureTableView() {
        tableView.register(VoiceMemoCell.self, forCellReuseIdentifier: VoiceMemoCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Action Method
    @objc private func buttonPressed() {
        print("두번째 화면으로 이동")
    }
}

extension VoiceMemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceMemoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoCell.identifier, for: indexPath) as! VoiceMemoCell
        cell.fileNameLabel.text = voiceMemoData[indexPath.row].title
        cell.fileTimeLabel.text = voiceMemoData[indexPath.row].time
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //세번째 화면으로 이동
        
    }
}
