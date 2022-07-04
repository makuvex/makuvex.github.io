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

## 그럼 어떻게 할까요? 쬐금 보니까 moduleMap을 사용하는 방법이 괜찮은거 같은데 한번 알아보죠!

구글링 해도 나오는데 여기서는 직접 사용한 방법으로 작성하려 해요.

![](https://github.com/makuvex/makuvex.github.io/blob/main/assets/framework_shot1.png?raw=true)


[project](https://github.com/user/repo/blob/branch/other_file.md)