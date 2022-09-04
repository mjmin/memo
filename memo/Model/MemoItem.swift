//
//  MemoItem.swift
//  memo
//
//  Created by Minji Kim on 2022/09/01.
//

import Foundation
import RealmSwift

class MemoItem : Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String?
    @Persisted var contents: String?
    @Persisted var dateInserted: Date?
    @Persisted var dateUpdated: Date?
    @Persisted var picked : Bool = false
    
    convenience init(title: String, contents : String) {
        self.init()
        self.title = title
        self.contents = contents
        dateInserted = Date()
        dateUpdated = Date()
        picked = false
    }
    

    func getDateFormat (date : Date) -> String {
        let dateFormatter = DateFormatter()
        if(Calendar.current.isDateInToday(date)){
            dateFormatter.dateFormat = "aa hh:mm"
        }else if(Calendar.current.isDateInWeekend(date)) {
            dateFormatter.dateFormat = "EEEE"
        }else {
            dateFormatter.dateFormat = "YYYY.MM.DD aa hh:mm"
        }
        return dateFormatter.string(from: date)
        
    }
    
}
