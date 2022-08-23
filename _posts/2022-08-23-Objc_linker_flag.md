---
title: "Linker flag -Objc"
categories:
  - XCode
  - objective-c
tags:
  - XCode
  - iOS
  - objective-c
  - framework
---

# 원문은 아래의 내용입니다.
### [내용 링크](https://developer.apple.com/library/archive/qa/qa1490/_index.html)

Objective-C로 작성된 static framework를 사용하다 보면 런타임시에 "unrecognized selector sent to instance 0x00000a1d" 에러와 함께
크래시가 발생하는 경우가 있다.

다른 케이스도 있겠지만 여기서 다루는 내용은 카테고리 구현체가 class 구현 파일과 따로 생성되어 빌드되는 경우에 발생한다. 

Dynamic한 특성을 제공하기 위해, Method가 호출되기 전까지 method를 구현한 코드가 결정되지 않는다(symbol로만 표시해두고, 나중에 Runtime에 실행할 코드가 결정된다). 

그리고 Objective-C는 method를 위한 linker symbol은 정의하지 않고 class를 위한 linker symbol만 정의한다.
즉 class에 대한 symbol은 있지만, 카테고리로 정의한 method symbol은 없는 것이다.

-ObjC라는 Linker Flag는 linker가 static library에 있는 모든 Objective-C로 작성된 class와 category를 load하도록 빌드 옵션을 설정해 주면 "unrecognized selector sent to instance " 크래시는 수정될수 있다.
