
# 🍏 원티드 iOS 프리온보딩 - VoiceRecorder App

원티드 iOS 프리온보딩 코스를 진행하며 구현한 음성메모 앱 입니다.

- 기간 `2022.06.27 ~ 2022.07.09`

## 👨🏻‍💻 팀원

|커킴|라비|꽁치대디|
|---|---|---|
|<a href="https://github.com/kirkim"><img src="https://avatars.githubusercontent.com/u/72755750?v=4" width="120px"/></a>|<a href="https://github.com/zoa0945"><img src="https://avatars.githubusercontent.com/u/51810980?v=4" width="120px"/></a>|<a href="https://github.com/trumanfromkorea"><img src="https://avatars.githubusercontent.com/u/55919701?v=4" width="120px"/></a>|
|네트워크, 모델관리|음성녹음, Waveform|파일재생, 음성변조|

## 📱 실행 화면 & 역할
![2022-07-09_16 08 02](https://user-images.githubusercontent.com/55919701/178095804-ba8f1980-6e9f-4d49-a2cf-3a4d3d799b53.png)

### 재생화면
- (라비) 음원 Waveform 출력 구현
- (꽁치대디) 음원 재생, 일시정지 구현
- (꽁치대디) 목소리 변조, 음량 조절 구현
- (꽁치대디) 5초 앞뒤로 건너뛰기, Waveform 조절 구현

### 음원 리스트 화면
- (커킴) 네트워크 모델 구현
- (커킴) Firebase Storage 데이터 요청 구현
- (커킴) TableView 음원 데이터 출력 구현
- (커킴) TableView 정렬, 즐겨찾기, 데이터 삭제 구현
- (커킴) 셀 이동, 기본순에 순서 기억

### 음성 녹음 화면
- (라비) 음성 녹음 구현
- (라비) 실시간 녹음상황에 맞춘 Waveform 출력 구현
- (라비) 음성 입력 주파수 제한 구현
- (꽁치대디) 녹음된 음성 재생, 일시정지, 건너뛰기 구현
- (커킴) Firebase Storage 음원 업로드 구현 

## 📝 목표 & 배운점
### MVVM 패턴 적용
- 효율적인 코드를 작성하기 위해 MVVM 패턴을 적용했습니다.
- MVVM 패턴을 학습할 수 있는 계기가 되었습니다. 
- Model 은 싱글톤으로 구현하여 재사용할 수 있도록 구현했습니다.

### 협업을 위한 Git 활용
- 변형된 Git Flow 모델을 이용하여 Feature 브랜치에서 각각 작업을 진행했습니다.
- 적극적으로 Git 을 활용하여 이에 익숙해지고자 했습니다.
- Git 사용간에 생기는 여러 문제들을 해결하며 Git 에 대해 학습했습니다. (rebase, revert 등...)

### 기능별 업무 분담
- 기능을 크게 3가지로 나누어 역할을 분담했습니다. (녹음, 재생, 네트워크)
- 역할별로 다른 기능을 구현했지만, 서로에게 영향을 끼치는 부분이 있어 팀원간의 의사소통이 굉장히 중요하다는 것을 깨달았습니다.