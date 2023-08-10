//
//  DetailTagViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class DetailTagViewController: UIViewController {

    var selectedTag: String?
    var tagsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedTag)
        self.navigationItem.title = selectedTag

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
