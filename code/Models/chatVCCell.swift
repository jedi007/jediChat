//
//  chatVCCell.swift
//  jediChat
//
//  Created by 李杰 on 2020/4/10.
//  Copyright © 2020 李杰. All rights reserved.
//

import UIKit

class ChatVCCell: UITableViewCell {
    @IBOutlet weak var showlabel: UILabel!
    
    //实现系统设置了首选字体后自动更新字体大小， 还需在storyBoard中也做相应设置
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("messagesCell awakeFromNib")
        
        //nameLabel.adjustsFontForContentSizeCategory = true
    }
    
}