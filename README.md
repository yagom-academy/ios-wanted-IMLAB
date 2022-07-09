## 목차
1. [프로젝트 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#1-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%86%8C%EA%B0%9C)
2. [팀원 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#2-%ED%8C%80%EC%9B%90-%EC%86%8C%EA%B0%9C)
3. [구현 화면](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#3-%EA%B5%AC%ED%98%84-%ED%99%94%EB%A9%B4)
4. [담당 파트](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#4-%EB%8B%B4%EB%8B%B9-%ED%8C%8C%ED%8A%B8)
5. [고민한 부분](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#5-%EA%B3%A0%EB%AF%BC%ED%95%9C-%EB%B6%80%EB%B6%84)
6. [개발 과정](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#6-%EA%B0%9C%EB%B0%9C-%EA%B3%BC%EC%A0%95)



</br></br>
# 1. 프로젝트 소개
- 녹음파일을 다루는 앱입니다.
    - 녹음 및 재생, 목소리 필터, 녹음 주파수 조절 기능 지원
- 아이폰, 세로 모드만 지원하는 앱입니다.
- `Firebase-FireStorage` 를 활용해 서버에 저장합니다.

</br></br>
# 2. 팀원 소개

| monica | 콩벌레 |
|:---:|:---:|
|![스크린샷 2022-07-05 오후 12 39 28](https://user-images.githubusercontent.com/66169740/177245353-2c07bcd1-ffee-4d2d-923b-f1867aba606d.png)|![스크린샷 2022-07-05 오후 12 39 49](https://user-images.githubusercontent.com/66169740/177245382-ce7471c7-0401-4eb9-97de-1b59bef22d7f.png)|


</br></br>
# 3. 구현 화면

| 첫번째 화면 - 녹음 List View| 두번째 화면 - 녹음 및 확인 뷰 | 세번째 화면 - 재생 뷰 |
|:---:|:---:|:---:|
|![화면_기록_2022-07-09_오후_3_29_25_AdobeExpress](https://user-images.githubusercontent.com/66169740/178095558-90b06648-8589-4dfb-81c5-30dd7df14c61.gif)|![화면_기록_2022-07-09_오후_3_29_25_AdobeExpress (4)](https://user-images.githubusercontent.com/66169740/178095665-01baadd9-7a9d-4675-854b-dce30baf8b0f.gif)|![화면_기록_2022-07-09_오후_3_29_25_AdobeExpress (3)](https://user-images.githubusercontent.com/66169740/178095703-35212a18-6d47-4806-874e-1275ce6d3dd7.gif)|


</br></br>
# 4. 담당 파트
## 첫번째 화면 - 녹음 List View
### monica
- 내비게이션 바 우상단에 + 버튼을 탭하면 녹음 화면(두 번째 화면)으로 이동
- 파일을 탭하면 파일의 재생 화면(세 번째 화면)으로 이동
- 화면을 아래로 드래그해서 새로고침을 하면 녹음 리스트 업데이트
### 콩벌레
- Firebase프로젝트를 생성하고, FireStorage 생성
- 파일명은 “현재 위치 _ 생성된 시간을 초 단위까지” 로 표시
- 새로운 녹음이 종료되면 녹음 리스트가 업데이트
- 리스트에서 스와이프 동작을 통해 파일을 삭제
## 두번째 화면 - 녹음 및 확인 뷰
### monica
- `UIBezierPath`를 이용하여 진행되고 있는 녹음의 파형을 나타내는 UI 구현
- `AVAudioRecorder`를 이용하여 녹음 진행/정지 기능 구현
- 녹음된 전체시간 표시
- `AVAudioSession`의 `sampleRate`를 이용하여 녹음 시 특정 주파수 영역 이하만 통과하도록 cutoff frequency를 설정
### 콩벌레
- 재생시 5초 전, 5초 후의 상태로 이동
- View를 닫는 상황에 대한 예외 처리
- `AVAudioPlayerNode`를 이용하여 녹음 종료 시 해당 파일을 같은 화면에서 재생
- 녹음 중, 재생 중, 정지 등 각 상태에 따라 버튼을 숨기거나 비활성화
- 녹음이 종료되면 `FireStorage`로 업로드
## 세번째 화면 - 재생 뷰
### monica
- 재생되는 음원의 파형을 나타내는 UI 구현
- 재생 시 현재 위치를 그래프에 표시
- 현재 재생시간 표시
### 콩벌레
- `CADisplayLink`를 이용하여 5초 전, 후로 이동하는 기능 구현
- 볼륨 조절 슬라이드를 넣어 볼륨을 조절
- `AVAudioEngine`을 이용해 음악 재생
- `AudioEngine`의 `AVAudioUnitTimePitch`를 이용하여 음의 pitch값을 이용해 목소리변형 재생

# 5. 고민한 부분
### 여러개의 녹음파일을 디바이스가 로컬 파일로 가지고 있을지, 아니면 하나의 파일만 가지고 있을지
```
→ 하나의 파일만으로 하기로 결정
```
- 한번에 하나의 파일만 재생,그리고 녹음 가능
- 녹음할때는 녹음만 가능함, 재생 불가
- 한번에 하나의 재생/녹음만 가능하면 여러개의 로컬 파일을 가지고 있을 이유가 없음. 
- Firebase Storage를 단순히 저장만하고 끝내는게 아닌, Firebase Storage를 최대한 이용하여 앱을 개발하는것에 의의를 둠

### 파형 이미지를 어떻게 구현할지
```
→ 실제 녹음 어플과 비슷하게 구현하기 위해 파형이 그려지는 view의 width를 Infinity로 설정하여 view를 이동시키면서 그리기로 결정
```
- 과제 요구사항에 제시된 이미지대로 구현하면 긴 시간 녹음할 경우 파형이 상당히 뭉쳐서 보이게 됨
- 실제 녹음 어플의 경우와 비슷하게 하는 편이 사용자 경험상 좋을 것이라고 판단
- 구현 방법에 대해 팀원과 논의하여 결정

# 6. 개발 과정
[노션링크](https://broken-redcurrant-2ce.notion.site/dc233bcf874c4ab191fe50244a0bacad)
