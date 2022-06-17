---
title: "Implicitly Unwrapped Optionals"
categories:
  - swift
tags:
  - swift
  - iOS
---
 

먼저 Swift.org의 설명을 한번 보고 갈께요.( [https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) )

>Sometimes it’s clear from a program’s structure that an optional will always have a value, after that value is first set.
In these cases, it’s useful to remove the need to check and unwrap the optional’s value every time it’s accessed, because it can be safely assumed to have a value all of the time.

>때때로 프로그램의 구조상 어떤 특정한 시점에는 옵셔널에 값이 무조건 들어있다는 것을 명확하게 알 수 있다.
이러한 경우에는 옵셔널에 값에 접근할때마다 **매번 옵셔널 언래핑 처리를 해주지 않아도 되는 것이 해당 사용성을 증가 시킬 수도 있다** . 왜냐하면 해당 옵셔널에는 값이 항상 있다고 추측할 수 있기 때문이다.

그리고 애플 스태프의 설명을 보고 제가 이해한 부분을 아래와 같이 정리했습니다. 최대한 풀어서 설명 하려 했는데 보시고 "아~ 모르겠다" 혹은 다른 의견 있으신 분 편하게 물어보셔도 됩니다.

관련 링크 : [https://developer.apple.com/forums/thread/99977](https://developer.apple.com/forums/thread/99977)

  

**1\. Swift API로 작성되지 않는 언어 호환성에서 null 허용에 대해 처리 가능**
-----------------------------------------------------

예를 들자면  옵씨로 UIDevice의 이름이 아래와 같이 정의되어 있어요.(NS\_ASSUME\_NONNULL\_BEGIN 미 선언)  
```
// UIDevice  
@property (nonatomic, readonly, strong) NSString name;  
```  
근데 이것을 swift로 자동변환 하면 "var name: String"으로 할지 "var name: String?" 할지 사람은 이름은 옵셔널이 아니야 라고 딱 판단 할수 있지만 스위프트 임포터는 잘 몰라요.

왜냐하면 nil이 될 수 있는지 없는지 선언자가 없기 때문이에요.

그래서 일단 "var name: String!"이렇게 변환을 해요.  
  
이 변환의 장점은 처음엔 nil이지만 어느 시점부터는 nil이 아님을 확실히 알고 있고 optional이 아닌것 처럼 사용이 가능한 부분이죠.

또한 nil이 아닌 것을 보장하지 못한다면 nil 체크를 먼저 하고 사용할 수 있는 것이에요. 즉 2가지 케이스 모두 커버가 가능하죠.


참고로 요새는 옵셔널에 대해 아래처럼 확인 마킹을 하고 있어 옵셔널이 아닌 것과 그런 것을 확실히 구분하고 있죠.  

```  
NS_ASSUME_NONNULL_BEGIN  
  
@property (nullable, nonatomic, readonly, strong) NSString name;  
  
NS_ASSUME_NONNULL_END
```
 

**2\. Swift의 엄격한 초기화 규칙에서 우회 가능**
---------------------------------

Swift는 이니셜라이저가 끝나기 전에 모든 속성을 초기화해야 합니다(클래스인 경우 super 호출 전에).

IBOutlet이 해당되는데 UIKit.framework의 class들은 대부분 옵씨로 구성되어 있어요.(근데 옵셔널에 대한 개념이 없음)

위의 1번과도 연관이 있는데 viewDidLoad이전에는 nil이지만 이후에는 nil이 아님을 보장하고 있죠.  
  

그리고 IBOutlet도 있는데 스토리보드에서 뷰 객체가 생성되기 전에는 IBOutlet은 nil이 들어있지만 생성되고 난 이후에는 해당 변수에 항상 값이 들어있을 것이기 때문에 암시적 언래핑 옵셔널으로 선언되어 있습니다.

만약 암시적 언래핑 옵셔널이 아닌 옵셔널로 매우 많은 IBOutlet들이 선언되고 항상 옵셔널 체크 및 사용이 일어난다면 사용성이 좋지는 않을 거 같아요.

**참고: 이 현상은 swift의 옵셔널 개념이 없는 Objective-C를 중심으로 IBOutlet이 설계되었기 때문에 발생합니다. 아직 애플에서는 IBOutlet과 Swift를 통합하는 더 나은 방법에 대한 계획은 없습니다.**

  
또 다른 경우도 있는데 URLSession 같은 경우를 보죠. 아래와 같이 session이 꼭 필요하고(옵셔널이 아닌) 변수로 선언이 되어 있어요.  
  
ex 1번의 경우에는 빌드 에러가 발생해요. self 사용하기 전에 super.init 먼저 호출하라고 하죠.

근데 URLSession의 파람으로 delegate가 꼭 들어가야 하는데 생성자, super호출 시점이 애매해져요.

해결하는 방법은 몇개가 있는데 일단 ex 2번과 같이 super 호출 전에 nil을 설정하고 이후에 URLSession의 param으로 self 전달 후 사용하는 것이에요.

3번처럼 lazy를 이용하는 방법도 있는데요 단지 암시적 언래핑 옵션에 대한 설명일 뿐 이에요
---------------------------------------------------------------

  
```swift
var session: URLSession!  
  
ex 1)  
required init?(coder: NSCoder) {  
    let config = URLSessionConfiguration.default  
    self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)  
  
    super.init(coder: coder)  
}  
  
ex 2)  
required init?(coder: NSCoder) {  
    let config = URLSessionConfiguration.default  
    self.session = nil  
    super.init(coder: coder)  
    self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)  
}  
  
ex 3)  
private lazy var session: URLSession = {  
    let config = URLSessionConfiguration.default  
    let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)  
    return session  
}()
```
 