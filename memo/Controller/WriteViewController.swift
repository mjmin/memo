//
//  WriteViewController.swift
//  memo
//
//  Created by Minji Kim on 2022/09/02.
//

import UIKit
import RealmSwift
//import UIActivity

class WriteViewController: UIViewController {

    let textView = UITextView().then {
        $0.font = .systemFont(ofSize: 15)
    }
    
    let backgroundColor : UIColor  = .black
    var objectId : ObjectId? = nil
    var memo : MemoItem?

    let contents : String? = nil
    let realmManager = RealmManager()
    let defaultText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setText()
        setupUI()
        setupNav()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveContents()
    }
    
    func setupNav () {
        navigationController?.navigationBar.tintColor = getPointColor(mode : self.traitCollection.userInterfaceStyle)
        navigationController?.navigationBar.prefersLargeTitles = false
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let shareBtn = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(showActivityView))
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(popView))
        self.navigationItem.rightBarButtonItems = [saveBtn, shareBtn]
    }
    
    func setText () {
        if (objectId != nil){
            memo = realmManager.getMemoById(id: objectId!)
            textView.text = "\(memo?.title! ?? defaultText)\n\(memo?.contents! ?? defaultText)"
        }
    }
    func setupUI () {
        view.addSubview(textView)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.becomeFirstResponder()
        textView.textAlignment = .left
        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
        textView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    @objc func popView() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func saveContents () {
        
        let text = textView.text ?? ""
        if(text.isEmpty){
            if(objectId != nil){
                // ??????
                realmManager.deleteMemoItem(id: objectId!)
            }
            return
        }
        var splitedContents = text.split(separator: "\n")
        let itemTitle = splitedContents[0]
        splitedContents.remove(at: 0)
        if(objectId == nil){
            // ??????
            realmManager.addMemoItem(item: MemoItem(title: String(itemTitle), contents: splitedContents.joined(separator: "\n")))
        }
        else{
            // ??????
            realmManager.updateMemoItem(id: objectId!, title: String(itemTitle), contents: splitedContents.joined(separator: "\n"))
        }
    }
    
    @objc func showActivityView () {
        let textToShare: String = textView.text ?? ""
        // 1. UIActivityViewController ?????????, ?????? ????????? ??????  - TextToShare
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

        // 2. ???????????? ???????????? ????????? ??? ???????????? ?????? UIActivityType ??????(?????? ??????)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact]

        // 3. ??????????????? ?????? ??? ????????? ?????? ????????? ??????
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
            // ???????????? ??? ??????
           }  else  {
            // ???????????? ??? ??????
           }
        }
        // 4. ???????????? ????????????(iPad????????? ??? ?????????, iPhone??? iPod????????? ????????? ???????????????.)
        self.present(activityViewController, animated: true, completion: nil)
    }
    


}
