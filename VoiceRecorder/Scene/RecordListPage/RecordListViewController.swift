//
//  RecordListVeiwController.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = RecordListViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        attribute()
        layout()
        setRefresh()
        RecordNetworkManager().saveRecord(filename: "bb")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update {
            self.tableView.reloadData()
        }
    }
    
    private func attribute() {
        title = "Voice Memos"
        view.backgroundColor = .white
        
        AddNavigationbarRightItem()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordListCell.self, forCellReuseIdentifier: RecordListCell.identifier)

        tableView.backgroundColor = .systemPink
    }
    
    private func AddNavigationbarRightItem() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentRecordPage))
        self.navigationItem.rightBarButtonItems = [addButton]
    }
    
    @objc private func presentRecordPage() {
        
        let vc = RecordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func layout() {
        [tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate 메서드
extension RecordListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellTotalCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordListCell.identifier, for: indexPath) as? RecordListCell else {
            return UITableViewCell()
        }
        cell.setData(filename: viewModel.getCellData(indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteCell(indexPath) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: 데이터를 받고나서 페이지를 열지 or 페이지를 열고 데이터를 받아올지 고민하기
//        tableView.allowsSelection = false
//        viewModel.didSelectedCell(indexPath) { [weak self] data in
//            guard let data = data else {
//                self?.tableView.allowsSelection = true
//                return
//            }
//            let vc = ViewController()
//            self?.navigationController?.pushViewController(vc, animated: true)
//            self?.tableView.allowsSelection = true
//        }
        
        let data = viewModel.getCellData(indexPath)
        let vc = PlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - 테이블뷰를 당겼을 때 새로고침시키는 메서드
extension RecordListViewController {
    private func setRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh() {
        self.viewModel.update(completion: {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        })
    }
}
