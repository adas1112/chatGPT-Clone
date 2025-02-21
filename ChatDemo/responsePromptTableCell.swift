//
//  responsePromptTableCell.swift
//  ChatDemo
//
//  Created by Bilal on 03/01/25.
//

import UIKit

class responsePromptTableCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var responseView: UIView!
    @IBOutlet weak var responseTxtViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    func adjustTextViewHeight() {
        // Update the height for the responseTextView
        let responseSize = responseTextView.sizeThatFits(CGSize(width: responseTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        responseTxtViewHeight.constant = responseSize.height
        
        contentView.layoutIfNeeded()
    }

}
