//
//  DownloadsTableViewCell.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 03/09/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit
import Alamofire

class DownloadsTableViewCell: UITableViewCell {
    
    static let id = "DownloadsCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func animateProgress(download: Download) {
        
        download.request.downloadProgress { (progress) in
            self.progressLabel.text = "\(Int(progress.fractionCompleted * 100)) %"
        }
    }

}
