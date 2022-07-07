
# README 작성시 필수 요소
- 팀원 소개 (이미지, 닉네임, 담당한 기술 등)
- 프로젝트 소개
- 기타 내용은 팀 내부에서 자율적으로 작성하시면 됩니다.



## 🧑‍💻 Developers
|서초(조성빈)|Peppo(이병훈)|
|---|---|
|<img width = "200" alt= "Peppo(이병훈)" src = "https://user-images.githubusercontent.com/64088377/177667367-3c9650d1-f89a-45dc-bc65-d249deedd39b.jpg">|<img width = "200" alt= "Peppo(이병훈)" src = "https://user-images.githubusercontent.com/64088377/177667367-3c9650d1-f89a-45dc-bc65-d249deedd39b.jpg">|

<br><br>


## 👀 미리보기
|VoiceMemoList(1st page)|RecordDetail(2nd page)|Playing(3rd page)|
|---|---|---|
|<img width = "250" alt="page1-VoiceRecorder" src = "https://user-images.githubusercontent.com/64088377/177666676-397756b0-299c-419c-9592-45e611ddb1f5.gif">|<img width = "250" alt= "page2-VoiceRecorder" src = "https://user-images.githubusercontent.com/64088377/177666696-d2d25b25-1354-4899-9c1c-69b586eb7a0a.gif">|<img width = "250" alt= "page3-VoiceRecorder" src = "https://user-images.githubusercontent.com/64088377/177666695-1fa3ad69-0aa6-4c4a-accd-4a321e5aed85.gif">|



## 🔀  Git Branch

개별 브랜치 관리 및 병합의 안정성을 위해 `Git Forking WorkFlow`를 적용했습니다.

Branch를 생성하기 전 Issue를 먼저 작성하고,

`<Prefix>/#<Issue_Number>` 의 양식에 따라 브랜치 명을 작성합니다.

#### 1️⃣ prefix

- `develop` : feature 브랜치에서 구현된 기능들이 merge될 브랜치. **default 브랜치이다.**
- `feature` : 기능을 개발하는 브랜치, 이슈별/작업별로 브랜치를 생성하여 기능을 개발한다
- `main` : 개발이 완료된 산출물이 저장될 공간
- `release` : 릴리즈를 준비하는 브랜치, 릴리즈 직전 QA 기간에 사용한다
- `bug` : 버그를 수정하는 브랜치
- `hotfix` : 정말 급하게, 제출 직전에 에러가 난 경우 사용하는 브렌치

#### 2️⃣ Git forking workflow 적용

1. 팀 프로젝트 repo를 포크한다.(이하 팀 repo)
2. 포크한 개인 repo(이하 개인 repo)를 clone한다.
3. 개인 repo에서 작업하고 개인 repo의 원격저장소로 push한다.
4. pull request를 통해서 팀 repo로 merge한다.
5. pull 받아야 할 때에는 팀 repo에서 pull 받는다.

</br>

## ⚠️  Issue Naming Rule
#### 1️⃣ 기본 형식
`[<PREFIX>] <Description>` 의 양식을 준수하되, Prefix는 협업하며 맞춰가기로 한다.

#### 2️⃣ 예시
```
[Feat] 회원가입 구현
[Fix] MainActivity 버그 수정
```

#### 3️⃣ Prefix의 의미

```bash
[Feat] : 새로운 기능 구현
[Design] : just 화면. 레이아웃 조정
[Fix] : 버그, 오류 해결, 코드 수정
[Add] : Feat 이외의 부수적인 코드 추가, 라이브러리 추가, 새로운 View 생성
[Del] : 쓸모없는 코드, 주석 삭제
[Refactor] : 전면 수정이 있을 때 사용합니다
[Remove] : 파일 삭제
[Chore] : 그 이외의 잡일/ 버전 코드 수정, 패키지 구조 변경, 파일 이동, 파일이름 변경
[Docs] : README나 WIKI 등의 문서 개정
[Comment] : 필요한 주석 추가 및 변경
[Merge] : 머지
```

</br>

## 🍗  Commit Message Convention

#### 1️⃣ 기본 형식
prefix는 Issue에 있는 Prefix와 동일하게 사용한다.
```swift
[prefix] #이슈번호 - 이슈 내용
```

#### 2️⃣ 예시 : 아래와 같이 작성하도록 한다.

```swift
// 1번 이슈에서 새로운 기능(Feat)을 구현한 경우
[Feat] #1 - 기능 구현
// 1번 이슈에서 레이아웃(Design)을 구현한 경우
[Design] #1 - 레이아웃 구현
```

</br>

## 🌀  Code Covention

[StyleShare/swift-style-guide](https://github.com/StyleShare/swift-style-guide) 를 기본으로 따르고 필요에 따라 추가한다.
Footer
