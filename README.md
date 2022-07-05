## 목차
1. [프로젝트 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder/edit/main/README.md#%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%86%8C%EA%B0%9C)
2. [팀원 소개](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder/edit/main/README.md#%ED%8C%80%EC%9B%90-%EC%86%8C%EA%B0%9C)
3. [구현 화면](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder/edit/main/README.md#%EA%B5%AC%ED%98%84-%ED%99%94%EB%A9%B4)
4. [담당 파트](https://github.com/Kim-Junhwan/ios-wanted-VoiceRecorder/edit/main/README.md#%EB%8B%B4%EB%8B%B9-%ED%8C%8C%ED%8A%B8)
5. [노션링크](https://www.notion.so/dc233bcf874c4ab191fe50244a0bacad)


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

| 첫번째 화면 | 두번째 화면 | 세번째 화면 |
|:---|:---|:---|
|![Simulator Screen Shot - iPhone 8 - 2022-07-05 at 12 48 24](https://user-images.githubusercontent.com/66169740/177245984-a0c4416b-ac54-4bfe-bc4b-489e1caacdca.png)|![Simulator Screen Shot - iPhone 8 - 2022-07-05 at 12 48 55](https://user-images.githubusercontent.com/66169740/177246055-bd6b7fd5-e78e-4f00-9c9f-9757c25ae522.png)|![Simulator Screen Shot - iPhone 8 - 2022-07-05 at 12 49 21](https://user-images.githubusercontent.com/66169740/177246112-7eaa6277-ee1c-4f6a-8ed4-72a1dc27e0b6.png)|


</br></br>
# 4. 담당 파트
||첫번째 화면| 두번째 화면 |세번째 화면|
|---|---|---|---|
|monica|&nbsp;- 내비게이션 바 우상단에 + 버튼을 탭하면 녹음 화면(두 번째 화면)으로 이동합니다.</br>&nbsp;- 파일을 탭하면 파일의 재생 화면(세 번째 화면)으로 이동합니다.|&nbsp;- 진행되고 있는 녹음의 파형</br>&nbsp;- 녹음 진행 버튼 / 녹음 정지 버튼</br>&nbsp;- 녹음된 전체시간 표시</br>&nbsp;- 녹음 시 특정 주파수 영역 이하만 통과하도록 cutoff frequency를 설정</br>&nbsp;- 위의 그래프와 유사한 방식으로 파형을 나타내는 UI를 구현한다.|&nbsp;- 재생 시 현재 위치를 위 그래프에 표시합니다.|
|콩벌레|&nbsp;- Firebase프로젝트를 생성하고, FireStorage 생성</br>&nbsp;- 파일명은 “현재 위치 _ 생성된 시간을 초 단위까지” 로 표시</br>&nbsp;- 새로운 녹음이 종료되면 녹음 리스트가 업데이트</br>&nbsp;- 리스트에서 스와이프 동작을 통해 파일을 삭제할 수 있습니다.|&nbsp;- 5초 전, 5초 후의 상태로 이동하는 버튼</br>&nbsp;- View를 닫는 상황에 대한 예외 처리</br>&nbsp;- 녹음 종료 시 해당 파일을 같은 화면에서 재생</br>&nbsp;- 녹음 중, 재생 중, 정지 등 각 상태에 따라 버튼을 숨기거나 비활성화</br>&nbsp;- 녹음이 종료되면 FireStorage로 업로드|&nbsp;- 5초 전, 후로 이동하는 기능</br>&nbsp;- 볼륨 조절 슬라이드를 넣어 볼륨을 조절</br>&nbsp;- 음의 pitch값을 이용해 목소리변형 재생|












