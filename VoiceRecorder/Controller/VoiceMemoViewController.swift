//
//  ViewController.swift
//  VoiceRecorder
//

import AVFoundation
import UIKit

import FirebaseStorage

class VoiceMemoViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    // MARK: - Properties
    
    private var audioLocalUrls: [URL] = []
    private var fileNames: [String] = []
    private var fileDurations: [String] = []
    private var isFetching: Bool = false
    
    private var player: AVAudioPlayer?
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchRecordingData()
    }
    
    // MARK: - Methods
    
    private func fetchRecordingData() {
        FireStorageManager.shared.fetchData { results in
            self.audioLocalUrls = results
            self.createFileName(urls: results)
            self.getFileDuration(urls: results)
            DispatchQueue.main.async {
                self.voiceMemoTableView.reloadData()
                if self.isFetching {
                    self.voiceMemoTableView.refreshControl?.endRefreshing()
                    self.isFetching = false
                }
            }
            
        }
    }
    
    private func createFileName(urls: [URL]) {
        fileNames = urls.map { url -> String in
            let urlToString = url.absoluteString
            let findIndex = urlToString.index(urlToString.endIndex, offsetBy: -33)
            let endIndex = urlToString.index(urlToString.endIndex, offsetBy: -4)
            let fileName = String(urlToString[findIndex..<endIndex])
            return fileName
        }
    }
    
    private func getFileDuration(urls: [URL]) {
        
        fileDurations = urls.map { url -> String in
            var durationTime: String = ""
            
            do {
                player = try AVAudioPlayer.init(contentsOf: url)
                if let duration = player?.duration {
                    durationTime = duration.minuteSecond
                }
            } catch {
                print("Error: <getFileDuration> - \(error.localizedDescription)")
            }
            return durationTime
        }
    }
    
    
    private func configureTableView() {
        
        let cell = UINib(nibName: VoiceMemoTableViewCell.identifier, bundle: nil)
        voiceMemoTableView.register(cell, forCellReuseIdentifier: VoiceMemoTableViewCell.identifier)
        voiceMemoTableView.delegate = self
        voiceMemoTableView.dataSource = self
        
        voiceMemoTableView.refreshControl = UIRefreshControl()
        voiceMemoTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    // MARK: - @objc
    
    @objc func pullToRefresh() {
        isFetching = true
        fetchRecordingData()
    }
}

// MARK: - Extensions

extension VoiceMemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioLocalUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoTableViewCell.identifier, for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }
        
        cell.timelineLabel.text = fileNames[indexPath.row]
        cell.durationLabel.text = fileDurations[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FireStorageManager.shared.deleteRecording(fileNames[indexPath.row])
            FireStorageManager.shared.deleteImage(fileNames[indexPath.row])
            do {
                try FileManager.default.removeItem(at: audioLocalUrls[indexPath.row])
            } catch {
                print("Error: <tableView firebase delete> - \(error.localizedDescription)")
            }
            audioLocalUrls.remove(at: indexPath.row)
            fileNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension VoiceMemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playingVC = self.storyboard?.instantiateViewController(withIdentifier: PlayingViewController.identifier) as? PlayingViewController else {return}
        playingVC.fileName = fileNames[indexPath.row]
        playingVC.fileURL = audioLocalUrls[indexPath.row]
        present(playingVC, animated: true)
    }
    
}

