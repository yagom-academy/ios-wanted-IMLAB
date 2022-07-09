# VoiceRecorder App

## 프로젝트 소개
>   녹음 / 재생 기능을 가진 앱입니다 <br/>
> - 녹음 시 dB에 따라 파형이 그려지는 것을 확인할 수 있습니다 <br/>
> - 녹음 시 cutoff freq 범위 값 변경을 통해 특정 주파수값 이상은 roll off 시킵니다 <br/>
> - 재생 시 파형과 position bar를 통해 현재 재생 위치를 확인할 수 있습니다 <br/>
> - 재생  pitch 값 변경을 통해 음성 변조 효과를 확인할 수 있습니다 <br/>

&nbsp;

## Index
- [팀원 소개](#팀원-소개)
- [담당 기술](#담당-기술)
- [기능설명](#기능-설명)
- [전체 앱 구성](#전체-앱-구성)
- [학습한 내용](#학습-내용)
- [문제해결](#문제해결)

&nbsp;

## 팀원 소개
| Hoi | Kei |
| ------ | ------ |
| <img src="https://cphoto.asiae.co.kr/listimglink/6/2013051007205672589_1.jpg" width="150px" height="150px" title="Github_Logo"></img> | <img src="https://i.pinimg.com/564x/ab/77/b6/ab77b685812966df28f059748d354ec2.jpg" width="150px" height="150px" title="Github_Logo"></img> |

## 담당 기술
| 화면 | Hoi | Kei |
|:-----:|-----|-----|
|#1|- FirebaseStorage에 올라가 있는 녹음 파일 불러오기</br>- 불러온 파일의 메타 데이터에서 저정되어있는 전체 재생시간 시간 가져오기</br>- 로딩 페이지를 생성하여 데이터를 모두 호출한 뒤에 사라지도록 구성|- TableView Layout 구성 및 Delegate를 활용한 3번째 페이지(플레이어 페이지)로 이동</br>&nbsp; - TableView 데이터 정렬 및 데이터 삭제</br>- 네비게이션 바 상단 +버튼을 통하여 두번째 화면(녹음 페이지)으로 이동|
|#2|- 진행되고 있는 녹음의 파형(데시벨값) 구현</br>- 특정 주파수 이하로 내려가도록 CutOff Frecuncy 설정하는 Slider 및 기능 생성</br> - 녹음 기능 구현 </br>- 녹음 종료시 및 예외처리 시 녹음 파일 FireBaseStorage 업로드|- 녹음 완료된 파일 재생 / 5초 전 / 5초 이후 구현 </br>- 재생시 프로그래스 바 업데이트</br>- 녹음시 버튼 에니메이션 적용 및 버튼 활성화 / 비활성화 |
|&nbsp;#3&nbsp;|- 재생파일의 파형(주파수) 구성 및 재생 시 Position bar이동 구현|- 녹음 파일 재생 / 5초 전 / 5초 이후 구현</br>- 재생시 프로그래스 업데이트 기능</br>- 음의 pitch값을 이용해 목소리변형 재생</br>- 시스템 볼륨을 조절하도록 볼륨 슬라이더 생성|


## 기능 설명
- 첫번째 화면
  - 녹음 파일목록을 구성하는 동안 로딩 화면을 표시합니다
  - 녹음 파일목록을 표시합니다 
  - 내비게이션 바 우상단에 + 버튼을 탭하면 녹음화면 (두번째 화면)으로 이동합니다
  - 파일을 탭하면 파일의 재생화면 (세번째 화면)으로 이동합니다
  - 새로운 녹음이 종료되면 녹음 리스트가 업데이트되고, 가장 최근에 녹음한 파일이 가장 상단에 위치합니다
  - 스와이프 동작을 통해 파일을 삭제할 수 있습니다
  
| 로딩 후 파일목록 표시 | 화면 이동 | 녹음 파일 삭제 및 리스트 업데이트 |
| :---------------------------: | :---------------------------: | :----------------------------: |
| <img src = "https://user-images.githubusercontent.com/95616104/178102930-6480e331-7ebd-440e-8592-bcb65db23666.gif" height="400px"> | <img src = "https://cdn.discordapp.com/attachments/990825200973119531/995339033976766514/Simulator_Screen_Recording_-_iPhone_11_Pro_-_2022-07-09_at_23.41.35.gif" height="400px"> | <img src = "https://cdn.discordapp.com/attachments/990825200973119531/995339154495914035/Simulator_Screen_Recording_-_iPhone_11_Pro_-_2022-07-09_at_23.42.14.gif" height="400px">|

  

- 두번째 화면

  - 녹음 버튼을 누르면 사용자에게 마이크 사용권한을 얻습니다
  - 녹음 시 녹음 경과 시간과 파형을 확인할 수 있습니다
  - 녹음 종료 시 해당 녹음 파일을 같은 화면에서 재생하여 들을 수 있습니다
  - 녹음 전에는 재생 관련 버튼들이 활성화되지 않고 녹음 후에 재생 관련 버튼들이 활성화됩니다
  - 녹음 파일 재생 시 5초 전/후로 이동하여 재생 가능합니다
  - 녹음이 종료되면 FireStorage로 업로드가 이루어집니다
  - 녹음 화면이 닫히더라도 해당 시점까지 녹음된 파일을 저장합니다
  
| 마이크 사용권한 요청 | 녹음 종료 후 재생 |
| --------------------------- | --------------------------- |
| <img src = "https://user-images.githubusercontent.com/95616104/178110328-2ea58dba-b48e-456c-bf7b-bf97d1f11c89.png" height="400px"> | <img src = "https://cdn.discordapp.com/attachments/990825200973119531/995341304097677442/Simulator_Screen_Recording_-_iPhone_11_Pro_-_2022-07-09_at_23.50.37.gif" height="400px"> |
 

- 세번째 화면 :

  - 재생 시 현재 위치를 확인할 수 있습니다
  - 재생 전 5초 전/후 위치를 이동하여 해당 지점부터 재생이 가능합니다
  - 재생 시에도 5초 전/후 위치를 이동하여 해당 지점부터 재생이 가능합니다
  - 볼륨 조절 슬라이드로 볼륨을 조절할 수 있습니다
  - 음의 pitch 값을 이용하여 재생 전, 재생 중 일반목소리/아기목소리/할아버지목소리로 음성 변조가 가능합니다
  
| 마이크 사용권한 요청 | 녹음 파일 재생 시 5초 전/후 이동 |
| --------------------------- | --------------------------- |
| <img src = "https://user-images.githubusercontent.com/95616104/178110328-2ea58dba-b48e-456c-bf7b-bf97d1f11c89.png" height="400px"> | <img src = "https://user-images.githubusercontent.com/95616104/178110428-953892ce-d027-455a-a8f7-1a2d7cabe77d.gif" height="400px"> |

&nbsp;

## 전체 앱 구성
### ViewController 구성
<img src = "https://user-images.githubusercontent.com/95616104/178094995-e3fe555f-e94a-400b-aafb-041f6d907562.png">

&nbsp;

### View
| class                        | 역할                                                          |
| ---------------------------- | ------------------------------------------------------------ |
| VoiceMemoListViewController  | - FireStorage에서 녹음 파일 목록을 가져와서 표시합니다<br/>- 스와이프하여 녹음파일을 삭제합니다<br/>- local 경로에 파일이 존재하지 않는 경우 FireStorage에서 다운로드합니다 |
| RecordingViewController      | - 녹음을 진행합니다 <br/>- slider로 cutoff frequency를 조절하여 특정 주파수 이상은 roll off 시킵니다<br/>- 녹음 시 dB에 따른 파형과 녹음 경과 시간을 확인합니다<br/>- 녹음 종료 후 해당 파일을 업로드합니다 <br/>- 녹음 완료된 파일을 재생합니다|
| PlayingViewController        | - 선택한 파일을 재생합니다<br/>- 파형과 progress bar를 통해 현재 재생 위치를 확인합니다<br/>-5 초 전/후로 이동하여 재생합니다<br/>- pitch값을 변경하여 음성 변조 효과를 확인합니다<br/>- slider로 볼륨을 조절합니다  |
| LoadingView                  | - 첫화면에서 FireStorage로부터 파일 다운로드 시 로딩중임을 표시합니다 |

&nbsp;

### Model
| struct                       | 역할                                                          |
| ---------------------------- | ------------------------------------------------------------ |
| RecordModel                  | - 녹음파일의 이름, 재생시간을 프로퍼티로 가지는 데이터 모델입니다 |
| RecordFileAnalysis           | - 녹음 파일의 주파수를 분석하여 파형 구성에 사용합니다 |

&nbsp;

### Utilities
| class / struct               | 역할                                                          |
| ---------------------------- | ------------------------------------------------------------ |
| FirebaseStorage              | - 녹음 파일을 업로드/다운로드/삭제하고 녹음 파일 리스트를 가져옵니다 |
| AudioRecorderHandler         | - 녹음을 위해 세션을 구성합니다<br/> - 녹음 시 파형을 그립니다<br/> - 녹음 정지 시 FireStorage에 파일을 저장합니다 |
| AudioPlayerHandler           | - pitch 값 조정 및 파일 재생을 위해 오디오 엔진을 구성합니다<br/> - 재생 시 프레임관련 위치 정보들을 업데이트 합니다<br/> - 재생 파일 분석 결과를 통해 파형을 그려줍니다
| TimeHandler                  | - 현재 시간을 문자열로 변환합니다 |
| DrawWaveform                 | - 오디오 파일을 분석하여 파형을 그립니다 |

&nbsp;

## 학습 내용

### 1. 오디오 관련 - AVFAudio framework
> 오디오 재생/녹음 및 앱의 시스템 오디오 동작을 구성합니다
- AVAudioSession : 앱의 오디오 사용 구성을 시스템에 전달하는 객체입니다
- AVAudioRecorder : 오디오 데이터를 파일에 기록하는 객체입니다
- AVAudioEngine : 오디오 신호를 생성 및 처리하고 입출력에 사용되는 오디오 노드 파이프라인을 빌드하는 객체입니다
- AVAudioNode : 오디오 생성/처리 및 I/O block을 위한 객체입니다
- AVAudioUnitTimePitch : 오디오 입력 신호의 pitch와 rate를 제어하는 객체입니다
- AVAudioUnitEQ : multiband equailizer를 구현하는 객체입니다
- AVAudioMixerNode : 여러 노드로부터 입력을 받아 mixing한 후 단일 출력으로 전달합니다

&nbsp;

> AVAudioEngine 인스턴스는 각각 하나의 inputNode, mixerNode, outputNode를 가집니다

&nbsp;

![image](https://user-images.githubusercontent.com/95616104/178098152-9d5a20e3-7005-4153-afc0-fd1a33ce9bb9.png)

&nbsp;

### 2. CADisplayLink
> App의 drawing을 디스플레이의 주사율(60Hz, 초당 60번 호출)과 동기화 할 수 있게 해주는 타이머 객체입니다
- CADisplayLink vs Timer 
  - 공통점 :<br/>
    - 설정된 selector 함수를 반복적으로 호출합니다<br/>
    - 사용 후 invalidate를 해주어야 합니다<br/>
  - 차이점 :<br/>
    - Timer는 자동으로 Run Loop에 등록이 되지만 CADisplayLink는 Run Loop에 수동으로 추가해주어야 합니다<br/>
    - Timer는 Run Loop가 UI를 그리는 등의 작업을 할 경우 호출이 늦어질 수 있으나, CADisplayLink는 iOS의 screen refresh rate(FPS)가 고정되어 있기 때문에 정확도가 높습니다.<br/>
```swift
private func setUpDisplayLink() {
    displayLink = CADisplayLink(target: self,
                                selector: #selector(updatePlayProgress))
    displayLink?.add(to: .current, forMode: .default)
    displayLink?.isPaused = true
}
```

### 3. UIBezierPath
> CustomView에서 렌더링할 수 있는 선/선분/곡선으로 구성된 경로입니다
```swift
import UIKit

class BezierPathView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        // 1. 객체 생성
        let path = UIBezierPath()
        
        // 2. 객체 속성 설정
        path.lineWidth = 10
        path.lineJoinStyle = .round
        
        // 3. 시작 지점 설정
        path.move(to: CGPoint(x: 100, y: 100))
        
        // 4. 도착 지점 설정
        path.addLine(to: CGPoint(x: 100, y: 200))
        
        // (옵션) 5. 도착 지점 close
        path.close()
        
        // (옵션) 6. 과정 3,4,5를 반복하며 subpath 추가하여 선을 그려나감
        
        // 위에서 경로를 설정해주었을 뿐 이 경로를 바탕으로 그래픽을 그려주려면 stroke() 또는 fill() 호출 필요
        // stroke() : path로 연결된 경로를 선으로 이어주는 역할
        // fill() : path로 둘러싸여진 영역을 채워주는 역할
        path.stroke()
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = BezierPathView(frame: self.view.frame)
        view.backgroundColor = .clear
        self.view.addSubview(view)
    }
}
```

&nbsp;

## 문제해결

### 상황 1. 의존성을 낮추기위하여 어떠한 방식을 사용하것이 좋을것인가?
- 원인 : 학습 시간에 SOLID 원칙에 대해 공부한 후 현재 구조에 개선이 필요하다고 생각했습니다
- 해결 방법 : protocol을 활용하여 객체를 추상화 한 후, 다른 객체에 의존하지 않도록 단일 책임 원칙을 적용하는 방식으로 접근해보았습니다.
```swift
protocol FirebaseStoreDownload {
    func downloadFromFirebase(fileName:String, handler: @escaping (Result<String , Error>) -> ())
}

class DownloadRecordfile : FirebaseStoreDownload {
    func downloadFromFirebase(fileName: String, handler: @escaping (Result<String, Error>) -> ()) {
        let storageRef = Storage.storage().reference()
        let islandRef = storageRef.child("voiceRecords").child(fileName)

        let fileMnager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = fileMnager.appendingPathComponent(fileName)

        let downloadTask = islandRef.write(toFile: fileUrl) { url, error in
            if let error = error {
                print("Error - Download Fail (error)")
                return
            }
            if let url = url {
                handler(.success(url.lastPathComponent))
            }
        }

        downloadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Error - Download Fail (error)")
                return
            }
        }
    }
}

```
  
### 상황 2. Cutoff frecuncy와 pitch 기능을 구현하기 위해서는 어떠한 방식을 사용해야하는가?
- 원인 : AVAudioRecorder/Player로 구성된 상황에서 cutoff frequency 기능을 구현하기 위해 AVAudioEngine을 사용해야 했습니다
- 해결 방법 : 연결 방식이 중요하다는 사실을 확인하고 아래와 같이 구성하였습니다
```swift
private func setUpDisplayLink() {
    displayLink = CADisplayLink(target: self,
                                selector: #selector(updatePlayProgress))
    displayLink?.add(to: .current, forMode: .default)
    displayLink?.isPaused = true
}
```
### 상황 3. AVAudioPlayerNode가 정지시 값의 변화가 정확하지 않은데 어떻게 처리해야 했는가?
- 원인 : AVAudioPlayerNode의 경우 정지 시 AudioPlayerNode의 lastRenderTime이 nil이 되어 현재 frame 위치값을 0으로 return하는 것이 문제였습니다
- 해결 방법 : CADisplayLink를 활용하여 currentFramePosition 값에 영향을 받지 않고 frame을 계산할 수 있었습니다 
```swift
private func setupEngine() {
    audioEngine = AVAudioEngine()

    setEqulizer()
    setMixerNode()

    makeConnection()
    audioEngine.prepare()
}

private func setMixerNode() {
    mixerNode = AVAudioMixerNode()
    mixerNode.volume = 0
    audioEngine.attach(mixerNode)
}

private func setEqulizer() {
    equalizer = AVAudioUnitEQ(numberOfBands: 1)

    equalizer.bands[0].filterType = .lowPass
    equalizer.bands[0].frequency = 5000
    equalizer.bands[0].bypass = false

    audioEngine.attach(equalizer)
}

private func makeConnection() {
    let inputNode = audioEngine.inputNode
    let inputformat = inputNode.outputFormat(forBus: 0)
    audioEngine.connect(inputNode, to: equalizer, format: inputformat)
    audioEngine.connect(equalizer, to: mixerNode, format: inputformat)

    let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputformat.sampleRate, channels: 1, interleaved: false)

    audioEngine.connect(mixerNode, to: audioEngine.mainMixerNode, format: mixerFormat)
}

```

