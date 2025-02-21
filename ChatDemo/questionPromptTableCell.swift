//
//  questionPromptTableCell.swift
//  ChatDemo
//
//  Created by Bilal on 03/01/25.
//

import UIKit

class questionPromptTableCell: UITableViewCell {
    
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionTextView.isScrollEnabled = false
           questionTextView.textContainer.lineFragmentPadding = 0
           questionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // Ensure that these constraints are defined in your cell's layout

       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        questionTextView.sizeToFit()
        questionTextView.isScrollEnabled = false
    }


}
