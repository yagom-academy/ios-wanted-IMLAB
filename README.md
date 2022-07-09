
# README 작성시 필수 요소
- 팀원 소개 (이미지, 닉네임, 담당한 기술 등)
- 프로젝트 소개
- 기타 내용은 팀 내부에서 자율적으로 작성하시면 됩니다.

## iOS-VoiceRecorder
Firebase Storage를 활용해 녹음 파일을 관리할 수 있는 녹음기 앱


# 팀원
|<img src="https://user-images.githubusercontent.com/75964073/178100225-48512f56-fe93-47f3-88e5-c1cb29110f66.png" width="150">|<img src="https://user-images.githubusercontent.com/75964073/178100336-b5893584-2dc3-4df5-a493-bb38c4f5cf2b.png" width="150">|<img src="https://user-images.githubusercontent.com/75964073/178100281-e807328d-df64-4024-9bf4-886a35609e4c.png" width="150">|
|:--:|:--:|:--:|
|**날라**|**국**|**승찬**|
|[@jazz-ing](https://github.com/jazz-ing)|[@oguuk](https://github.com/oguuk)|[@seungchan2](https://github.com/seungchan2)|

</br>

# Convention

`Coding Convention` · `Commit Convention`

<details markdown="1">
<summary>[Coding Convention]</summary>


## 📍 함수 네이밍

**`뷰 전환`**

pop, push, present, dismiss
동사 + To + 목적지 뷰 (다음에 보일 뷰)
( dismiss는 dismiss + 현재 뷰 )

**`초기세팅`**
- init + 목적어
ex) initPickerView

**`hidden unhidden`**
- show + 목적어
- hide + 목적어

**`뷰 UI 관련`**
- 동사원형 + 목적어

**`애니메이션`**
- 동사원형 + 목적어 + WithAnimation
- showButtonsWithAnimation

**`권한 위임`**
- setDelegation()
- assignDelegation()

**`subview로 붙이기`**
- attatch

**`프로토콜`**
- 뷰 이름 + View + Protocol

---

## 📍 파일명 네이밍

**@IBOutlet Properties - 프로퍼티 종류 뒤에 다 쓰기 (줄임말 X)**

ex) emailTextField(O) emailTF(X)  
      loginButton(O)

**뷰 컨트롤러 파일 만들 때 뒤에 ViewController 다 쓰기 (VC (X))**

파일명 첫 글자는 대문자  
Enum 등은 첫 글자 대문자  
변수 첫 글자는 소문자

</details>

<details markdown="3">
<summary>[Commit Convention]</summary>
  </br>

```
✅ [커밋 타입] 내용 (#이슈번호) 형식으로 작성
✅ ex. [Feat] 파형 기능 구현
✅ 제목(title)을 아랫줄에 작성
```
</details>
 
<details markdown="3">
<summary>[Commit Type]</summary>
  </br>
  > 🚨 총 5개의 커밋 타입으로 구분한다.
  
```  
[Add]    기능이 아닌 것 생성 및 추가 작업(파일·익스텐션·프로토콜 등)
[Feat]   새로운 기능 추가 작업
[Style]  UI 관련 작업(UI 컴포넌트, Xib 파일, 컬러·폰트 작업 등)
[Fix]    에러 및 버그 수정, 기능에 대한 수정 작업
[Set]    세팅 관련 작업
```  
 

</details>

<br />

# Branch Strategy

`Git Flow` · `GitHub Flow`

<details markdown="1">
<summary>브랜치 종류 소개</summary>

`origin/main` - default 

`feature`
- feature/#이슈번호
- feature/#1

</details>

<details markdown="1">
<summary>시나리오</summary>

> 1️⃣ **Issue**
> 1. 이슈생성

> 2️⃣ **Branch**
> - ex. feature/#3

> 3️⃣ **Pull request**
> 1. reviewer → 2명

> 4️⃣ **Code Review**
> 1. 수정 요청
> 2. 대상자(작업자)가 수정을 하고 다시 커밋을 날림

> 5️⃣ **merge**
> 1. 팀원 호출
> 2. 간단한 리뷰, 피드백, 회의 마친 후
> 3. 다 같이 보는 자리에서 합칠 수 있도록 하기

</details>


## Descripton
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-lightgrey) 
![Xcode 13.3](https://img.shields.io/badge/Xcode-13.3-blue)
![Firebase](https://img.shields.io/badge/Firebase-9.3.0-orange)

## Data Flow
![Frame 5104](https://user-images.githubusercontent.com/80672561/178103116-6509c074-360e-4776-8c83-8d0d5a8bc6db.png)

# Trouble Shooting

## 구조 설계
- 팀원들과 여려 차례 회의를 나눈 결과, 개발할 때 구조 설계가 가장 중요하다고 생각을 하였고 가장 많은 시간을 투자하였다. </br>
- 처음에는 `MVC Pattern`으로 설계를 하였으나, `MVC Pattern`의 단점인 MassiveViewController를 해결하고자 `MVVM + Clean Architecture`를 도입하였다. </br>
- 2주라는 시간동안 공부를 하며 완벽한 `MVVM + Clean Architecture`를 구현해내지는 못했으나 모바일 개발에서 `Clean Architecture`의 핵심은 `계층 나누기` `의존성 분리`에 핵심이 있다는 것을 배울 수 있었다. </br>


## async await
- `FirebaseStorage`에 녹음 파일을 올리거나, fetch 해올 때나 다양한 상황에서 비동기 처리에 많은 리소스를 투자해야했다.
- 또한 반복되는 콜백의 뎁스가 깊어지는 단점을 처리하기 위해 팀원들과 함께 [WWDC 2021 async await](https://developer.apple.com/videos/play/wwdc2021/10132/)를 보며 학습하여`async await`을 도입하였다.
- 비동기 코드를 동기 코드처럼 작성할 수 있다는 장점이 있었지만, 새롭게 학습하고 적용하다보니 어려움도 있었다.
- 하지만 팀원들 모두 새로운 기술을 습득하는 데에 두려워하지 않고, 습득한 내용을 프로젝트에 적용하였다.


## Package.resolved
![image](https://user-images.githubusercontent.com/80672561/178109524-329faa92-b3bb-41f9-aa4f-3b5da71f0883.png)

- `Cocoapods`을 사용하지 않고, `SPM`을 사용하면서 발생하였다.
- 이슈 발생 원인은 팀원 중 한 명의 Schema Version이 지원하지 않아서 발생한 문제이다.
- 해결 방법
  - Xcodeproj의 패키지 안에 xcworkspace의 패키지를 들어간다.
  - xcsharedata 폴더에 들어간다. 
  - 폴더 안에 swiftpm 폴더의 package.resolved를 삭제한다.
  - 그 후, Xcode에서 File -> Packages -> Reset Package Caches에 들어간다.
  - Xcode에서 해당 라이브러리를 SPM으로 다시 다운로드하여 이슈를 해결하였다.  


# ScreenShot
