//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

final class HomeViewController: UIViewController {
    
    
    var homeTableView: UITableView?
    var homeViewModel = HomeViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeViewModel.reset()
        self.setDataBinding()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setConstraints()
    }
    
}

private extension HomeViewController {
    
    func setNavigationBar() {
        title = "Voice Memos"
        let audioCreationButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = audioCreationButton
    }
    
    @objc func didTapAddButton() {
        //TODO: Push AudioCreation VC
        let audioCreationViewController = CreateAudioViewController()
        navigationController?.pushViewController(audioCreationViewController, animated: true)
    }
    
    func setTableView(){
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
        homeTableView = tableView
        homeTableView?.translatesAutoresizingMaskIntoConstraints = false
        homeTableView?.delegate = self
        homeTableView?.dataSource = self
    }
    
    func setConstraints() {
        guard let homeTableView = homeTableView else {return}
        view.addSubview(homeTableView)
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setDataBinding() {
        let group = DispatchGroup()
        DispatchQueue.global().async {
            group.enter()
            self.homeViewModel.fetchAudioTitles {
                group.leave()
            }
            group.wait()
            
            DispatchQueue.main.async {
                self.homeTableView?.reloadData()
            }
            
            self.homeViewModel.fetchMetaData()
            self.homeViewModel.audioData.values.forEach({ $0.bind { [weak self] metadata in
                DispatchQueue.main.async {
                    guard let filename = metadata.filename, let index = self?.homeViewModel.audioTitles.firstIndex(of: filename) else {return}
                    self?.homeTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }})
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id) as? HomeTableViewCell else {return UITableViewCell()}
        
        let model = homeViewModel[indexPath]
        cell.configure(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeViewModel.audioData.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = homeViewModel[indexPath], let fileName = data.filename else {return}
        let endPoint = EndPoint(fileName: fileName)
        FirebaseService.makeURL(endPoint: endPoint) { result in
            switch result {
            case .success(let url):
                let playScene = PlayViewController()
                playScene.url = url
                self.navigationController?.pushViewController(playScene, animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            homeViewModel.remove(indexPath: indexPath){ isRemoved in
                if isRemoved{
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.reloadData()
                }
            }
        }
    }
}
