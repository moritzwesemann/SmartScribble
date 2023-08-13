//
//  NotesCollectionViewController.swift
//  SmartScribble
//
//  Created by Moritz on 10.08.23.
//

import UIKit

class NotesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    // MARK: - Properties
    var notes: [Note] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadNotes()
        registerForNoteNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
        notesCollectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
    }
    
    private func loadNotes() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes.sorted(by: { $0.lastEdited > $1.lastEdited })
        }
    }
    
    private func registerForNoteNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNoteAdded), name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    @objc private func handleNewNoteAdded() {
        loadNotes()
        notesCollectionView.reloadData()
    }
    
    private func extractHashtags(from text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "#(\\w+)", options: [])
            let results = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch let error {
            print("Fehler beim Extrahieren von Hashtags: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - UICollectionViewDataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = notesCollectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
        let note = notes[indexPath.row]
        
        cell.titleLabel.text = note.title
        cell.contentTextField.text = String(note.text.prefix(230))
        cell.tagsLabel.text = extractHashtags(from: note.text).joined(separator: " ")
        
        style(cell: cell)
        return cell
    }
    
    func style(cell: NoteCollectionViewCell) {
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 8.0
        cell.contentTextField.isUserInteractionEnabled = false
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteDetail", let destinationVC = segue.destination as? SingleNoteViewController, let indexPath = notesCollectionView.indexPathsForSelectedItems?.first {
            destinationVC.noteID = notes[indexPath.row].id
        }
    }
}
