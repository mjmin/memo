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
                // 삭제
                realmManager.deleteMemoItem(id: objectId!)
            }
            return
        }
        var splitedContents = text.split(separator: "\n")
        let itemTitle = splitedContents[0]
        splitedContents.remove(at: 0)
        if(objectId == nil){
            // 작성
            realmManager.addMemoItem(item: MemoItem(title: String(itemTitle), contents: splitedContents.joined(separator: "\n")))
        }
        else{
            // 수정
            realmManager.updateMemoItem(id: objectId!, title: String(itemTitle), contents: splitedContents.joined(separator: "\n"))
        }
    }
    
    @objc func showActivityView () {
        let textToShare: String = textView.text ?? ""
        // 1. UIActivityViewController 초기화, 공유 아이템 지정  - TextToShare
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

        // 2. 기본으로 제공되는 서비스 중 사용하지 않을 UIActivityType 제거(선택 사항)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact]

        // 3. 컨트롤러를 닫은 후 실행할 완료 핸들러 지정
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
            // 성공했을 때 작업
           }  else  {
            // 실패했을 때 작업
           }
        }
        // 4. 컨트롤러 나타내기(iPad에서는 팝 오버로, iPhone과 iPod에서는 모달로 나타냅니다.)
        self.present(activityViewController, animated: true, completion: nil)
    }
    


}
