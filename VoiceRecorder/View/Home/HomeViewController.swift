//
//  HomeViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFAudio
import Combine

class HomeViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identfier)
        return tableView
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        return activityIndicatorView
    }()
    
    private let viewModel = HomeViewModel()
    
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        viewModel.fetch()
    }
}

// MARK: - Private

private extension HomeViewController {
    func configure() {
        configureView()
        configureNavigation()
        addSubViews()
        makeConstraints()
        bind()
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
        [tableView, activityIndicatorView].forEach {
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [tableView, activityIndicatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func touchAddButton() {
        let session = AVAudioSession.sharedInstance()
        
        switch session.recordPermission {
        case .granted:
            let recordController = RecordViewController()
            recordController.delegate = self
            present(recordController, animated: true)
        } else {
            
            // TODO: - 권한 유도 다시 해주기
            
            AVAudioSession.sharedInstance().requestRecordPermission { isPermission in
                self.permission = isPermission
            }
            let alertController = UIAlertController(title: "", message: "설정에서 마이크 권한을 허용해주세요.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alertController, animated: true)
        case .undetermined:
            session.requestRecordPermission { _ in
            }
        default: break
        }
    }
    
    func bind() {
        viewModel.$audios
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellable)
        
        viewModel.$isReady
            .receive(on: DispatchQueue.main)
            .sink { isReady in
                if isReady {
                    self.activityIndicatorView.stopAnimating()
                } else {
                    self.activityIndicatorView.startAnimating()
                }
            }
            .store(in: &cancellable)
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
        cell.configureAudio(audio)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = viewModel.audio(at: indexPath.row)
        let playViewController = PlayViewController()
        playViewController.configureAudio(audio)
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
