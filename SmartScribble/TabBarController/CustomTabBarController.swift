//
//  CustomTabBarController.swift
//  SmartScribble
//
//  Created by Moritz on 11.08.23.
//

import UIKit

class CustomTabBarController: UITabBarController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.delegate = self
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        guard let currentViewController = selectedViewController else { return }

        var allowSwipe = false

        if let navigationController = currentViewController as? UINavigationController,
           let topController = navigationController.topViewController {

            if let notesController = topController as? NotesCollectionViewController,
               notesController.notesCollectionView.contentOffset.y <= 0 {
                allowSwipe = true
            } else if let tagsController = topController as? TagsViewController,
                      tagsController.tableView.contentOffset.y <= 0 {
                allowSwipe = true
            } else if let detailTagController = topController as? DetailTagViewController,
                      detailTagController.notesTableView.contentOffset.y <= 0 {
                allowSwipe = true
            }
        }

        if allowSwipe {
            if let newNoteVC = self.storyboard?.instantiateViewController(withIdentifier: "newNoteVC") as? NewNoteViewController {
                newNoteVC.modalPresentationStyle = .pageSheet // Hier haben wir den Stil geändert
                self.present(newNoteVC, animated: true, completion: nil)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }


    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        
        guard let currentNavigationController = selectedViewController as? UINavigationController else { return }
            
            let currentViewController = currentNavigationController.topViewController
        
        print(currentViewController!)
        

            // Prüfen Sie, ob der aktuelle ViewController der Typ ist, den Sie erlauben wollen
        if !(currentViewController is NotesCollectionViewController) && !(currentViewController is TagsViewController) {
            return
        }
        
        if sender.direction == .left {
            if self.selectedIndex < (self.tabBar.items?.count ?? 0) - 1 {
                animateToTab(to: self.selectedIndex + 1)
            }
        }

        if sender.direction == .right {
            if self.selectedIndex > 0 {
                animateToTab(to: self.selectedIndex - 1)
            }
        }
    }

    
    func animateToTab(to newIndex: Int) {
        guard let tabViewControllers = viewControllers,
              let fromView = selectedViewController?.view,
              let toView = tabViewControllers[newIndex].view,
              let fromIndex = viewControllers?.firstIndex(of: selectedViewController!),
              fromIndex != newIndex else { return }

        // Position, wo die Animation beginnt (entweder links oder rechts)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = newIndex > fromIndex
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: fromView.center.y)

        // Fügen Sie die zu zeigende Ansicht dem Container hinzu
        fromView.superview?.addSubview(toView)

        // Animationsblock
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y)

        }, completion: { finished in
            if finished {
                fromView.removeFromSuperview()
                self.selectedIndex = newIndex
            }
        })
    }
}
