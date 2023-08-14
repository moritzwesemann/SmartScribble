//  DetailTagViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

import UIKit

class DetailTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var detailTagCollectionView: UICollectionView!

    // MARK: - Properties
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    var selectedTag = ""
    
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
        detailTagCollectionView.reloadData()
        print(selectedTag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        detailTagCollectionView.delegate = self
        detailTagCollectionView.dataSource = self
    }
    
    private func loadNotes() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes.sorted(by: { $0.lastEdited > $1.lastEdited })
            
            if selectedTag == "Sonstiges" {
                filteredNotes = notes.filter { $0.tags.isEmpty }
            } else {
                filteredNotes = notes.filter { $0.tags.contains(selectedTag) }
            }
        }
    }

    
    private func registerForNoteNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNoteAdded), name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    @objc private func handleNewNoteAdded() {
        loadNotes()
        detailTagCollectionView.reloadData()
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
    
    private func removeHashtags(from text: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "#(\\w+)", options: [])
            let modifiedText = regex.stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: "")
            return modifiedText
        } catch let error {
            print("Fehler beim Entfernen von Hashtags: \(error.localizedDescription)")
            return text
        }
    }
    
    // MARK: - UICollectionViewDataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailTagCollectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
        let note = filteredNotes[indexPath.row]
            
        cell.titleLabel.text = note.title
            
        let textWithoutHashtags = removeHashtags(from: note.text)
        cell.contentTextField.text = String(textWithoutHashtags.prefix(230))
            
        cell.tagsLabel.text = extractHashtags(from: note.text).joined(separator: " ")
            
        style(cell: cell)
        return cell
    }
    
    func style(cell: NoteCollectionViewCell) {
        // Hintergrundfarbe der Zelle
        cell.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Ein leicht grauer Farbton

        // Textformatierung
        cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.titleLabel.textColor = .black
        cell.contentTextField.font = UIFont.systemFont(ofSize: 16)
        cell.contentTextField.textColor = .darkGray
        cell.tagsLabel.font = UIFont.systemFont(ofSize: 14)
        cell.tagsLabel.textColor = .lightGray
        
        // Eckenradius
        cell.layer.cornerRadius = 8.0
        
        // Schatten
        cell.layer.shadowColor = UIColor(white: 0.0, alpha: 0.1).cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 4.0

        // Entfernen Sie den Rand
        cell.layer.borderWidth = 0.0
        
        // Deaktivieren Sie die Interaktion mit dem Textfeld
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
        if segue.identifier == "showNoteDetail",
           let destinationVC = segue.destination as? SingleNoteViewController,
           let indexPath = detailTagCollectionView.indexPathsForSelectedItems?.first {
            destinationVC.noteID = filteredNotes[indexPath.row].id
        }
    }
}
