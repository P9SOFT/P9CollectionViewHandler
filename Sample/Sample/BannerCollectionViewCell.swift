//
//  BannerCollectionViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 19.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {
    
    fileprivate var data:[String:Any]?
    fileprivate weak var delegate:P9CollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func clickButtonTouchUpInside(_ sender: Any) {
        
        delegate?.collectionViewCellEvent(cellIdentifier: Self.identifier(), eventIdentifier: EventId.clickMe.rawValue, data: data, extra: nil)
    }
}

extension BannerCollectionViewCell: P9CollectionViewCellProtocol {
    
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize {
        
        return CGSize(width: 160, height: 160)
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return
        }
        self.data = data
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
        if let imageId = data["imageId"] as? Int {
            self.imageView.image = UIImage(named: "img\(imageId)")
        } else {
            self.imageView.image = nil
        }
    }
    
    func setDelegate(_ delegate: P9CollectionViewCellDelegate) {
        
        self.delegate = delegate
    }
}
