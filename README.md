P9CollectionViewHandler
============

UICollectionView is useful type of view to listing items.
But, typing control code is a kind of boilerplate.
P9CollectionViewHandler library help you to handling UICollectionView easy and simple.

# Installation

You can download the latest framework files from our Release page.
P9CollectionViewHandler also available through CocoaPods. To install it simply add the following line to your Podfile.
pod ‘P9CollectionViewHandler’

# Simple Preview

```swift
let cellIdentifierForType:[String:String] = [ 
    "1" : RedCollectionViewCell.identifier(),
    "2" : GreenCollectionViewCell.identifier(),
    "3" : BlueCollectionViewCell.identifier()
] 

let supplementaryIdentifierForType:[String:String] = [ 
    "1" : HeaderCollectionReusableView.identifier(),
    "2" : FooterCollectionReusableView.identifier()
] 

let collectionView = UICollectionView(frame .zero)

let handler = P9CollectionViewHandler()
handler.delegate = self
handler.standby(identifier:"sample", cellIdentifierForType: cellIdentifierForType, supplementaryIdentifierForType: supplementaryIdentifierForType, collectionView: collectionView)

var records:[P9CollectionViewHandler.Record] = []
records.append(P9CollectionViewHandler.Record(type: "2", data: nil, extra: nil))
records.append(P9CollectionViewHandler.Record(type: "3", data: nil, extra: nil))

handler.sections.append(P9CollectionViewHandler.Section(headerType: "1", headerData: nil, footerType: nil, footerData: nil, records: records, extra: nil))

collectionView.reloadData()

func collectionViewHandlerCellDidSelect(handlerIdentifier: String, cellIdentifier: String, indexPath: IndexPath, data: Any?, extra: Any?) {
    // handling collectionview default select action
}

func collectionViewHandlerCellEvent(handlerIdentifier: String, cellIdentifier: String, eventIdentifier: String?, indexPath:IndexPath?, data: Any?, extra: Any?) {
    // handling custom event from cell
}
```

Let's take a look around one by one.

# Make your collectionview cell confirm the protocol

You need confirm and implement P9CollectionViewCellProtocol as below for your collectionview cell to use P9CollectionViewHandler.
If you want to use supplementary view then, you need confirm and implement same protocol for it.

```swift
protocol P9CollectionViewCellProtocol: class {
    static func identifier() -> String
    static func instanceFromNib() -> UIView
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9CollectionViewCellDelegate)
    func setIndexPath(_ indexPath: IndexPath)
}
```

identifier and instanceFromNib function need return its' identifier string and instance object for collectionview cell.
But, these two function is optional. You don't need implement it, except that you want to do some customizing.
So, let the identifier function return the class name of your collection view cell and instanceFromNib return a instance object for given class name from identifier.

cellSizeForData function need return the size of collectionview cell for a given data.

```swift
static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize {
    guard let data = data as? CellDataModel else {
        return .zero
    }
    return CGSize(width: 40, height: 40)
}
```

setData function pass the data and extra object for updating your collectionview cell.
You can do your business code to update collectionview cell.

```swift
func setData(_ data: Any?, extra: Any?) {
    guard let data = data as? CellDataModel else {
        return
    }
    self.data = data
    self.titleLabel.text = data.title ?? "Sample"
}
```

setDelegate function pass the callback object to feedback custom event.
If your collectionview cell have some custom event, confirm P9CollectionViewCellDelegate to your controller first.

```swift
protocol P9CollectionViewCellDelegate: class {
    
    func collectionViewCellEvent(cellIdentifier:String, eventIdentifier:String?, indexPath:IndexPath?, data:Any?, extra:Any?)
}

extension ViewController: P9CollectionViewCellDelegate {
    // ...
}
```

and set delegate and feedback your custom event by it.

```swift
func setDelegate(_ delegate: P9CollectionViewCellDelegate) {
    self.delegate = delegate
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.collectionViewCellEvent(cellIdentifier: SampleCollectionViewCell.identifier(), eventIdentifier: "touch", indexPath: nil, data: data, extra: nil)
}
```

setIndexPath function pass the indexPth object.
You can store this indexPath information and send it with event delegate call.

```swift
func setIndexPath(_ indexPath: IndexPath) {
    self.indexPath = indexPath
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.collectionViewCellEvent(cellIdentifier: SampleCollectionViewCell.identifier(), eventIdentifier: "touch", indexPath: indexPath, data: data, extra: nil)
}
```

If your project based on Objective C then, you need confirm and implement P9CollectionViewCellObjcProtocol for your collectionview cell.
Not P9CollectionViewCellProtocol but P9CollectionViewCellObjcProtocol.
It have same member functions with P9CollectionViewCellProtocol, but you must implemnt all functions include identifier and instanceFromNib.

