# 목차
  1. [Team](#Team)
     1. [팀원 소개](#팀원-소개)
     2. [기여한 부분](#기여한-부분)
  2. [프로젝트 소개](#프로젝트-소개)
     1. [목표](#목표)
     2. [사용한 기술](#사용한-기술)
     3. [기능 소개](#기능-소개)
        - [App Flow](#App-Flow)
        - [Demo gif](#Demo-gif)
     4. [사용한 Pattern 소개](#사용한-Pattern-소개)
        - [Coordinator Pattern](#Coordinator-Pattern)
        - [Observer Pattern](#Observer-Pattern)
     5. 객체 역할 소개
        - [View 관련](#View-관련)
        - [Manger 관련](#Manger-관련)
     6. [Project UML](#Project-UML)
  3. [고민한 부분](#고민한-부분)
  4. [회고](회고)
  
---

# Team
## 팀원 소개 

| Downey                       | JMin                             |                            Oyat|
| ---------------------------- | -------------------------------- |----------------------------|
| [<img src="https://github.com/dahun-lee-daji.png" width="200">](https://github.com/dahun-lee-daji)| [<img src="https://github.com/jmindeveloper.png" width="200">](https://github.com/jmindeveloper)|[<img src="https://github.com/iclxxud.png" width="200">](https://github.com/iclxxud)|
|개발 및 팀 리딩, 기술 소개 | 개발 및 앱 Bug 탐색 | 개발 및 스터디 내용 자료 제작 |


## 기여한 부분

| 팀원 | 기여한 내용|
| ---------------------------- | -------------------------------- |
| Downey| 내용|
| JMin| 내용|
| Oyat| 내용|

# 프로젝트 소개
## 목표
> 요구사항에 적합한 녹음 앱 개발
> 외부 라이브러리 : __FirebaseStorage Only!__
## 사용한 기술
`Coordinator Pattern` `Observer Pattern` `Delegate Pattern`
`Code-based UI` `MVC` `Dependency inversion`
  
## 기능 소개

### App Flow
  - all Flow
  <p float="none">
  <img src= "./images/AppFlow001.jpg" width="500" />
  </p>

  - ListView Flow
  <p float="left">
  <img src= "./images/AppFlow002.jpeg" width="500"/>
  </p>

  - RecordView Flow
  <p float="right">
  <img src= "./images/AppFlow004.jpeg" width="500"/>  
  </p>

  - PlayView Flow
    <p float="left">
  <img src= "./images/AppFlow003.jpg" width="500"/>
</p>
  
### Demo Gif
  - 첫 화면
  
   <p float="left">
  <img src= "./images/gif/home.gif" width="300"/>
</p>

  - RecordView, 레코드 기능
  
   <p float="left">
  <img src= "./images/gif/record.gif" width="300"/>
</p>

  - RecordView, 재생 기능
  
   <p float="left">
  <img src= "./images/gif/record_play.gif" width="300"/>
</p>

  - PlayView, 재생기능
  
   <p float="left">
  <img src= "./images/gif/play.gif" width="300"/>
</p>

## 사용한 Pattern 소개
### Coordinator Pattern

<p float="none">
  <img src= "./images/CoordinatorPattern.png" width="1000" />
  </p>

### 1. 코디네이터 패턴을 사용한 이유
> MVC에 Coordinator패턴을 적용함으로 Massive VC를 덜어내기 위해 사용하였습니다.

### 2. 어떤 장점이 존재할까?
> Coordinator가 화면 전환 역할을 해주는 객체가 되어 좀 더 VC를 가볍게 만들 수 있습니다. 화면 전환에 대한 코드가 모여 있어 파악, 관리하기가 용이하고 게다가 책임과 구분(역할)에 따라 여러 개의 Coordinator를 사용할 수 있어 객체지향적으로 구현하기 더 수훨합니다.

### Observer Pattern

<p float="none">
  <img src= "./images/ObserverPattern.png" width="1000" />
  </p>

### 1. 옵저버 패턴을 사용한 이유
> 옵저버 패턴을 활용하면 변경사항이 생겨도 무난히 처리할 수 있는 유연한 객체 지향 시스템을 구축할 수 있기 때문입니다. 이는 객체 사이의 상호 의존성을 최소화할 수 있기 때문입니다.(느슨하게 결합되어 있기 때문)

### 2. 어떤 장점이 존재할까?
> - Delegate Design Pattern 은 1:1 관계에서 사용하는 반면, Observer & Notification Pattern 은 1:다 관계 성립 가능
( ex. 저희의 경우 레코드뷰, 플레이뷰 2곳에 옵저버를 생성해 AudioPlayable 객체에 1개의 Notification 을 기다릴 수 있게 하였습니다)
> - 실시간으로 한 객체의 변경사항을 다른 객체에 전파할 수 있습니다.
> - 느슨한 결합(Loose Coupling)으로 시스템이 유연하고 객체간의 의존성을 제거할 수 있습니다
> - Open / Close 원칙(개방 폐쇄 원칙)을 지킬 수 있습니다. (개방 폐쇄 원칙: 확장에는 열려있고, 변경에는 닫혀있어야 한다.)


## 객체 역할 소개

### View 관련

| class / struct               | 역할                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| `SceneDelegate`         | - 앱의 초기 권한 요청, Coordinator 및 비즈니스 로직 객체를 생성함.  |
| `AppCoordinator`      | - 앱의 화면 전환을 담당하는 객체. SceneDelegate로 부터 전달받은 객체를 각 ViewController의 필요에 맞게 전달한다.   |
| `VoiceMemoListView`           | - FirebaseStorageManager를 이용하여 사용자의 녹음 파일 목록을 가져온다.<br />- 파일명에 따른 metaData를 얻어와 View에 표기한다. <br />- 셀을 슬라이드하여, 로컬과 FirebaseStorage내의 녹음 파일을 삭제 할 수 있다. |
| `VoiceMemoRecordView`             | - 녹음을 할 수 있다.<br />- 녹음 시 특정 주파수 이하만 통과 할 수 있도록 한다.<br />- 녹음 시 볼륨 파형을 볼 수 있다. <br />- 녹음을 재생 할 수 있으며, 재생 위치를 5초 전후로 이동 할 수 있다.<br />- 녹음 완료 시, 녹음 파일을 FirebaseStorage에 업로드한다. |
| `VoiceMemoPlayView` | - 녹음을 재생 할 수 있으며, 재생 위치를 5초 전후로 이동 할 수 있다.<br />- 녹음의 pitch를 바꿔 목소리를 변조 할 수 있다. <br />- 재생 위치를 View의 색 변화를 통해 알 수 있다. <br />- 녹음 파일의 볼륨 파형을 볼 수 있다.<br />- 슬라이더를 사용하여 볼륨을 조절 할 수 있다. |
| `WaveFormView`       | - 전달받은 볼륨 파형 Data를 사용하여 User가 볼륨 파형을 쉽게 알 수 있도록 한다. |

### Manger 관련

| class / struct               | 역할                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| `FirebaseStorageManager`         | - FirebaseStorage와 Networking 하는 객체.<br />- 파일 목록 가져오기, 파일의 metaData가져오기, 파일의 다운, 업로드, 삭제 기능    |
| `PathFinder`      | - Class FileManager를 감싼 객체.<br />- 앱에서 필요한 Local File System에 접근하는 기능을 제공. <br />- 현재 시간을 파일 경로로 제공하는 기능 제공  |
| `AudioManager`           | - Protocol AudioRecordable과 AudioPlayable 채택시, 상속해야 하는 Class. <br />-두 Procotol의 구현 class에 필요한 공통 Property, Method를 제공한다.  |
| `AudioRecodable`             | - 녹음 기능을 제공하는 Recorder의 기능을 명시하는 Protocol |
| `DefalutAudioRecoder`             | - AudioRecodable을 채택한 Recoder기능을 View에 제공하는 Class |
| `AudioPlayable`             | - 녹음 파일을 재생하는 Player의 기능을 명시하는 Protocol  |
| `DefalutAudioPlayer` | - AudioPlayable을 채택한 Player기능을 View에 제공하는 Class |



## Project UML
<p float="left">
  <img src= "./images/uml.png" width="1000" />
</p>
# 고민한 부분

## Downey
## Oyat
## JMin

# 회고

## Downey
## Oyat
## JMin
