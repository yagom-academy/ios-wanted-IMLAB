//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit
import FirebaseStorage
import AVFAudio

class VoiceMemoViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    // MARK: - Properties
    
    var localUrls: [URL] = []
    var fileNames: [String] = []
    var fileDurations: [String] = []
    
    var player: AVAudioPlayer?
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchRecordingData()
        
    }
    
    // MARK: - IBActions
    
    @IBAction func moveToRecordDetail(_ sender: UIBarButtonItem) {
        
        
    }
    
    // MARK: - Methods
    
    func fetchRecordingData() {
        FireStorageManager.shared.fetchData { results in
            self.localUrls = results
            self.createFileName(urls: results)
            self.getFileDuration(urls: results)
            DispatchQueue.main.async {
                self.voiceMemoTableView.reloadData()
            }
        }
    }
    
    func createFileName(urls: [URL]) {
        fileNames = urls.map { url -> String in
            let urlToString = url.absoluteString
            let findIndex = urlToString.index(urlToString.endIndex, offsetBy: -33)
            let endIndex = urlToString.index(urlToString.endIndex, offsetBy: -4)
            let fileName = String(urlToString[findIndex..<endIndex])
            return fileName
        }
    }
    
    func getFileDuration(urls: [URL]) {
        
        fileDurations = urls.map { url -> String in
            var durationTime: String = ""
            
            do {
                player = try AVAudioPlayer.init(contentsOf: url)
                if let duration = player?.duration {
                     durationTime = duration.minuteSecond
                }
            } catch {
                print("<getFileDuration Error> - \(error.localizedDescription)")
            }
            return durationTime
        }
    }
    
    
    func configureTableView() {
        
        let cell = UINib(nibName: VoiceMemoTableViewCell.identifier, bundle: nil)
        voiceMemoTableView.register(cell, forCellReuseIdentifier: VoiceMemoTableViewCell.identifier)
        voiceMemoTableView.delegate = self
        voiceMemoTableView.dataSource = self
    }
}

// MARK: - Extensions

extension VoiceMemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoTableViewCell.identifier, for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }

        cell.timelineLabel.text = fileNames[indexPath.row]
        cell.durationLabel.text = fileDurations[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FireStorageManager.shared.deleteItem(fileNames[indexPath.row])
            do {
                try FileManager.default.removeItem(at: localUrls[indexPath.row])
            } catch {
                print(error)
            }
            localUrls.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension VoiceMemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playingVC = self.storyboard?.instantiateViewController(withIdentifier: PlayingViewController.identifier) as? PlayingViewController else {return}
        playingVC.fileName = fileNames[indexPath.row]
        playingVC.fileURL = localUrls[indexPath.row]
        present(playingVC, animated: true)
    }
}

