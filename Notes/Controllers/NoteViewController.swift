//
//  NoteViewController.swift
//  NOTES
//
//  Created by Дмитрий Корчагин on 31.01.2023.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    var activityViewController: UIActivityViewController? = nil
    var scrollView = UIScrollView()
    var textView = UITextView()
    let options = UIBarButtonItem()
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    private func setUpViews(){
        
        if selectedNote == nil{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            selectedNote = Note(entity: entity!, insertInto: context)
            selectedNote?.name = "New Note"
            selectedNote?.details = ""
        }
        title = selectedNote?.name
        textView.text = selectedNote?.details
        
        view.backgroundColor = res.colors.background
        let barButtonMenu = UIMenu(
            title: "", children: [
                UIAction(title: NSLocalizedString("Copy", comment: ""), image: res.images.image(named: "copy"), handler: copy),
                UIAction(title: NSLocalizedString("Rename", comment: ""), image: res.images.image(named: "rename"), handler: rename),
                UIAction(title: NSLocalizedString("Duplicate", comment: ""), image: res.images.image(named: "duplicate") , handler: duplicate),
                UIAction(title: NSLocalizedString("Delete", comment: ""), image: res.images.image(named: "delete"), handler: delete),
                UIAction(title: NSLocalizedString("Share", comment: ""), image: res.images.image(named: "share"), handler: share)
        ])
        options.image = res.images.image(named: "options")
        navigationItem.rightBarButtonItem = options
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        options.menu = barButtonMenu
        createScrollView()
        menuHandler()
    }
    @objc func back(){
        saveData(needBack: true)
    }
    
    private func saveData(needBack f: Bool){
        if isNewNote { createNewNote(needBack: f) }
        updateSelectedNoteData(needBack: f)
        isNewNote = false
    }
    private func updateSelectedNoteData(needBack f: Bool){
        selectedNote?.name = title
        selectedNote?.details = textView.text
        if f { self.navigationController?.popViewController(animated: true) }
    }
    private func createNewNote(needBack f: Bool){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
        let newNote = Note(entity: entity!, insertInto: context)
        
        newNote.id = noteList.count as NSNumber
        newNote.name = title
        newNote.details = textView.text
        
        do{
            try context.save()
            noteList.append(newNote)
            if f { self.navigationController?.popViewController(animated: true) }
        } catch {
            print("can't save data")
        }
    }
    
    private func copy(action: UIAction) {
        saveData(needBack: false)
        let pBoard = UIPasteboard.general
        pBoard.string = (selectedNote?.name ?? "") + "\n" + (selectedNote?.details ?? "")
    }
    private func rename(action: UIAction) {
        saveData(needBack: false)
        showInputDialog(title: "Rename",
                        subtitle: "Enter a new title",
                        actionTitle: "Enter",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "New note",
                        inputKeyboardType: .default,
                        actionHandler: { (input:String?) in self.title = input ?? "" })
    }
    private func duplicate(action: UIAction) {
        saveData(needBack: false)
        let alertController = UIAlertController(title: "", message: "A copy has been created", preferredStyle: .alert)
        alertController.setValue(
            NSAttributedString(
                string: alertController.message!,
                attributes: [NSAttributedString.Key.font: res.fonts.font(named: "regular", 23)!,
                                NSAttributedString.Key.foregroundColor: UIColor.black]),
            forKey: "attributedMessage")

        let actionOk = UIAlertAction(title: "Okey", style: .default) { (action) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            newNote.id = noteList.count as NSNumber
            newNote.name = (self.selectedNote?.name ?? "" ) + " copy"
            newNote.details = self.selectedNote?.details
            do{
                try context.save()
                noteList.append(newNote)
            } catch {
                print("erroe save duplicate note")
            }
        }
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    private func delete(action: UIAction){
        saveData(needBack: false)
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .alert)
        alertController.setValue(
            NSAttributedString(
                string: alertController.title!,
                attributes: [NSAttributedString.Key.font: res.fonts.font(named: "regular", 23)!,
                                NSAttributedString.Key.foregroundColor: UIColor.black]),
            forKey: "attributedTitle")

        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive) {
            (action) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    if (note == self.selectedNote) {
                        note.deletedDate = Date()
                        try context.save()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch {
                print("Fetch Failed")
            }
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionDelete)
        self.present(alertController, animated: true, completion: nil)
    }
    private func share(action: UIAction){
        saveData(needBack: false)
        self.activityViewController = UIActivityViewController(activityItems: [(selectedNote?.name ?? "") + "\n" + (selectedNote?.details ?? "")], applicationActivities: nil)
        self.present(self.activityViewController!, animated: true)
    }
    
    fileprivate func createScrollView(){
        view.addSubview(scrollView)
        view.addSubview(textView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = res.colors.background
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = res.fonts.font(named: "regular", 23)
        textView.backgroundColor = res.colors.background
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -7),
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 7),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
    }
    
    fileprivate func menuHandler() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: UITextView.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: UITextView.keyboardWillHideNotification, object: nil)
    }
    @objc func updateText(_ sender: Notification){
            
        let userInfo = sender.userInfo
        let getKeyboardRect = (userInfo! [UIResponder.keyboardFrameEndUserInfoKey] as! NSValue ).cgRectValue
        let keyboardFrame = self.view.convert(getKeyboardRect, to: view.window)
        
        if sender.name == UITextView.keyboardWillHideNotification{
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
        
    }
    fileprivate func showInputDialog(title:String? = nil,
                            subtitle:String? = nil,
                            actionTitle:String? = "",
                            cancelTitle:String? = "",
                            inputPlaceholder:String? = nil,
                            inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                            cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                            actionHandler: ((_ text: String?) -> Void)? = nil) {
           
           let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
           alert.addTextField { (textField:UITextField) in
               textField.placeholder = inputPlaceholder
               textField.keyboardType = inputKeyboardType
           }
           alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
               guard let textField =  alert.textFields?.first else {
                   actionHandler?(nil)
                   return
               }
               actionHandler?(textField.text)
           }))
           alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
           
           self.present(alert, animated: true, completion: nil)
       }
}

