//
//  P9CollectionViewHandler.swift
//
//
//  Created by Tae Hyun Na on 2019. 5. 14.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

@objc public protocol P9CollectionViewCellDelegate: class {
    
    func collectionViewCellEvent(cellIdentifier:String, eventIdentifier:String?, indexPath:IndexPath?, data:Any?, extra:Any?)
}

public protocol P9CollectionViewCellProtocol: class {
    
    static func identifier() -> String
    static func instanceFromNib() -> UIView?
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9CollectionViewCellDelegate)
    func setIndexPath(_ indexPath: IndexPath)
}

public extension P9CollectionViewCellProtocol {
    
    static func identifier() -> String {
        
        return String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
    
    static func instanceFromNib() -> UIView? {
        
        return Bundle.main.loadNibNamed(identifier(), owner: nil, options: nil)?[0] as? UIView
    }
    
    func setDelegate(_ delegate:P9CollectionViewCellDelegate) {}
    
    func setIndexPath(_ indexPath: IndexPath) {}
}

@objc public protocol P9CollectionViewCellObjcProtocol: class {
    
    static func identifier() -> String
    static func instanceFromNib() -> UIView?
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9CollectionViewCellDelegate)
    func setIndexPath(_ indexPath: IndexPath)
}

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

@objc open class P9CollectionViewHandler: NSObject {
    
    @objc(P9CollectionViewRecord) public class Record : NSObject {
        @objc public var type:String
        @objc public var data:Any?
        @objc public var extra:Any?
        @objc public init(type:String, data:Any?, extra:Any?) {
            self.type = type
            self.data = data
            self.extra = extra
        }
    }
    
    @objc(P9CollectionViewSection) public class Section : NSObject {
        @objc public var headerType:String?
        @objc public var headerData:Any?
        @objc public var footerType:String?
        @objc public var footerData:Any?
        @objc public var extra:Any?
        @objc public var records:[Record]?
        @objc public init(headerType:String?, headerData:Any?, footerType:String?, footerData:Any?, records:[Record]?, extra:Any?) {
            self.headerType = headerType
            self.headerData = headerData
            self.footerType = footerType
            self.footerData = footerData
            self.records = records
            self.extra = extra
        }
    }
    
    public typealias CallbackBlock = (_ indexPath:IndexPath?, _ data:Any?, _ extra:Any?) -> Void
    
    fileprivate let moduleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    fileprivate var handlerIdentifier:String = ""
    fileprivate var cellIdentifierForType:[String:String] = [:]
    fileprivate var supplementaryIdentifierForType:[String:String] = [:]
    fileprivate var callbackBlocks:[String:CallbackBlock] = [:]

    @objc public var sections:[Section] = []
    @objc public weak var delegate:P9CollectionViewHandlerDelegate?
    
