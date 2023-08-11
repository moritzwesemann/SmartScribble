// NoteCollectionViewCell.swift
// SmartScribble
// Created by Moritz on 10.08.23.

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // Formatieren des Titel-Labels
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textColor = .black
            
            // Formatieren des Text-Labels
            contentTextField.font = UIFont.systemFont(ofSize: 14)
            contentTextField.textColor = .darkGray
            
            // Formatieren des Tags-Labels
            tagsLabel.font = UIFont.systemFont(ofSize: 12)
            tagsLabel.textColor = .black
        }
    
}
