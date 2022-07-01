//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class HomeViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identfier)
        return tableView
    }()
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.configure()
        
        self.viewModel.loadingEnded = { [weak self] in
            self?.tableView.reloadData()
        }
        
        self.viewModel.fetch()
    }
    
    
    func setupLayOut(){
        
    }
}

private extension HomeViewController {
    func configure() {
        self.configureNavigation()
        self.addSubViews()
        self.makeConstraints()
    }
    
    func configureNavigation() {
        self.navigationItem.title = "Voice Memos"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchAddButton))
    }
    
    func addSubViews() {
        
        [tableView].forEach{
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    @objc func touchAddButton() {
        let controller = RecordViewController()
        self.present(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.audiosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identfier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        let audio = self.viewModel.audio(at: indexPath.row)
        cell.audio = audio
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = self.viewModel.audio(at: indexPath.row)
        let playViewController = PlayViewController()
        playViewController.audio = audio
        self.present(playViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //TODO: - 삭제 메소드 추가
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            viewModel.deleteAudio(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
