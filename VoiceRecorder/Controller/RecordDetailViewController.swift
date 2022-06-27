//
//  RecordDetailViewController.swift
//  VoiceRecorder
//
//  Created by BH on 2022/06/27.
//

import UIKit
import AVFoundation
import FirebaseStorage

class RecordDetailViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet weak var recordWaveView: UIView!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var recordProgressBar: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    var audioFilePath = ""
    
    let storage = Storage.storage()
        
    let readyToRecordButtonImage = UIImage(systemName: "record.circle")
    let recordingButtonImage = UIImage(systemName: "record.circle.fill")
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Methods
    func setupAudioRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            recordingSession?.requestRecordPermission({ [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        self.showSettingViewController()
                    }
                }
            })
            
        } catch let error {
            // TODO: 에러 핸들링
            print(error.localizedDescription)
        }
    }
    
    func loadRecordingUI() {
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        audioFilePath = audioFilename.path
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder?.delegate = self
            audioRecorder?.record()

            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setImage(readyToRecordButtonImage, for: .normal)
        FileManager.default.fileExists(atPath: audioFilePath)
        uploadRecodeDataToFirebase()
        
    }
    
    func uploadRecodeDataToFirebase() {
        // Create a root reference
        let storageRef = storage.reference()

        // Create a reference to "mountains.jpg"
        let mountainsRef = storageRef.child(audioFilePath)

        // Create a reference to 'images/mountains.jpg'
        let mountainImagesRef = storageRef.child("/")

        // While the file names are the same, the references point to different files
        mountainsRef.name == mountainImagesRef.name            // true
        mountainsRef.fullPath == mountainImagesRef.fullPath    // false
        // File located on disk
        
        
        
        let localFile = URL(fileURLWithPath: audioFilePath)

        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("/")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          riversRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func showSettingViewController() {
        let alert = UIAlertController(title: "접근권한", message: "마이크 접근권한이 필요합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                      return
                  }
            
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }))
        
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - IBActions
    
    @IBAction func controlRecordProgressBar(_ sender: UISlider) {
    }
    
    @IBAction func controlRecordButton(_ sender: UIButton) {
        if audioRecorder == nil {
            setupAudioRecorder()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func controlBackButton(_ sender: UIButton) {
    }
    
    @IBAction func controlPlayButton(_ sender: UIButton) {
    }
    
    @IBAction func controlNextButton(_ sender: UIButton) {
    }
    
    
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioRecorderDelegate {
    
}
