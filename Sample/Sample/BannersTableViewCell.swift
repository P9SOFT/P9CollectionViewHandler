//
//  BannersTableViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 19.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit
import P9TableViewHandler

class BannersTableViewCell: UITableViewCell {
    
    private let cellIdentifierForType:[String:String] = [
        "1" : TextCollectionViewCell.identifier(),
        "2" : BannerCollectionViewCell.identifier()
    ]
    
    private let supplementaryIdentifierForType:[String:String] = [
        "1" : LabelCollectionReusableView.identifier()
    ]
    
    fileprivate var data:[String:Any]?
    fileprivate var handler = P9CollectionViewHandler()
    fileprivate weak var delegate:P9TableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        handler.standby(identifier: "banners", cellIdentifierForType: cellIdentifierForType, supplementaryIdentifierForType: supplementaryIdentifierForType, collectionView: collectionView)
        handler.delegate = self
    }
}

extension BannersTableViewCell: P9TableViewCellProtocol {
    
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2, let banners = data["banners"] as? [[String:Any]], let first = banners.first else {
            return 0
        }
        
        return (TextCollectionViewCell.cellSizeForData(first, extra: nil).height + 8)
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return
        }
        self.data = data
        titleLabel.text = data["title"] as? String ?? ""
        titleLabel.textColor = (data["textColor"] as? String ?? "000000").colorByHex
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
        if let banners = data["banners"] as? [[String:Any]], banners.count > 0 {
            var records:[P9CollectionViewHandler.Record] = []
            for banner in banners {
                records.append(P9CollectionViewHandler.Record(type: "\(banner["type"] as? Int ?? 0)", data: banner, extra: nil))
            }
            let headerType = (data["header"] as? [String:Any] ?? [:])["type"] as? Int ?? 0
            let footerType = (data["footer"] as? [String:Any] ?? [:])["type"] as? Int ?? 0
            handler.setSections([P9CollectionViewHandler.Section(headerType: "\(headerType)", headerData: data["header"], footerType: "\(footerType)", footerData: data["footer"], records: records, extra: nil)])
        } else {
            handler.setSections([])
        }
        collectionView.reloadData()
    }
    
    func setDelegate(_ delegate: P9TableViewCellDelegate) {
        
        self.delegate = delegate
    }
}

extension BannersTableViewCell: P9CollectionViewHandlerDelegate {
    
    func collectionViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?) {
        
        delegate?.tableViewCellEvent(cellIdentifier: cellIdentifier, eventIdentifier: "select \(indexPath)", data: data, extra: extra)
    }
    
    func collectionViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?) {
        
        delegate?.tableViewCellEvent(cellIdentifier: cellIdentifier, eventIdentifier: eventIdentifier, data: data, extra: extra)
    }
    
    func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionViewHandler(handlerIdentifier:String, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
