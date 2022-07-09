//
//  HomeViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFAudio
import Combine

final class HomeViewController: UIViewController {
    enum HomeConstants {
        static let navigationTitle = "음성 메모장"
        static let alertMicrophoneTitle = "설정에서 마이크 권한을 허용해주세요."
        static let alertRemoveRecordTitle = "녹음파일 삭제"
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: Constants.TableViewCellIdentifier.home)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        refreshControl.isHidden = true
        return refreshControl
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
    
    func configureNavigation() {
        navigationItem.title = HomeConstants.navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchAddButton))
    }
    
    func addSubViews() {
        [tableView].forEach {
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    @objc func touchAddButton() {
        let session = AVAudioSession.sharedInstance()
        
        switch session.recordPermission {
        case .granted:
            presentRecordViewController()
        case .denied:
            let alertController = UIAlertController(title: Constants.Alert.empty, message: HomeConstants.alertMicrophoneTitle, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Constants.Alert.ok, style: .default, handler: nil))
            present(alertController, animated: true)
        case .undetermined:
            session.requestRecordPermission { granted in
                if granted {
                    self.presentRecordViewController()
                }
            }
        default: break
        }
    }
    
    @objc func refreshTableView(_ refreshControl: UIRefreshControl) {
        self.viewModel.fetch()
        refreshControl.endRefreshing()
    }
    
    func bind() {
        viewModel.$audios
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    func presentRecordViewController() {
        DispatchQueue.main.async {
            let recordController = RecordViewController()
            recordController.delegate = self
            self.present(recordController, animated: true)
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
            let alertController = UIAlertController(title: HomeConstants.alertRemoveRecordTitle, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Constants.Alert.cancel, style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: Constants.Alert.ok, style: .default, handler: { _ in
                self.viewModel.deleteAudio(indexPath)
            }))
            present(alertController, animated: true)
        }
    }
}

// MARK: - RecordViewControllerDelegate

extension HomeViewController: RecordViewControllerDelegate {
    func uploadSuccess() {
        viewModel.fetch()
    }
}