    @objc public func standby(identifier:String, cellIdentifierForType:[String:String], supplementaryIdentifierForType:[String:String], collectionView:UICollectionView) {
        
        handlerIdentifier = identifier
        self.cellIdentifierForType = cellIdentifierForType
        self.supplementaryIdentifierForType = supplementaryIdentifierForType
        self.cellIdentifierForType.forEach { (key, value) in
            collectionView.register(UINib(nibName: value, bundle: nil), forCellWithReuseIdentifier: value)
        }
        self.supplementaryIdentifierForType.forEach { (key, value) in
            collectionView.register(UINib(nibName: value, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: value)
            collectionView.register(UINib(nibName: value, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: value)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc public func registCallback(callback: @escaping CallbackBlock, forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) {
        
        callbackBlocks[key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier)] = callback
    }
    
    @objc public func unregistCallback(forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) {
        
        callbackBlocks.removeValue(forKey: key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier))
    }
    
    @objc public func unregistAllCallbacks() {
        
        callbackBlocks.removeAll()
    }
}

extension P9CollectionViewHandler {
    
    fileprivate func key(forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) -> String {
        
        if let eventIdentifier = eventIdentifier {
            return "\(cellIdentifier):\(eventIdentifier)"
        }
        return "\(cellIdentifier):"
    }
}

extension P9CollectionViewHandler: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard section >= 0, section < sections.count else {
            return 0
        }
        return sections[section].records?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard indexPath.section >= 0, indexPath.section < sections.count,
            let type = sections[indexPath.section].headerType,
            let clsName = supplementaryIdentifierForType[type], clsName.count > 0 else {
                return UICollectionReusableView()
        }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter :
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: clsName, for: indexPath)
            let data = (kind == UICollectionView.elementKindSectionHeader ? sections[indexPath.section].headerData : sections[indexPath.section].footerData )
            if let view = view as? P9CollectionViewCellProtocol {
                view.setData(data, extra: sections[indexPath.section].extra)
                view.setDelegate(self)
                view.setIndexPath(indexPath)
            }
            if let view = view as? P9CollectionViewCellObjcProtocol {
                view.setData(data, extra: sections[indexPath.section].extra)
                view.setDelegate(self)
                view.setIndexPath(indexPath)
            }
            return view
        default :
            break
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].headerType,
            let clsName = supplementaryIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName),
            let collectoinViewCellContentsCell = cls as? P9CollectionViewCellProtocol.Type else {
                return .zero
        }
        
        return collectoinViewCellContentsCell.cellSizeForData(sections[section].headerData, extra: sections[section].extra)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].footerType,
            let clsName = supplementaryIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName),
            let collectoinViewCellContentsCell = cls as? P9CollectionViewCellProtocol.Type else {
                return .zero
        }
        
        return collectoinViewCellContentsCell.cellSizeForData(sections[section].footerData, extra: sections[section].extra)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
            let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count,
            let clsName = cellIdentifierForType[records[indexPath.row].type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
                return .zero
        }
        
        if let cellType = cls as? P9CollectionViewCellProtocol.Type {
            return cellType.cellSizeForData(records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
        if let cellType = cls as? P9CollectionViewCellObjcProtocol.Type {
            return cellType.cellSizeForData(records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count,
              let clsName = cellIdentifierForType[records[indexPath.row].type], clsName.count > 0 else {
                return UICollectionViewCell(frame: .zero)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: clsName, for: indexPath)
        if let cell = cell as? P9CollectionViewCellProtocol {
            cell.setData(records[indexPath.row].data, extra: records[indexPath.row].extra)
            cell.setDelegate(self)
            cell.setIndexPath(indexPath)
        }
        if let cell = cell as? P9CollectionViewCellObjcProtocol {
            cell.setData(records[indexPath.row].data, extra: records[indexPath.row].extra)
            cell.setDelegate(self)
            cell.setIndexPath(indexPath)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count else {
                return
        }
        
        let cellIdentifier = cellIdentifierForType[records[indexPath.row].type] ?? records[indexPath.row].type
        
        if let callback = callbackBlocks[key(forCellIdentifier: cellIdentifier)] {
            callback(indexPath, records[indexPath.row].data, records[indexPath.row].extra)
        } else {
            delegate?.collectionViewHandlerCellDidSelect?(handlerIdentifier: handlerIdentifier, cellIdentifier: cellIdentifier, indexPath: indexPath, data: records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let edgeInsets = delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, layout: collectionViewLayout, insetForSectionAt: section) {
            return edgeInsets
        }
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if let spacing = delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) {
            return spacing
        }
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if let spacing = delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) {
            return spacing
        }
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, willDisplay: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        delegate?.collectionViewHandler?(handlerIdentifier: handlerIdentifier, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
    }
}

extension P9CollectionViewHandler: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        delegate?.collectionViewHandlerWillBeginDragging?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.collectionViewHandlerDidScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            delegate?.collectionViewHandlerDidEndScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        delegate?.collectionViewHandlerDidEndScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
}

extension P9CollectionViewHandler: P9CollectionViewCellDelegate {
    
    public func collectionViewCellEvent(cellIdentifier: String, eventIdentifier: String?, indexPath: IndexPath?, data: Any?, extra: Any?) {
        
        if let eventIdentifier = eventIdentifier, let callback = callbackBlocks[key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier)] {
            callback(indexPath, data, extra)
        } else {
            delegate?.collectionViewHandlerCellEvent?(handlerIdentifier: handlerIdentifier, cellIdentifier: cellIdentifier, eventIdentifier: eventIdentifier, indexPath: indexPath, data: data, extra: extra)
        }
    }
}
