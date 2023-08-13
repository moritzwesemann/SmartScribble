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
        
        configureTitleLabel()
        configureContentTextField()
        configureTagsLabel()
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
    }
    
    private func configureContentTextField() {
        contentTextField.font = UIFont.systemFont(ofSize: 14)
        contentTextField.textColor = .darkGray
    }
    
    private func configureTagsLabel() {
        tagsLabel.font = UIFont.systemFont(ofSize: 12)
        tagsLabel.textColor = .black
    }
}
