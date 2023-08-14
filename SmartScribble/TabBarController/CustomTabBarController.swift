//
//  CustomTabBarController.swift
//  SmartScribble
//
//  Created by Moritz on 11.08.23.
//
import UIKit

class CustomTabBarController: UITabBarController, UIGestureRecognizerDelegate {
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    // MARK: - Setup Methods
    private func setupGestureRecognizers() {
        setupSwipeGesture(direction: .left, action: #selector(handleSwipes(_:)))
        setupSwipeGesture(direction: .right, action: #selector(handleSwipes(_:)))
        setupSwipeGesture(direction: .down, action: #selector(handleSwipeDown(_:)), delegate: self)
    }
    
    private func setupSwipeGesture(direction: UISwipeGestureRecognizer.Direction, action: Selector, delegate: UIGestureRecognizerDelegate? = nil) {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: action)
        swipeGesture.delegate = delegate
        swipeGesture.direction = direction
        view.addGestureRecognizer(swipeGesture)
    }
    
    // MARK: - Swipe Gesture Handlers
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        guard let currentViewController = selectedViewController as? UINavigationController else { return }
        
        var allowSwipe = false
        
        if let notesController = currentViewController.topViewController as? NotesCollectionViewController, notesController.notesCollectionView.contentOffset.y <= 0 {
            allowSwipe = true
        } else if let tagsController = currentViewController.topViewController as? TagsViewController, tagsController.tableView.contentOffset.y <= 0 {
            allowSwipe = true
        } else if let detailTagController = currentViewController.topViewController as? DetailTagViewController, detailTagController.notesTableView.contentOffset.y <= 0 {
            allowSwipe = true
        }

        if allowSwipe {
            presentNewNoteViewController()
        }
    }
    
    @objc private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .left && selectedIndex < (tabBar.items?.count ?? 0) - 1 {
            animateToTab(to: selectedIndex + 1)
        } else if sender.direction == .right && selectedIndex > 0 {
            animateToTab(to: selectedIndex - 1)
        }
    }
    
    // MARK: - Other Utility Methods
    private func presentNewNoteViewController() {
        if let newNoteVC = storyboard?.instantiateViewController(withIdentifier: "newNoteVC") as? NewNoteViewController {
            newNoteVC.modalPresentationStyle = .pageSheet
            present(newNoteVC, animated: true, completion: nil)
        }
    }

    private func animateToTab(to newIndex: Int) {
        guard let tabViewControllers = viewControllers, let fromView = selectedViewController?.view, let toView = tabViewControllers[newIndex].view else { return }
        
        let fromIndex = viewControllers?.firstIndex(of: selectedViewController!)
        guard let startIndex = fromIndex, startIndex != newIndex else { return }
        
        let offset = (newIndex > startIndex ? view.bounds.width : -view.bounds.width)
        performAnimation(fromView: fromView, toView: toView, offset: offset) {
            fromView.removeFromSuperview()
            self.selectedIndex = newIndex
        }
    }

    private func performAnimation(fromView: UIView, toView: UIView, offset: CGFloat, completion: @escaping () -> Void) {
        toView.center = CGPoint(x: fromView.center.x + offset, y: fromView.center.y)
        fromView.superview?.addSubview(toView)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
            toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
        }) { _ in
            completion()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
