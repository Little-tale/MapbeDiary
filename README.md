
# 메모 일지도 ReadMe

- 메모일지도 앱은 Swift로 구현한 지도기반 메모앱 입니다.

> 일상 속, 스쳐 지나가는 수많은 장소들은 종종 생각보다 더 깊은 의미를 지닐 때가 있습니다.
이런 장소들에 담긴 우리의 추억과 경험은 시간이 지나면서 희미해지기 쉬운데,
만약 이러한 순간들을 보다 구체적으로 기록으로 남길 수 있다면 어떨까요?
> 

# 소개 사진 

![GitImage 001](https://github.com/Little-tale/MapbeDiary/assets/116441522/ad505d13-463c-4b0a-91a1-905650908e67)


# 📷 메모 일지도 프로젝트 소개

> 지역을 저장하고 그지역에 대한 기록을 남깁니다.
> 
- 메모 일지도는 지도를 기반으로 메모와 사진을 남길수 있는 앱입니다.
- 사용자의 위치를 통해 메모를 남길수 있습니다.
- 특정 장소를 검색해 메모를 남길수 있습니다.
- 하나의 장소에서 여러 메모를 남길수 있습니다.
- 지도의 마커를 사용자가 정한 사진으로 변경해 커스텀 할수 있습니다.
- 여러 장소에 남긴 메모들을 모아 볼수 있습니다.

## 📸 개발기간

> 3/4 ~ 3/24 ( 2주간 )
> 

# 📷 사용한 기술들

- UIKit / MapKit
- MVVM / Facade /  Router / Repository / strategy / SingleTone
- URLSession / Decodable
- CodeBaseUI / SnapKit /  Compositional
- Realm(Swift) / FireBase Analytics / FireBase Crashlytics
- FloatingPanel / IQKeyboard / Toast
- API : KAKAO REST API ( 키워드로 장소 검색하기, 좌표로 주소 변환하기 )

# 📷 기술설명

## MVVM

> 커스텀 Observable 클래스를 생성하여 MVVM Input-output패턴을 통해 
비즈니스 로직을 분리하여 재사용성을 높였습니다.
> 

## URLSession

> Api 요청시 각각의 에러들을 직접 핸들링 하기위해
라우터 패턴과 전략적 패턴을 섞어 각 API의 에러코드나 
URLResponse 등의 에러들을 핸들링 하였습니다.
> 

## Realm Swift

> EmbeddedObject와 LinkingObject를 통해 
Too many RelationShip 을 컨트롤하였으며, 각각의 에러들을 Enum으로 정의해 
에러를 컨트롤 하였습니다.
> 

![스크린샷 2024-03-27 오후 7 04 31](https://github.com/Little-tale/MapbeDiary/assets/116441522/c4249ad9-bb5f-40b1-98c3-7a33b68d79ea)

## FireBase **Crashlytics / FireBase Analytics**

- 사용자들이 사용시 문제가 발생한 부분들을 분석해 보완하기 위해 **Crashlytics를 적용하였습니다.**
- 또한 어떠한 씬에서 많은 이탈이 발생하였는지 분석하기 위해 **FireBase Analytics를 적용하였습니다.**

# 📷 앱 흐름도

![스크린샷 2024-03-24 오후 11 23 05](https://github.com/Little-tale/MapbeDiary/assets/116441522/6e89f990-5c21-4613-9e0b-3d1a3a448158)

# UI ScreenShot 

## 온보딩 화면

![1](https://github.com/Little-tale/MapbeDiary/assets/116441522/f81da74a-90ba-4c65-8c82-a88b97416c7a)

## 마커 이미지 변경

![2](https://github.com/Little-tale/MapbeDiary/assets/116441522/186528e0-1492-485e-8530-4cb3094a99b3)

## Detail 메모 수정

![3](https://github.com/Little-tale/MapbeDiary/assets/116441522/ef0fc024-182e-48c6-973e-9c20f9b73a38)

## 설정창

![4](https://github.com/Little-tale/MapbeDiary/assets/116441522/5e34fea8-4bd9-4ccb-8752-ff1db3709a4b)

## 검색화면과 마커

![5](https://github.com/Little-tale/MapbeDiary/assets/116441522/917c9678-ead0-4391-9a31-8ba57e5387ca)

## Detail메모 작성

![6](https://github.com/Little-tale/MapbeDiary/assets/116441522/eaaac89f-4d7c-424e-b13f-1e6269991f23)

## Detail메모 삭제와 Location 삭제

![7](https://github.com/Little-tale/MapbeDiary/assets/116441522/b9a57886-9817-4d40-8b22-ea63ce033418)
## longPress 와 저장

![8](https://github.com/Little-tale/MapbeDiary/assets/116441522/22e96509-3fbc-4710-affb-d75470e24d7c)

## 추가 메모 작성

![9](https://github.com/Little-tale/MapbeDiary/assets/116441522/2ea1be05-0a71-4389-b763-d6dc072d6cb8)

## 사용자 마커 액션,
Memo 버튼 액션,
List 에서 메모 삭제

![10](https://github.com/Little-tale/MapbeDiary/assets/116441522/798da9ea-5583-47b0-ad2d-8bf9755feb36)

# 새롭게 학습 한 부분 과 고려했던 사항

## 네트워크 오프라인 상황에서도 작동하도록

> 네트워크에 연결되어 있지 않은 상태에서도 사용할 수 있도록, <br>
네트워크 상태를 감지하는 클래스를 만들어 사용자가 메모를 남기거나 사진을 남길 수 있도록 하였습니다.
> 

```swift
import Network
final class NetWorkServiceMonitor {

    static let shared = NetWorkServiceMonitor()    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case cellular
        case ethernet
        case unknown
        case wifi
    }
    // 네트워크 상태 확인
    public func startMonitor(){} 
```

## 이미지 변경시 변경된 사항만 적용하기

> 이미 사용자가 저장하였던 이미지를 수정하거나 삭제하였을 때 <br>
기존의 방식이었던 지우고 다시 쓰기는 데이터 처리와 성능에 있어 <br>
비효율적인 방법이라는 판단이 들었습니다. <br>
이에 따라 기존의 데이터와 수정되어야 할 데이터를 비교하여 최소한의 비용으로 <br> 
추가 삭제가 될 수 있도록 하였습니다.
> 

```swift
var removeImageObject: [ImageObject] = []
var originalImageObject: [ImageObject] = []

........
 // 원본 | A | B | C | >= index + 1
  if (indexPath.item + 1) <= originalCount, originalCount != 0 {
      // 지워질 에정으로 옮기기
      let willRemove = emptyModel.value.originalImageObject[indexPath.item]
            
      emptyModel.value.removeImageObject.append(willRemove)
      emptyModel.value.originalImageObject.remove(at: indexPath.item)
 }
 ........
```

## 카메라와 갤러리 권한을 관리하는 클래스 (Facade 패턴)

> 현재 프로젝트에는 여러 씬에서 카메라와 이미지 권한을 요구하고, 이미지 받아야 하였습니다. <br>
그때마다 해당하는 ViewController 에서 권한을 확인하고 요구하고, <br>
이미지를 처리하는 작업을 하는 것이 비효율적인 작업이라고 판단하여 <br>
Image 권한과 데이터를 전달하여 주는 클래스를 만들어 적용하였습니다. 
> 

```swift
enum ImagePickMode{
    case camera // 한장만 할 경우
    case maximer(Int) // 갤러리, 여러장이지만 최대정하기
}
enum ImageServiceError: Error {
    case cantGetImage
}

/// 이미지 관련된 기능을 제공하는 서비스 클래스 입니다.
final class ImageService: NSObject { 
        // 이미지의 결과 타입
        typealias ImageResult = ( Result<[UIImage]?, ImageServiceError> ) -> Void
        /// 이미지 피커를 띄울 ViewController
    private weak var presntationViewController: UIViewController?
    /// 이미지 결과 핸들러
    private var complitionHandler: ( ( Result<[UIImage]?, ImageServiceError> ) -> Void )?
       
    func pickImage(complite: @escaping ImageResult){ ... } 
    
    func checkCameraPermission(compltion: @escaping (Bool) -> Void)
..........
 
}
```

# **localization**

> 현재 앱은 한국에서만 사용할 수 있는 앱이지만, 한국에 사는 외국인들을 위해 <br>
현지화 작업을 통해 영어로도 앱을 사용할 수 있도록 현지화 작업을 했습니다.
> 

```swift
// Localizable.strings (ko)
"Error_alert_title" = "에러";

"Alert_check_title" = "확인";

"Cancel_check_title" = "취소";

"Kakao_error_message_type1" = "서비스에 문제가 발생했습니다. 다시 시작해주세요!";
......
// Localizable.strings (en) 
"Error_alert_title" = "Error";

"Alert_check_title" = "check";

"Cancel_check_title" = "Cancel";

"Kakao_error_message_type1" = "There was a problem with the service, please restart it!";
.....
```

# 이슈 대처

## Panel 내려가는 도중 새로운 Panel에 의한 ( UI 비동기 Issue )

> Panel을 보고 있는 동안 다른 뷰 컨트롤러 Panel을 띄어야 할 때 보고 있던 Panel이 내려가는 도중 
새로운 Panel이 나오게 됨으로써 원래의 Panel이 deinit은 되었으나
화면에서 사라지지 않는 Issue ( UI 비동기 Issue ) 가 있었습니다.
> 

> Panel이 완전히 내려갔음을 @escaping 으로 감지하여 
새로운 Panel을 UI에 그리게 함으로써 문제를 해결하였습니다.
> 

```swift
// MARK: 판넬을 내리고 싶을때
    private func removeExistingPanelIfNeeded(completion: @escaping () -> Void) {
        if let existingPanel = floatPanel {
            existingPanel.removePanelFromParent(animated: true) { [weak self] in
                self?.floatPanel = nil
                completion()
            }
        } else {
            completion()
        }
    }
```

```swift
 private func updateFloatingPanel(with configuration: PanelConfiguration) {
        removeExistingPanelIfNeeded { [weak self] in
            self?.setupPanel(with: configuration)
        }
    
```

## Image Resizing 이슈와 메모리 관찰

![imageResizing](https://github.com/Little-tale/MapbeDiary/assets/116441522/0a09eb5b-bd8a-4054-bf7e-022d8a3c949d)

> 버튼이나 마커에 이미지를 적용할 때,
이미지 크기가 너무 커서 영역을 벗어나는
이슈가 있었습니다. 
이미지 크기를 줄이기 위해 이미지 리사이징을
적용하였는데,
> 

> 메모리 효율을 비교하기 위해 이미지 리사이징을 하지 않았을 때와
이미지 리사이징을 하고나서 저장하고 적용 하였을 때를 비교하여 최대한의 효율을 위해
이미지 리사이징을 한후 저장한 이미지를 불러오는 방법을 채택하였습니다.
> 

### 이미지 리사이징 하기전

![ResigingBefore](https://github.com/Little-tale/MapbeDiary/assets/116441522/55b13036-d27a-49c1-a53f-209bc3d34961)


### 이미지 리사이징후
(이미지 저장할때 리사이징후 저장)

![ResizingAfter](https://github.com/Little-tale/MapbeDiary/assets/116441522/12a9198c-14b4-4fee-a42a-af9e63297af6)


```swift
// MARK: 이미지 리사이징
    func resizingImage(targetSize: CGSize) -> UIImage?{
        let widthScale = targetSize.width / self.size.width
        let heightScale = targetSize.height / self.size.height
        
        let minAbout = min(widthScale, heightScale)
        
        let scaledImageSize = CGSize(width: size.width * minAbout, height: size.height * minAbout)
        
        let render = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = render.image { [weak self] _ in
            guard let self else { return }
            draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
```

---
