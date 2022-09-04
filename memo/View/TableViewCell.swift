//
//  TableViewCell.swift
//  memo
//
//  Created by Minji Kim on 2022/09/01.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var memo : MemoItem? {
        didSet {
            guard let memo = memo else {
                return
            }
            titleLabel.text = memo.title
            dateLabel.text = memo.getDateFormat(date: memo.dateUpdated!)
            guard let contents = memo.contents, !contents.isEmpty else{
                contentsLabel.text = "추가 컨텐츠 없음"
                return
            }
            contentsLabel.text = contents
            setContentsViewWidth()
        }
    }
    
    let titleLabel = UILabel ().then {
        $0.font = .boldSystemFont(ofSize: 13)
    }
    
    let dateLabel = UILabel().then{
        $0.font = .systemFont(ofSize: 13)
    }
    
    let contentsLabel = UILabel ().then {
        $0.font = .systemFont(ofSize: 13)
    }
    
    let contentsStackView = UIStackView().then{
        $0.spacing = 5
        $0.alignment = .leading
        $0.distribution = .fill
        $0.axis = .horizontal
    }
    
    let stackView = UIStackView().then{
        $0.spacing = 10
        $0.alignment = .leading
        $0.distribution = .fill
        $0.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupStackView()
        setConstraints()
    }
    
    func setupStackView(){
        
        self.contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentsStackView)
        
        contentsStackView.addArrangedSubview(dateLabel)
        contentsStackView.addArrangedSubview(contentsLabel)
    }
    
    func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView).inset(15)
        }
    }
    
    func setContentsViewWidth() {
        dateLabel.sizeToFit()
        contentsLabel.sizeToFit()
        let contentWidth = self.contentView.frame.width - contentsStackView.spacing - dateLabel.frame.width
        contentsLabel.snp.makeConstraints { make in
            make.width.equalTo(contentWidth).priority(98)
        }

//        print(titleLabel.text!, dateLabel.frame.width, self.contentView.frame.width , contentWidth)
        let width = dateLabel.frame.width + contentsLabel.frame.width + contentsStackView.spacing
        contentsStackView.snp.makeConstraints { make in
            make.width.equalTo(width).priority(99)
        }
    }
    
}
