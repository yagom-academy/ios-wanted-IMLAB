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
    
    var items: [StorageReference] = []
    let storage = Storage.storage()
    
    var player: AVAudioPlayer?
        
    var flag : Int = 0

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
//        getDataFromFirebase()
    }
    
    // MARK: - IBActions
    
    @IBAction func moveToRecordDetail(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Methods
    
    func getDataFromFirebase() {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("recording/")
        
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(localURL)
        let finalURL = localURL.appendingPathComponent("recording/")
        fileRef.write(toFile: finalURL)
            do {
                player = try AVAudioPlayer(contentsOf: finalURL)
                player?.prepareToPlay()
                player?.play()
            } catch {
                print(error)
            }
        
//        fileRef.getData(maxSize: Int64(1 * 1024 * 1024)) {data, error in
//            if let error = error {
//                print(error)
//            } else {
//                print(data)
//            }
//        }
        fileRef.listAll() {result, error in
            if let error = error {
                print(error)
            }
            for item in result.items {
                print(item)
            }
        }
        
    }
    
    func configureTableView() {

        let cell = UINib(nibName: "VoiceMemoTableViewCell", bundle: nil)
        voiceMemoTableView.register(cell, forCellReuseIdentifier: "VoiceMemoTableViewCell")
        
        voiceMemoTableView.delegate = self
        voiceMemoTableView.dataSource = self
    }
}

// MARK: - Extensions

extension VoiceMemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMemoTableViewCell", for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }
        // test
        let storageRef = storage.reference()
        let fileRef = storageRef.child("recording/")
        
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(localURL)
        let finalURL = localURL.appendingPathComponent("recording/")
        fileRef.write(toFile: finalURL)
    
        if flag == 0 {
            fileRef.listAll() {result, error in
                if let error = error {
                    print(error)
                }
                for item in result.items {
                    print(item)
                    self.items.append(item)
                }
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                print(self.items)
            }
            flag = 1
        }
//        cell.timelineLabel.text = recordName[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension VoiceMemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playingVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayingViewController") as? PlayingViewController else {return}
        present(playingVC, animated: true)
    }
}

