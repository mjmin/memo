
//  ViewController.swift
//  memo
//
//  Created by Minji Kim on 2022/09/01.
//

import UIKit
import RealmSwift
import SnapKit

final class ViewController: UIViewController {
    
    var tableView : UITableView?
    var realmManager = RealmManager()
    let searchController = UISearchController()
    let addBtn = UIButton().then {
        let image = UIImage(systemName: "square.and.pencil")
        $0.setImage(image, for: .normal)
    }
    var pointColor : UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        pointColor = getPointColor(mode : self.traitCollection.userInterfaceStyle)
        setupTableView()
        setupAddBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
    
    func reloadView(){
        tableView?.reloadData()
        setupNav()
    }
    
    func loadTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let memoCount = realmManager.getMemoList().count + realmManager.getMemoList(picked: true).count
        title = "\(numberFormatter.string(for: memoCount)!)개의 메모"
    }
    
    
    func setupTableView(){
        let barHeight: CGFloat = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight), style: .insetGrouped).then {
            $0.sectionIndexColor = .orange
        }
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        tableView?.register(TableViewCell.self, forCellReuseIdentifier: "memoCell")
        //        tableView?.keyboardDismissMode = .onDrag
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    func setupNav() {
        
        // (네비게이션바 설정관련) iOS버전 업데이트 되면서 바뀐 설정⭐️⭐️⭐️
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명으로
        //appearance.backgroundColor = .brown     // 색상설정
        
        //appearance.configureWithTransparentBackground()  // 투명으로
        navigationController?.navigationBar.standardAppearance = appearance
        //        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        loadTitle()
        
        
        searchController.searchBar.placeholder =  "검색"
        searchController.searchBar.tintColor = pointColor
        // 내비게이션 바는 항상 표출되도록 설정
        searchController.hidesNavigationBarDuringPresentation = false
        // updateSearchResults(for:) 델리게이트를 사용을 위한 델리게이트 할당
        //        searchController.searchResultsUpdater = self
        // 뒷배경이 흐려지지 않도록 설정
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupAddBtn(){
        view.addSubview(addBtn)
        addBtn.tintColor = pointColor
        addBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).inset(15)
            make.trailing.equalTo(view.snp.trailing).inset(15)
            make.width.height.equalTo(70)
        }
        addBtn.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    
    @objc func addBtnTapped(){
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.window?.endEditing(true)
        super.touchesEnded(touches, with: event)
        print(#function)
    }
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let searchText = searchController.searchBar.text!
        if hasFixedSection(section) {
            return searchBarIsEmpty() ? realmManager.getMemoList(picked: true).count : realmManager.getSearchMemoList(search: searchText, picked: true).count
        }else {
            return searchBarIsEmpty() ? realmManager.getMemoList().count : realmManager.getSearchMemoList(search: searchText).count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as! TableViewCell
        let searchText = searchController.searchBar.text!;
        let list : Results<MemoItem> = hasFixedSection(indexPath.section) ? searchBarIsEmpty() ? realmManager.getMemoList(picked: true) : realmManager.getSearchMemoList(search: searchText, picked: true) : searchBarIsEmpty() ? realmManager.getMemoList() : realmManager.getSearchMemoList(search: searchText)
        let memoItem = list[indexPath.row]
        cell.memo = memoItem
        cell.selectionStyle = .none
        
        if(!searchBarIsEmpty()){
            changeSearchTextColor(cell: cell)
        }
        
        return cell
    }
    
    func changeSearchTextColor(cell : TableViewCell) {
        let searchText = searchController.searchBar.text!
        let titleText = cell.titleLabel.text!
        let contentsText = cell.contentsLabel.text ?? ""
        
        let titleRange = (titleText as NSString).range(of: searchText, options: .caseInsensitive)
        let attributedText = NSMutableAttributedString.init(string: titleText)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: pointColor!, range: titleRange)
        cell.titleLabel.attributedText = attributedText
        
        let contentsRange = (contentsText as NSString).range(of: searchText, options: .caseInsensitive)
        let attributedText2 = NSMutableAttributedString.init(string: contentsText)
        attributedText2.addAttribute(NSAttributedString.Key.foregroundColor, value: pointColor!, range: contentsRange)
        cell.contentsLabel.attributedText = attributedText2
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle : String
        if searchBarIsEmpty() {
            sectionTitle = hasFixedSection(section) ? "고정된 메모" : "메모"
        }else {
            let searchText = searchController.searchBar.text!
            
            sectionTitle = hasFixedSection(section) ? "고정된 메모: \(realmManager.getSearchMemoList(search: searchText, picked: true).count)개 찾음" : "메모: \(realmManager.getSearchMemoList(search: searchText).count)개 찾음"
        }
        
        return sectionTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return realmManager.hasFixedOne() ? 2 : 1
    }
    
    func hasFixedSection (_ section : Int) -> Bool {
        return  tableView!.numberOfSections > 1 && section == 0
    }
}


extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell
        let vc = WriteViewController()
        vc.objectId = currentCell.memo?._id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell
        
        let fix = UIContextualAction(style: .normal, title: "고정", handler: { action, view, completionHaldler in
            self.realmManager.toggleFixedStatus(id: currentCell.memo!._id)
            self.reloadView()
            completionHaldler(true)
        })
        fix.backgroundColor = pointColor
        // 아이콘설정
        if hasFixedSection(indexPath.section){
            // 고정해제
            fix.image = UIImage(systemName: "pin.slash.fill")
        }else{
            // 고정
            fix.image = UIImage(systemName: "pin.fill")
        }
        return UISwipeActionsConfiguration(actions: [fix])
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell
        // 삭제
        let trash = UIContextualAction(style: .destructive, title: "삭제", handler: { action, view, completionHaldler in
            
            let alert = UIAlertController(title: "메모 삭제", message: "메모를 삭제하시겠습니까?", preferredStyle: .alert)
            let success = UIAlertAction(title: "확인", style: .default) { action in
                self.realmManager.deleteMemoItem(id: currentCell.memo!._id)
                self.reloadView()
                completionHaldler(true)
            }
            let cancel = UIAlertAction(title: "취소", style: .default) { action in
                completionHaldler(true)
            }
            alert.addAction(success)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        })
        trash.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [trash])
    }
    
    
    
}
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadView()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
}
