//
//  TextCollectionViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 19.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    fileprivate var data:[String:Any]?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension TextCollectionViewCell: P9CollectionViewCellProtocol {
    
    static func cellSizeForData(_ data: Any?, extra: Any?) -> CGSize {
        
        return CGSize(width: 160, height: 160)
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 1 else {
            return
        }
        self.data = data
        titleLabel.text = data["title"] as? String ?? ""
        titleLabel.textColor = (data["textColor"] as? String ?? "000000").colorByHex
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
    }
}
