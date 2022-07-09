## 목차
1. [프로젝트 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#1-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%86%8C%EA%B0%9C)
2. [팀원 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#2-%ED%8C%80%EC%9B%90-%EC%86%8C%EA%B0%9C)
3. [구현 화면](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#3-%EA%B5%AC%ED%98%84-%ED%99%94%EB%A9%B4)
4. [담당 파트](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#4-%EB%8B%B4%EB%8B%B9-%ED%8C%8C%ED%8A%B8)
5. [고민한 부분](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#5-%EA%B3%A0%EB%AF%BC%ED%95%9C-%EB%B6%80%EB%B6%84)
    - [여러개의 녹음파일을 디바이스가 로컬 파일로 가지고 있을지, 아니면 하나의 파일만 가지고 있을지 고민](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#%EC%97%AC%EB%9F%AC%EA%B0%9C%EC%9D%98-%EB%85%B9%EC%9D%8C%ED%8C%8C%EC%9D%BC%EC%9D%84-%EB%94%94%EB%B0%94%EC%9D%B4%EC%8A%A4%EA%B0%80-%EB%A1%9C%EC%BB%AC-%ED%8C%8C%EC%9D%BC%EB%A1%9C-%EA%B0%80%EC%A7%80%EA%B3%A0-%EC%9E%88%EC%9D%84%EC%A7%80-%EC%95%84%EB%8B%88%EB%A9%B4-%ED%95%98%EB%82%98%EC%9D%98-%ED%8C%8C%EC%9D%BC%EB%A7%8C-%EA%B0%80%EC%A7%80%EA%B3%A0-%EC%9E%88%EC%9D%84%EC%A7%80-%EA%B3%A0%EB%AF%BC)
    - [오디오 파일이 끝까지 재생되면 다시 처음으로 돌아가는 기능을 어떻게 구현할 것인가](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#%EC%98%A4%EB%94%94%EC%98%A4-%ED%8C%8C%EC%9D%BC%EC%9D%B4-%EB%81%9D%EA%B9%8C%EC%A7%80-%EC%9E%AC%EC%83%9D%EB%90%98%EB%A9%B4-%EB%8B%A4%EC%8B%9C-%EC%B2%98%EC%9D%8C%EC%9C%BC%EB%A1%9C-%EB%8F%8C%EC%95%84%EA%B0%80%EB%8A%94-%EA%B8%B0%EB%8A%A5%EC%9D%84-%EC%96%B4%EB%96%BB%EA%B2%8C-%EA%B5%AC%ED%98%84%ED%95%A0-%EA%B2%83%EC%9D%B8%EA%B0%80)
    - [파일이 완전히 다운로드 되기 이전에 녹음을 재생하는 뷰가 이전 파일을 재생하는 문제](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#%ED%8C%8C%EC%9D%BC%EC%9D%B4-%EC%99%84%EC%A0%84%ED%9E%88-%EB%8B%A4%EC%9A%B4%EB%A1%9C%EB%93%9C-%EB%90%98%EA%B8%B0-%EC%9D%B4%EC%A0%84%EC%97%90-%EB%85%B9%EC%9D%8C%EC%9D%84-%EC%9E%AC%EC%83%9D%ED%95%98%EB%8A%94-%EB%B7%B0%EA%B0%80-%EC%9D%B4%EC%A0%84-%ED%8C%8C%EC%9D%BC%EC%9D%84-%EC%9E%AC%EC%83%9D%ED%95%98%EB%8A%94-%EB%AC%B8%EC%A0%9C)
    - [파형 이미지를 어떻게 구현할지](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#%ED%8C%8C%ED%98%95-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A5%BC-%EC%96%B4%EB%96%BB%EA%B2%8C-%EA%B5%AC%ED%98%84%ED%95%A0%EC%A7%80)
    - [아이폰 실제 기기의 sample rate가 바뀌지 않는 문제](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder#%EC%95%84%EC%9D%B4%ED%8F%B0-%EC%8B%A4%EC%A0%9C-%EA%B8%B0%EA%B8%B0%EC%9D%98-sample-rate%EA%B0%80-%EB%B0%94%EB%80%8C%EC%A7%80-%EC%95%8A%EB%8A%94-%EB%AC%B8%EC%A0%9C)
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



</br></br>
# 5. 고민한 부분

# 콩벌레
## 여러개의 녹음파일을 디바이스가 로컬 파일로 가지고 있을지, 아니면 하나의 파일만 가지고 있을지 고민
```
→ 하나의 파일만으로 하기로 결정
```
- 한번에 하나의 파일만 재생,그리고 녹음이 가능했다.
- 녹음할때는 녹음만 가능하고, 재생은 불가했다.
- 한번에 하나의 재생/녹음만 가능하면 여러개의 로컬 파일을 가지고 있을 이유가 없었다. 
- Firebase Storage를 단순히 저장만 하고 끝내는 게 아닌, Firebase Storage를 최대한 이용하여 앱을 개발하는 것에 의의를 두었다.

## 오디오 파일이 끝까지 재생되면 다시 처음으로 돌아가는 기능을 어떻게 구현할 것인가
```
→ CADisplayLink를 이용해 재생버튼을 누를시 재생과 동시에 계속해서 현재 위치와 오디오파일의 재생시간을 비교하는 방식으로 구현
```
- AVAudioPlayerNode의 AVAudioPlayerNodeCompletionCallbackType을 이용하여 오디오 재생이 끝나면 playerNode를 stop을 하려고 했으나 deadLock 문제로 인해 stop하는것이 불가능했다.
- 그래서 pause인 상태에서 다시 처음으로 돌아가능 기능을 구현했으나 pause상태에서 처음으로 돌아갈 경우, sampleTime이 0부터 시작되는 게 아닌 이전의 시간에서부터 시작되는 문제가 발생했다.
![Untitled](https://user-images.githubusercontent.com/58679737/178103237-d6ada367-0a98-41a9-8f8d-3347cef0b5b1.png)
- 따라서 5초 앞으로 뒤로 기능을 구현하려고 했을때 정확한 현재의 위치를 알 수가 없어서 구현할수가 없음. 또한 음성 파형을 움직일때 정확한게 현재 재생되고 있는 위치를 표시 할 수 없앴다.
- AVAudioPlayerNodeCompletionCallbackType가 아닌 다른 방식으로 현재 재생되고있는 시간의 위치와 오디오 파일의 재생시간을 비교하는 방법과 AVAudioPlayerNode를 stop시킬수 있는 방법이 필요해서 아래와 같이 구현되도록 해야됐다.
![Untitled (1)](https://user-images.githubusercontent.com/58679737/178103622-85471a10-e6f8-4515-8124-d9c5ddb2a621.png)

## 파일이 완전히 다운로드 되기 이전에 녹음을 재생하는 뷰가 이전 파일을 재생하는 문제
```
→ 뷰가 로드되고 난 후 파일이 다운로드 되도록 변경. 다운로드 되는동안에는 재생버튼이나 이동 버튼을 터치할 수 없도록 구현
```
- 이전에는 셀을 클릭할때 녹음 파일을 다운로드 받으면서, 녹음파일재생뷰를 로딩하는 형식으로 구현했다.
- 다운로드가 끝나기전, 뷰를 로드시 이전에 존재하던 녹음파일이 재생되는 문제 발생 <img src="https://user-images.githubusercontent.com/58679737/178103433-4101670e-f127-4140-bc6a-f2384417d386.png" width="650" height="350"/>

# monica
## 파형 이미지를 어떻게 구현할지
```
→ 실제 녹음 어플과 비슷하게 구현하기 위해 파형이 그려지는 view의 width를 Infinity로 설정하여 view를 이동시키면서 그리기로 결정
```
- 과제 요구사항에 제시된 이미지대로 구현하면 긴 시간 녹음할 경우 파형이 상당히 뭉쳐서 보이게 된다.
- 실제 녹음 어플의 경우와 비슷하게 하는 편이 사용자 경험상 좋을 것이라고 판단했다.
- 구현 방법에 대해 팀원과 논의하여 결정하였다.

## 아이폰 실제 기기의 sample rate가 바뀌지 않는 문제
- 시뮬레이터 상에서는 sample rate가 잘 변하지만 실제 기기(iphone 8)에서는 변하지 않았다.
- 해당 기종이 문제인지 실제 기기인 게 문제인지 파악하기 위해 동일한 기종(iphone 8)의 실제 기기와 시뮬레이터로 테스트를 했다.
    - 시뮬레이터에서는 sample rate가 의도한 대로 잘 바뀌었으나 실제 기기에서는 48000Hz로 고정된 채 바뀌지 않았다.
- iphone 8 기기에서만 바뀌지 않는 건지 확인해보기 위해 아이패드로도 테스트했으나 결과는 동일했다.
- 관련 키워드로 구글링을 한 결과, 이어폰을 꽂으면 실제 기기에서도 sample rate가 변경된다는 내용을 발견했다.
    - 블루투스 이어폰을 연결하여 테스트를 해보았으나 앱에서 이어폰을 인식하지 못하고 내장마이크로 녹음이 이루어졌다.
    - AVAudioSession에서 Category를 설정할 때 allowBluetooth 옵션을 사용하여 블루투스 이어폰 연결 후 다시 테스트했다.
        - 이번엔 sample rate가 8000Hz로 고정된 채 바뀌지 않았다.
- 실제 기기에서 작동이 아예 안 된다고 결론을 내리기엔 당장 테스트 해볼 수 있는 기종의 수가 부족했다.
- 구글링을 해봐도 sample rate 값 변경이 안 된다는 스택오버플로우 질문글은 있지만, 실제 시뮬레이터와 기기 간에 차이가 있다는 글은 찾기 힘들었다.
- 스택오버플로우에 직접 위 문제에 대한 질문글을 올리고 답변을 받았으나 그 답변 또한 이 문제 상황에 맞는 해답이 아니어서 효과가 없었다.
- 공부를 위해 강의에 나오는 간단한 기능을 구현할 때는 문제를 맞닥뜨려도 구글링을 하면 블로그글이나 스택오버플로우글이 꽤 많이 나왔는데, 이렇게까지 자료가 없는 상황은 처음이어서 당황했다.
- 하지만 이번 경험이 있었기에 다음에 이와 비슷한 문제 상황을 만났을 때는 좀 더 능숙하게 자료조사를 해나갈 수 있을 것 같다.
- 자료조사 초반에 읽은 글을 정리해두지 않아서 불필요하게 봤던 글을 반복해서 보는 경우가 있었는데, 다음번엔 비록 나에게 도움이 되지 않은 글이라 하더라도 그 글의 내용 또한 정리해두어서 같은 글을 두 번 보는 경우가 없게끔 효율적으로 자료조사를 진행할 것이다.

</br></br>
# 6. 개발 과정
[노션링크](https://broken-redcurrant-2ce.notion.site/dc233bcf874c4ab191fe50244a0bacad)
