//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

final class HomeViewController: UIViewController {
    
    
    var homeTableView: UITableView?
    var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setConstraints()
        setDataBinding()
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
    
    func setDataBinding(){
        let group = DispatchGroup()
        DispatchQueue.global().async {
            group.enter()
            self.homeViewModel.fetchAudioTitles {
                group.leave()
            }
            group.wait()
            self.homeViewModel.audioData.values.forEach({ $0.bind { [weak self] metadata in
                DispatchQueue.main.async {
                    guard let title = metadata.filename else {return}
                    guard let index = self?.homeViewModel.audioTitles.firstIndex(of: title) else {return}
//                    self?.homeTableView?.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
                    self?.homeTableView?.reloadData()
                }
            }})
            self.homeViewModel.fetchMetaData()
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

}
