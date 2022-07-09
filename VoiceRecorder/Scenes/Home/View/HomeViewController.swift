//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

import AVFoundation

final class HomeViewController: UIViewController {
  
  private var homeTableView: UITableView?
  private var homeViewModel = HomeViewModel()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    LoadingIndicator.showLoading()
    DispatchQueue.global().async {
      self.checkNetworkConnection()
    }
    homeViewModel.reset()
    setFirebaseNetworkErrorHandler()
    setData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    LoadingIndicator.hideLoading()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNavigationBar()
    setTableView()
    setConstraints()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NetworkMonitor.shared.stopMonitoring()
  }
}

private extension HomeViewController {
  
  func setNavigationBar() {
    title = "Voice Memos"
    let audioCreationButton = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addButtonDidTap))
    navigationItem.rightBarButtonItem = audioCreationButton
  }
  
  @objc func addButtonDidTap() {
    AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
      DispatchQueue.main.async {
        if granted {
          let audioCreationViewController = CreateAudioViewController()
          self.navigationController?.pushViewController(audioCreationViewController, animated: false)
        } else {
          print("마이크 권한 거절")
          guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
              print("마이크 권한 환경설정에서 허용")
            }
          }
        }
      }
    })
  }
  
  func setTableView(){
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(
      HomeTableViewCell.self,
      forCellReuseIdentifier: HomeTableViewCell.id)
    homeTableView = tableView
    homeTableView?.refreshControl = UIRefreshControl()
    homeTableView?.refreshControl?.addTarget(
      self,
      action: #selector(pullToRefresh(_:)),
      for: .valueChanged)
    homeTableView?.translatesAutoresizingMaskIntoConstraints = false
    homeTableView?.delegate = self
    homeTableView?.dataSource = self
  }
  
  @objc func pullToRefresh(_ sender: Any) {
    homeViewModel.reset()
    setData()
    homeTableView?.refreshControl?.endRefreshing()
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
  
  func setData() {
    let group = DispatchGroup()
    DispatchQueue.global().async { [weak self] in
      group.enter()
      self?.homeViewModel.fetchAudioTitles {
        group.leave()
      }
      group.wait()
      DispatchQueue.main.async {
        self?.homeTableView?.reloadData()
      }
      self?.homeViewModel.fetchMetaData{
        self?.bindData()
      }
    }
  }
  
  func bindData() {
    self.homeViewModel.audioData.values.forEach({
      $0.bind { [weak self] metadata in
        DispatchQueue.main.async {
          guard let filename = metadata.filename,
                let index = self?.homeViewModel.audioTitles.firstIndex(of: filename)
          else {
            return
          }
          self?.homeTableView?.reloadRows(
            at: [IndexPath(row: index, section: 0)],
            with: .automatic)
        }
      }})
  }
  
  func setFirebaseNetworkErrorHandler() {
    self.homeViewModel.errorHandler = { error in
      Alert.present(
        title: nil,
        message: error.localizedDescription,
        actions: .ok(nil),
        from: self)
    }
  }
  
  func checkNetworkConnection(){
    NetworkMonitor.shared.startMonitoring{ error in
      DispatchQueue.main.async {
        Alert.present(title: nil,
                      message: error.localizedDescription,
                      actions: .ok({self.presentWifiPreference()}),
                      from: self)
      }
    }
  }
  
  func presentWifiPreference() {
    if let url = URL(string:"App-Prefs:root=WIFI") {
      if UIApplication.shared.canOpenURL(url) {
        if #available(iOS 10.0, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          UIApplication.shared.openURL(url)
        }
      }
    }
  }
  
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: HomeTableViewCell.id) as? HomeTableViewCell
    else {
      return UITableViewCell()
    }
    

    let model = homeViewModel[indexPath]
    cell.configure(model: model)
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    homeViewModel.audioData.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let data = homeViewModel[indexPath] else {return}
    LoadingIndicator.showLoading()
    self.checkNetworkConnection()
    homeViewModel.enquireForURL(data) { url in
      guard let url = url else {return}
      let playScene = PlayViewController(url)
      self.navigationController?.pushViewController(playScene, animated: true)

    }
  }
  
  func tableView(
    _ tableView: UITableView,
    commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath) {
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

