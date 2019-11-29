//
//  LabelCollectionReusableView.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 19.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class LabelCollectionReusableView: UICollectionReusableView {
    
    fileprivate var data:[String:Any]?
    fileprivate weak var delegate:P9CollectionViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        delegate?.collectionViewCellEvent(cellIdentifier: LabelCollectionReusableView.identifier(), eventIdentifier: "touch", data: data, extra: nil)
    }
}

extension LabelCollectionReusableView: P9CollectionViewCellProtocol {
    
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 1 else {
            return .zero
        }
        
        return CGSize(width: 80, height: 160)
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 1 else {
            return
        }
        self.data = data
        self.titleLabel.text = data["title"] as? String ?? ""
    }
    
    func setDelegate(_ delegate: P9CollectionViewCellDelegate) {

        self.delegate = delegate
    }
}
