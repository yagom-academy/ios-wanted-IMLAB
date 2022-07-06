//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var recordListTableView: UITableView!
    
    // MARK: - UI Components
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(
            self,
            action: #selector(beginRefresh),
            for: .valueChanged
        )
        return control
    }()
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var recordList = [RecordModel]() {
        didSet {
            recordList = Array(Set(recordList))
            recordList.sort { $0.name > $1.name }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupRecordListTableView()
        fetchRecordFile()
    }
    
    // MARK: - @IBAction
    @IBAction func didTapShowRecordView(_ sender: UIBarButtonItem) {
        guard let recordVC = storyboard?.instantiateViewController(
            withIdentifier: "RecordViewController"
        ) as? RecordViewController else { return }
        
        recordVC.modalPresentationStyle = .popover
        recordVC.delegate = self
        present(recordVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let playVC = storyboard?.instantiateViewController(
            withIdentifier: "PlayViewController"
        ) as? PlayViewController else { return }
        
        playVC.recordFile = recordList[indexPath.row]
        present(playVC, animated: true, completion: nil)
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            LocalFileManager(recordModel: recordList[indexPath.row]).deleteToLocal()
            StorageManager.shared.delete(fileName: recordList[indexPath.row].name) { result in
                switch result {
                case .success(_ ):
                    self.recordList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    func tableView(
        _ tableView: UITableView,
       cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "RecordListTableViewCell", for: indexPath
            ) as? RecordListTableViewCell else { return UITableViewCell() }
            
            cell.setUpView(recordFile: recordList[indexPath.row])
            return cell
        }
}

// MARK: - RecordViewControllerDelegate
extension ListViewController: RecordViewControllerDelegate {
    func recordView(didFinishRecord: Bool) {
        fetchRecordFile()
    }
}

// MARK: - @objc Methods
private extension ListViewController {
    @objc func beginRefresh(_ sender: UIRefreshControl) {
        recordList = []
        fetchRecordFile()
        sender.endRefreshing()
    }
}

// MARK: - Methods
private extension ListViewController {
    func fetchRecordFile() {
        if !self.refreshControl.isRefreshing {
            activityIndicator.startAnimating()
        }
        StorageManager.shared.get { result in
            switch result {
            case .success(let recordFile):
                self.recordList.append(recordFile)
                self.recordListTableView.reloadData()
                self.activityIndicator.stopAnimating()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🐸")
            }
        }
    }
}

// MARK: - UI Methods
private extension ListViewController {
    func configureUI() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func setupRecordListTableView() {
        recordListTableView.refreshControl = refreshControl
        recordListTableView.delegate = self
        recordListTableView.dataSource = self
        recordListTableView.register(
            UINib(nibName: "RecordListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RecordListTableViewCell"
        )
    }
}

