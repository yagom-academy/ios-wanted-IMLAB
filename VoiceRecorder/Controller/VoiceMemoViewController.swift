//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit
import FirebaseStorage
import AVFAudio

class VoiceMemoViewController: UIViewController {
    
    private enum RefString {
        static let recording: String = "recording/"
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var voiceMemoTableView: UITableView!
    
    // MARK: - Properties
    
    var items: [StorageReference] = []
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        items = FireStorageManager.shared.getDataFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if items.isEmpty == false {
            DispatchQueue.main.async {
                self.voiceMemoTableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func moveToRecordDetail(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Methods
    
//    func getDataFromFirebase() {
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let fileRef = storageRef.child(RefString.recording)
//
//        fileRef.listAll() { (result, error) in
//            if let error = error {
//                print(error)
//            }
//            for item in result.items {
//                self.items.append(item)
//            }
//            self.voiceMemoTableView.reloadData()
//        }
//    }

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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoiceMemoTableViewCell.identifier, for: indexPath) as? VoiceMemoTableViewCell else { return UITableViewCell() }
        cell.timelineLabel.text = items[indexPath.row].name
        cell.durationLabel.text = "02:11"
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
        guard let playingVC = self.storyboard?.instantiateViewController(withIdentifier: PlayingViewController.identifier) as? PlayingViewController else {return}
        present(playingVC, animated: true)
    }
}

