//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFAudio

class HomeViewController: UIViewController {
    private var permission: Bool = false
    
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
        checkPermission()
        
        configure()
        
        viewModel.loadingEnded = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.fetch()
    }
}

private extension HomeViewController {
    func configure() {
        configureView()
        configureNavigation()
        addSubViews()
        makeConstraints()
    }
    
    func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    // TODO: - String 관리
    func configureNavigation() {
        navigationItem.title = "음성 메모장"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchAddButton))
    }
    
    func addSubViews() {
        view.addSubview(tableView)
    }
    
    func makeConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    @objc func touchAddButton() {
        if permission {
            let recordController = RecordViewController()
            recordController.delegate = self
            present(recordController, animated: true)
        } else {
            // TODO: - 권한 유도 다시 해주기
            AVAudioSession.sharedInstance().requestRecordPermission { isPermission in
                self.permission = isPermission
            }
            // String
            let alertController = UIAlertController(title: "", message: "설정에서 마이크 권한을 허용해주세요.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alertController, animated: true)
        }
    }
    
    func checkPermission() {
        let session = AVAudioSession.sharedInstance()
        
        switch session.recordPermission {
        case .granted:
            self.permission = true
        case .denied:
            self.permission = false
        case .undetermined:
            session.requestRecordPermission { permission in
                self.permission = permission
            }
        default:
            self.permission = false
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.audiosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identfier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        let audio = viewModel.audio(at: indexPath.row)
        cell.audio = audio
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = viewModel.audio(at: indexPath.row)
        let playViewController = PlayViewController()
        playViewController.audio = audio
        present(playViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "녹음파일 삭제", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.viewModel.deleteAudio(indexPath)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            present(alertController, animated: true)
        }
    }
}

// MARK: - RecordViewControllerDelegate
extension HomeViewController: RecordViewControllerDelegate {
    func recordViewControllerDidDisappear() {
        viewModel.fetch()
    }
}
