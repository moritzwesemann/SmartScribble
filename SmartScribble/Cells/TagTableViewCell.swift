//
//  TagTableViewCell.swift
//  SmartScribble
//
//  Created by Moritz Wesemann on 13.08.23.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        styleCell()
    }
    
    private func styleCell() {
        // Hintergrundfarbe des Containers
        containerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Ein leicht grauer Farbton
        
        // Textformatierung
        tagLabel.font = UIFont.boldSystemFont(ofSize: 20)
        tagLabel.textColor = .black
        
        // Container-View-Styling
        containerView.layer.cornerRadius = 8
        
        // Schatten
        containerView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.1).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 4.0
    }
}
