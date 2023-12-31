
# 팀원 소개
||콩벌레|JMin|Kei|
|----|----|----|----|
|팀원|<img src = "https://avatars.githubusercontent.com/u/58679737?v=4" height="150px">| <img src = "https://avatars.githubusercontent.com/u/87932687?v=4" height="150px">| <img src = "https://i.pinimg.com/564x/ab/77/b6/ab77b685812966df28f059748d354ec2.jpg" height="150px">|
|담당기술|- 한글 오토마타 구현<br/>- 공백/삭제/shift키 기능 구현<br/>- Code refactoring|- API 통신 기능 구현<br/>- Keyboard extension 구현<br/>- Code refactoring|- Keyboard layout 구현<br/>- XCTest 작성<br/>- Code refactoring|

&nbsp;

# 프로젝트 소개
- 서버 API를 이용하여 리뷰 목록을 가져오고, 새로운 리뷰를 작성할 수 있습니다
- 한글 오토마타 알고리즘을 활용하여 custom keyboard를 구현하였습니다
- Keyboard extension을 이용하여 custom keyboard를 safari나 iMessage 등에서 사용할 수 있습니다


&nbsp;

# 구현화면
- 첫번째 화면
  - 서버 API에서 상품 리뷰 목록을 가져온 후 화면에 표시합니다
  - 댓글 작성 시간에 따라 1시간 이내: 분 단위 / 하루 이내 : 시간 단위 / 하루 이상 : 년월일을 표시합니다
  - 사용자가 리뷰를 작성한 후 작성 버튼을 누르면 서버 API로 POST 요청을 보내서 서버에 추가합니다
  - 리뷰 목록에 위에서 작성한 리뷰를 최상단에 표시합니다
  
  |목록에 서버 데이터 표시|새로 작성한 리뷰 목록에 업데이트|
  |:----:|:----:|
  |<img src ="https://user-images.githubusercontent.com/87932687/179905296-ff8d6479-072b-4215-b2df-143f00c8cbf7.gif" height="400px">|<img src = "https://user-images.githubusercontent.com/87932687/179905666-6b847a1e-7abf-40ec-9ec3-84da93356f8a.gif" height="400px">|
  
- 두번째 화면
  - 화면 하단에 배치된 키 버튼을 누르면 상단에 한글이 조립되어 표시됩니다
  - Shift 버튼을 눌러 쌍자음, 복합모음을 입력할 수 있습니다
  - Back 버튼을 눌러 조합중인 글자 중 한 음소만 지울 수 있습니다
  - Space 버튼을 눌러 공백을 추가할 수 있습니다 
  
  |한글조합/Shift/Back/Space 버튼 기능 구현|
  |:----:|
  |<img src = "https://user-images.githubusercontent.com/87932687/179907319-783d373d-a8ba-4233-af43-9f72702b7080.gif" height="400px">|
  
- 추가 기능
  - Keyboard extension을 활용하여 custom keyboard를 Safari, iMessage 앱에서 사용할 수 있습니다

  |Custom Keyboard 사용하기|
  |:----:|
  |<img src = "https://user-images.githubusercontent.com/87932687/179905136-7becb0a3-ec36-41d9-ae15-9e00aeb9c480.gif" height="400px">|
  
&nbsp;
  
# 키보드 이벤트 전달 과정
<img src = "https://user-images.githubusercontent.com/87932687/180590988-560930db-f645-4ac4-bcc7-5cd478372035.jpg">

## delegate pattern 및 클로저 콜백 방식 선택 이유
다른 객체에서 반드시 이벤트를 전달받아야 하는 경우에는 protocol을 사용해서 **delegate pattern**으로 구현하였습니다<br><br>
다만 KeyboardIOManager에서는 delegate pattern 대신 **클로저 콜백**을 이용하여 WriteReviewViewController에 이벤트를 전달해 주었는데 그 이유는 구현된 알고리즘에 따라 보내주는 이벤트의 종류나 개수가 모두 달랐기 때문입니다
<br><br>
실제로 이번 프로젝트에서 KeyboardIOManager의 알고리즘을 각자 생각해봤었는데 보내주는 이벤트의 개수 및 종류가 전부 달랐었습니다

&nbsp;

# 한글 오토마타
![image](https://github.com/Kim-Junhwan/IOS-CustomKeyboard/assets/58679737/cbc1df69-a088-4ac7-a435-e879bd7bd781)

오토마타를 구현하면서 가장 크게 신경쓴 부분은 효율성입니다. 처음에는 글자를 입력받으면, 입력받은 글자를 큐에 push하고, 큐를 pop해서 글자를 조합해 나가는 방식으로 구현하려 했습니다. 그러나 큐의 길이가 길어짐에 따라 시간도 오래 걸리고 음절 하나를 추가하는데 처음부터 계산을 해야하는 비효율적인 상황에 놓입니다. 따라서 오토마타처럼 현재 상태에 따라 글자를 조합해 나가는 방식으로 구현을 했습니다.

## 한글 입력

오토마타 상태의 전이에 따라서 한글을 조합하는 알고리즘을 구현했습니다. 오토마타의 각 상태에 따른 상태 전이 알고리즘과 해당 상태에서 작업을 진행할 알고리즘 두개로 나뉘어져 있습니다.<br>
<br>
오토마타는 이전에 입력한 글자, 현재 입력한 글자, 현재 상태에 따라 어떤 상태로 이동할지 결정합니다. 상태를 전이 하고 나면, 각 상태에 따른 작업을 진행합니다.<br>
<br>
작업을 진행하고 나면, 현재 오토마타의 상태, 입력된 키, 입력된 글자의 종류, 조합된 한글을 스택에 넣어 저장합니다. 또 조합된 글자를 버퍼에 넣습니다. 버퍼는 조립된 한글 문자열을 저장하고, textField에 조립된 한글 문자열을 보여주는 역할을 합니다.

## 글자 지우기

![스크린샷 2022-07-23 오후 2 12 33](https://user-images.githubusercontent.com/58679737/180591428-d85145f2-1459-4814-9094-002966f3834f.png)

글자를 지우는데 입력한 키, 오토마타 상태등의 정보를 저장한 스택을 사용합니다. 스택을 pop하고 스택에 가장 마지막에 저장된 글자의 조합을 현재 조합중인 글자에 넣습니다. 또한 현재 오토마타의 상태와 입력된 키 값을 마지막에 저장된 상태와 키값으로 변경해줍니다.<br>
오토마타의 상태가 이전 상태로 돌아가 이전 상태에서 조합이 가능해, 그 상태에서 다른 상태로 전이및 조합이 가능합니다.<br>
<br>
IOS의 키패드는 조립중인 글자는 한음자씩, 스페이스를 누르거나 커서가 변경되어 조합이 종료된 글자는 통째로 지웁니다. 이를 구현하기 위해 스페이스바가 눌리면 조합이 즉시 종료되고 오토마타와 입력한 키를 저장하는 스택을 즉시 비우며, 한칸을 띄웁니다. 스택이 빈 경우에는 버퍼를 removeLast()하여 마지막 글자를 지웁니다.
