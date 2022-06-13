# Xcode 컴파일 시간 및 런타임 실행 속도 높이기(swift)
 
## Code Optimizations(아래의 내용은 컴파일러 속도 최적화에만 관련된 부분이고 가독성 및 모듈화와 상충되는 부분이 있기 때문에 적절히 사용 )


### 1. 재사용
### 각각의 파일에 코드가 정의되어 있어 컴파일시 모두 시간이 소용됨. 아래와 같이 extension 파일을 작성하고 사용시에는 확장파일에만 컴파일 시간이 소요되고 복사됨.

```swift
// Bad: Writing isValidEmail variable twice
class LoginViewController: UIViewController {
	//...
}
```

```swift
fileprivate extension String {
	var isValidEmail : Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
		return predicate.evaluate(with: self)
	}
}
```

```swift
// Bad: Writing isValidEmail variable twice
class SignupViewController: UIViewController {
	//...
}
```

```swift
fileprivate extension String {
	var isValidEmail : Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
		return predicate.evaluate(with: self)
	}
}
```

```swift
// Bad: Writing isValidEmail variable twice
class LoginViewController: UIViewController {
	//...
}
```

```swift
// Good: Seperate extension which can be used multiple times
fileprivate extension String {
	var isValidEmail : Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
		return predicate.evaluate(with: self)
	}
}
```

### 2. 기본 구현만 정의된 오버라이딩 함수 제거

```swift
// Bad: Having Unnecessary useless code
final class FilterCell: UITableViewCell {

	@IBOutlet weak var labelTitle: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
```

```swift
// Good: Cleaned version
final class FilterCell: UITableViewCell {

	@IBOutlet weak var labelTitle: UILabel!
}
```

### 3. 가능하면 let(Immutable)를 사용
### 4. 상속 받기를 원하지 않는 class 앞에 final keyword 붙히기
### 5. 연관 파일에 같이 선언된 extension은 private or fileprivate 키워드를 붙여라

```swift
// Good: A good example to make the extension private.
final class VideoRecorder {
}
```

```swift
private extension VideoRecorder {

	func capturePhoto() {
	}

	func startRecording() {
	}

	func stopRecording() {
	}
}
```

### 6. 타입 선언을 명확히 선언
### 7. 타입을 명시 하지 않으면 컴파일러에서 타입을 찾아야 하는데 시간이 소요됨.

```swift
// Bad: Avoid the automatic type infer. It's an extra overhead for the compiler to determine the variable type
public class ViewController: UIViewController {
	let constantWidth = 100
	var isUpdating = false
	var isDataAvailable = false
	var userNames = [“Amit”, “Yogesh”, “Rohit”]
	var numbers = [1, 2, 3]
	var savedPaymentMethods = [SavedPaymentMethod]()
}
```

```swift
// Good: Always specify type of the variable to reduce compiler type infer work.
final class ViewController: UIViewController {
	private let constantWidth: CGFloat = 100
	fileprivate var isUpdating: Bool = false
	private(set) var isDataAvailable: Bool = false
	private var userNames: [String] = [“Amit”, “Yogesh”, “Rohit”]
	var numbers: [Int] = [1, 2, 3]
	private var savedPaymentMethods: [SavedPaymentMethod] = []
}
```

```swift
// Bad: Avoid .init because it's an extra overhead for the compiler to determine the type when compiling
button.transform = .init(scaleX: 1.5, y: 1.5)
button.contentEdgeInsets = .init(top: 11, left: 32, bottom: 11, right: 32)
tableView.contentSize = .init(width: 100, height: 500)
```

```swift
// Good: Using the Type init version
button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
button.contentEdgeInsets = UIEdgeInsets(top: 11, left: 32, bottom: 11, right: 32)
tableView.contentSize = CGSize(width: 100, height: 500)
```

### 7. 한줄에 너무 많은 계산식을 표현하지 말것.(컴파일러 힘듦)
```swift
// Bad: Long calculation in single line
let widthHeight = max(min(min(self.bounds.width - 60, self.bounds.height - 100), 100), 45)
```

```swift
// Good: Rewritten in multiple lines
let proposedWidthHeight = min(self.bounds.width - 60, self.bounds.height - 100)
let allowedMaxWidth = min(proposedWidthHeight, 100)
let widthHeight = max(allowedMaxWidth, 45)
```

```swift
// Bad: Multiple calculation in single line
func totalSeconds() -> Int {
	return (hours*60*60) + (minutes * 60) + seconds
}
```

```swift
// Good: Rewritten in multiple lines
func totalSeconds() -> Int {
	let totalHours: Int = hours*3600
	let totalMinutes: Int = minutes * 60
	return totalHours + totalMinutes + seconds
}
```

### 8. 문자열 보간법("\()")보다 연결 형태가 좀 더 낫다?(이거는 여러가지 말이 많은데 시간 측정을 다양하게 해봐야 함)
```swift
// Bad: Avoid interpolation whenver possible
var storageIdentifier: String {
	return "\(storageName)_\(installationId)"
}
````
```swift
// Good: Use concatenation whenever possible
var storageIdentifier: String {
	return storageName + "_" + installationId
}
```

### 9. BOOL형태 조건에서 == false or == true보다는 not operator 사용
```swift
// Bad Original statement
if flag == false {
	// do something on false
}
```

```swift
// Good Rewritten with !
if !flag {
	// do something on false
}
```
```swift
// Bad Original statement
if flag == true {
	// do something on true
}
```
```swift
// Good Rewritten
if flag {
// do something on true
}
```

### 10. 한 라인에 많은 ?? operator 사용하는것 보다 각각의 if let 이 더 낫다

```swift
// Bad: Doing all the calculations in a single line, which increases the compilation complexity.
return CGSize(width: size.width + (rightView?.bounds.width ?? 0) + (leftView?.bounds.width ?? 0) + 22, height: bounds.height)
```

```swift
// Good: Another solution is at least split the complex expression to multiple lines
let rightPadding: CGFloat = rightView?.bounds.width ?? 0
let leftPadding: CGFloat = leftView?.bounds.width ?? 0
return CGSize(width: size.width + rightPadding + leftPadding + 22, height: bounds.height)
```

```swift
// Best: Avoid the ?? operator and rewrite same thing with if let
var padding: CGFloat = 22
if let rightView = rightView {
	padding += rightView.bounds.width
}

if let leftView = leftView {
	padding += leftView.bounds.width
}

return CGSizeMake(size.width + padding, bounds.height)
```

## Storyboard Optimization
### 1. 하나의 스토리 보드에 너무 많은 scene,  viewController를 사용하지 말고 각각의 파일로 분리해서 사용
### 2. 하나의 controller에 많은 view들을 생성해서 사용하지 말고 controller를 분리해서 사용
### 3. controller에 UIScrollView를 사용해서 많은 내용을 넣지 말고 UITableView, UICollectionView를 사용

 