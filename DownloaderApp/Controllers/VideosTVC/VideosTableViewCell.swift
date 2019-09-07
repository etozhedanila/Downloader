//
//  VideosTableViewCell.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit

class VideosTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var dateLabel: UILabel!
    
    static let id = "videoCell"
    
    private var title: String = "title"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sendSubviewToBack(titleTextField)
        self.titleTextField.delegate = self
        self.titleTextField.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if isEditing == true {
            self.titleTextField.isUserInteractionEnabled = true
        }
        else {
             self.titleTextField.isUserInteractionEnabled = false
        }
    }
    
    func configure(video: Video) {
        self.title = video.titleName ?? " "
        self.dateLabel.text = video.date
        titleTextField.text = self.title
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing == false {
            self.titleTextField.endEditing(true)
            self.titleTextField.isUserInteractionEnabled = false
        }
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.title = textField.text!
    }
}
