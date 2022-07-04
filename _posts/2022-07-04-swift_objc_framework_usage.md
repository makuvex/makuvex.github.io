---
title: "Swift framework에서 Objective-c framework 사용하기"
categories:
  - swift
  - objective-c
tags:
  - swift
  - iOS
  - objective-c
  - framework
---



## Swift framework 에서 Objective-c framework 사용하기

일반적인 연동 방법은 $productName-Bridging-Header.h를 사용하여 App Target에서 연동하는 방법이 주로 안내되고 있는데 이와 같은 방법으로 framework에서 연동하면 아래와 같은 오류가 발생 하는 군여 ㅠㅠ

> error: using bridging headers with framework targets is unsupported
Command CompileSwiftSources failed with a nonzero exit code

---

#### $productName-Bridging-Header.h. 사용
1. $productName-Bridging-Header.h 생성(SwiftTest-Bridging-Header.h)
2. Swift Target > build setting > Swift Compiler - General > Objective-C Bridging Header 항목에서 
$productName-Bridging-Header.h 추가
ex) $productName-Bridging-Header.h가 SwiftTest 폴더(모듈이름)안에 위치 하면 SwiftTest/SwiftTest-Bridging-Header.h 라고 입력
3. $productName-Bridging-Header.h. 안에 연동할 framework header를 import
ex) #import <ObjcTest/ObjcTestClass.h>
4. swift 파일 안에서는 import 추가 할 필요 없이 사용

```
@interface ObjcTestClass : NSObject

@property(nonatomic, strong, readonly) NSString *string;

@end
```

```swift
let objcc = ObjcTestClass()
print(objcc.string)
```
---

## 그럼 어떻게 할까요? 좀 보니까 moduleMap을 사용하는 방법이 괜찮은거 같은데 한번 알아보죠!

- 아래 스샷의 ObjcTest 프로젝트가 objective-c로 만든 framework이고 SwiftTest 프로젝트가 swift작성한 framework입니다.
- 빨간 박스로 표시한 부분이 이번에 다룰 내용이에요.

![](https://github.com/makuvex/makuvex.github.io/blob/main/assets/framework_shot1.png?raw=true)

1. module.modulemap이란 이름으로 파일을 생성합니다.
2. 연동 하고 싶은 public header로 모듈을 구성 합니다. framework이름이 ObjcTest.framework 이며 public header는  ObjcTestClass.h 에요
```
module ObjcTest {
    header "ObjcTest.framework/Headers/ObjcTestClass.h"
    export *
}
```
3. xcconfig파일을 구성 합니다. 이름은 마음에 드는거로 샥샥~ 저는 config로 지었어요.  
new. > ios -> other -> configuration settings file로 선택
```
SWIFT_INCLUDE_PATHS = $(SRCROOT)/
MODULEMAP_PRIVATE_FILE = $(SRCROOT)/module.modulemap
```
4. ObjcTest.framework을 confif.xcconfig랑 module.modulemap 파일이랑 동일 경로에 놓고 아래와 같이 사용하면 되는거야.       



```swift
import ObjcTest

let objc = ObjcTestClass()
print("test1 \(objc.string)")
```


[project 링크](https://github.com/makuvex/makuvex.github.io/blob/main/assets/objcWithSwiftFramework_0704.zip)

### 당연한 이야기 겠지만 private header, 혹은 objc category로 구성되고 public 하지 않는 모듈은 연동 할 수 없음. 
### 또한 ObjcTest.framework를 shortcut link로 연동하지 못하고 카피로 구성하여 확인함. 추후 shortcut link 방법으로 하는 포스팅을 추가할 계획이얌.

---
> 기존 소스들이 objective-c로 작성되었고 swift로 컨버전을 하면서 혹은 새 기능은 swift로 작성할때 framework들로 모듈을 구성하여 사용하면 얻는 이점이 많음.
그래서 이와 같은 형태로 legacy project들이 많이 구성되어 있는데 framework <-> framework 연동 방법에 대한 고민을 하던 중 이런 작업이 있어 기록 하려고 이렇게 구구절절 작성함(안하면 기억이 이제는 안남) ㅠㅠ. 귀찮항~
---
