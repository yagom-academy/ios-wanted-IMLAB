//
//  PlayingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/07/02.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayingViewController: UIViewController {
    
    @IBOutlet weak var positionBar: UIView!
    @IBOutlet weak var volumeSliderView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    //    @IBOutlet weak var waveScrollView: UIScrollView!
//    @IBOutlet weak var drawWaveForm: DrawWaveform!
    
    private var progressTimer: Timer?
    private var inPlayMode: Bool = false
    var selectedFileInfo: RecordModel?
    var startPoint = CGPoint(x: 0.0, y: 0.0)
    var firstindex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let fileInfo = selectedFileInfo else { return }
        self.fileNameLabel.text = fileInfo.recordFileName
        self.totalPlayTimeLabel.text = fileInfo.recordTime
        self.currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = 0.0
        audioPlayerHandler.selectPlayFile(self.fileNameLabel.text)
        configureVolumeSlider()
        
        positionBar.center.x -= waveFormView.bounds.width
//        let layout = waveCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.scrollDirection = .horizontal
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayerHandler.stop()
    }
    
    private let audioPlayerHandler = AudioPlayerHandler(
        localFileHandler: LocalFileHandler(),
        timeHandler: TimeHandler()
    )
    
    private func configureVolumeSlider() {
        let volumeView = MPVolumeView(frame: volumeSliderView.bounds)
        volumeSliderView.addSubview(volumeView)
    }
    
    private func setButton(enable: Bool) {
        goBackwardButton.isEnabled = enable
        goForwardButton.isEnabled = enable
    }
    
    @IBAction func changePitch(_ sender: UISegmentedControl) {
        switch soundPitchControl.selectedSegmentIndex {
        case 0:
            audioPlayerHandler.changePitch(to: 0)
        case 1:
            audioPlayerHandler.changePitch(to: 800)
        case 2:
            audioPlayerHandler.changePitch(to: -900)
        default:
            break
        }
    }
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.seek(to: -5.0)
        playProgressBar.progress = audioPlayerHandler.progress
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.seek(to: 5.0)
        playProgressBar.progress = audioPlayerHandler.progress
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        inPlayMode.toggle()
        audioPlayerHandler.playOrPause()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                             target: self,
                                             selector: #selector(updateProgress),
                                             userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
        firstindex += 1
//        waveCollectionView.scrollToItem(at: NSIndexPath(item: firstindex, section: 0) as IndexPath, at: .right, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.positionBar.center.x += self.waveFormView.bounds.width
        }, completion: nil)
        if !audioPlayerHandler.isPlaying {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
}

//extension PlayingViewController : UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return readFile.points.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "waveCollectionViewCell", for: indexPath) as! waveCollectionViewCell
//        let contentview = cell.contentView
//        let view = UIView(frame: CGRect(x: contentview.frame.midX, y: contentview.frame.midY, width: 5, height: readFile.points[indexPath.row] * 10))
//        let view2 = UIView(frame: CGRect(x: contentview.frame.midX, y: contentview.frame.midY - CGFloat(readFile.points[indexPath.row] * 10), width: 5, height: readFile.points[indexPath.row] * 10))
//        view.backgroundColor = .red
//        view2.backgroundColor = .red
//        contentview.addSubview(view)
//        contentview.addSubview(view2)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//            return CGSize(width: 5, height: 100)
//
//        }
//
//}