```objective-c
+ (NSString *)identifier {
    return @"SampleCollectionViewCell";
}

+ (UIView *)instanceFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:[SampleCollectionViewCell identifier] owner:nil options:nil] firstObject];
}
```

# Handling

Now, your collectionview cells are ready.
Make dictionary for type key with your collectionview cell identifiers, and supplementary view identifiers.
Just make unique type key value as you wish or some type value from server response model.

```swift
let cellIdentifierForType:[String:String] = [ 
    "1" : RedCollectionViewCell.identifier(),
    "2" : GreenCollectionViewCell.identifier(),
    "3" : BlueCollectionViewCell.identifier()
] 

let supplementaryIdentifierForType:[String:String] = [ 
    "1" : HeaderCollectionReusableView.identifier(),
    "2" : FooterCollectionReusableView.identifier()
] 
```

Set them to handler.
And, dont't forget set delegate to get feedback from handler.

```swift
let handler = P9CollectionViewHandler()
handler.standby(identifier:"sample", cellIdentifierForType: cellIdentifierForType, supplementaryIdentifierForType: supplementaryIdentifierForType, collectionView: collectionView)
handler.delegate = self
```

And, you need to make model data for handler.
Don't worry, you can use your own model without any change. Just wrapping them into handler model.
Here is defintion of handler models.

```swift
@objc(P9CollectionViewRecord) public class Record : NSObject {
    var type:String
    var data:Any?
    var extra:Any?
    @objc public init(type:String, data:Any?, extra:Any?=nil) {
        self.type = type
        self.data = data
        self.extra = extra
    }
}
    
@objc(P9CollectionViewSection) public class Section : NSObject {
    var headerType:String?
    var headerData:Any?
    var footerType:String?
    var footerData:Any?
    var extra:Any?
    var records:[Record]?
    @objc public init(headerType:String?, headerData:Any?, footerType:String?, footerData:Any?, records:[Record]?, extra:Any?) {
        self.headerType = headerType
        self.headerData = headerData
        self.footerType = footerType
        self.footerData = footerData
        self.records = records
        self.extra = extra
    }
}
```

You can make model by N sections with M records within each sections as normal collectionview data structure.
Make records, sections as you want and set them to handler.

```swift
var records:[P9CollectionViewHandler.Record] = []
records.append(P9CollectionViewHandler.Record(type: "1", data: nil, extra: nil))
records.append(P9CollectionViewHandler.Record(type: "2", data: nil, extra: nil))

handler.sections.append(P9CollectionViewHandler.Section(headerType: nil, headerData: nil, footerType: nil, footerData: nil, records: records, extra: nil))
```

And, reload targt collectionview.

```swift
collectionView.reloadData()
```

Now, get message from each collectionview cells by confirm protocol P9CollectionViewHandlerDelegate.
Here is protocol and implement sample.

```swift
@objc public protocol P9CollectionViewHandlerDelegate: class {
    @objc optional func collectionViewHandlerWillBeginDragging(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func collectionViewHandlerDidScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func collectionViewHandlerDidEndScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func collectionViewHandler(handlerIdentifier:String, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    @objc optional func collectionViewHandler(handlerIdentifier:String, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
    @objc optional func collectionViewHandler(handlerIdentifier:String, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    @objc optional func collectionViewHandler(handlerIdentifier:String, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)
    @objc optional func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    @objc optional func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    @objc optional func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    @objc optional func collectionViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?)
    @objc optional func collectionViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, indexPath:IndexPath?, data:Any?, extra:Any?)
}
```

```swift
extension ViewController: P9CollectionViewHandlerDelegate {
    
    func collectionViewHandlerCellDidSelect(handlerIdentifier: String, cellIdentifier: String, indexPath: IndexPath, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) indexPath \(indexPath.section):\(indexPath.row) did select")
    }
    
    func collectionViewHandlerCellEvent(handlerIdentifier: String, cellIdentifier:String, eventIdentifier:String?, indexPath: IndexPath?, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) event \(eventIdentifier ?? "")")
    }
}
```

If you don't like huge switch code, then use callback function(or block) for each event identifier.

```swift
enum EventId: String {
    case clickMe
}

handler.registerCallback(callback: doClickMe(indexPath:data:extra:), forCellIdentifier: CollectionViewCell.identifier(), withEventIdentifier: EventId.clickMe.rawValue)

extension TableViewCell {
    
    func doClickMe(indexPath:IndexPath?, data:Any?, extra:Any?) {
        
        print("Got Click Me.")
    }
}
```

You can also use callback function(or block) for selecting cell event by not passing event identifier.

```swfit
handler.registerCallback(callback: collectionViewCellSelectHandler(indexPath:data:extra:), forCellIdentifier: CollectionViewCell.identifier())
```

# License

MIT License, where applicable. http://en.wikipedia.org/wiki/MIT_License
