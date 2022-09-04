//
//  RealManager.swift
//  memo
//
//  Created by Minji Kim on 2022/09/01.
//


import Foundation
import RealmSwift
import Then

class RealmManager {
    
    var localRealm : Realm
    
    init() {
        var config = Realm.Configuration(schemaVersion: 2)
        config.deleteRealmIfMigrationNeeded = true
        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config
        localRealm = try! Realm()
    }
        
    func getMemoList (picked : Bool = false) -> Results<MemoItem> {
        return localRealm.objects(MemoItem.self).where {
            $0.picked == picked
        }.sorted(byKeyPath: "dateUpdated", ascending: false)
    }
    
    func getSearchMemoList(search : String, picked : Bool = false) -> Results<MemoItem> {
        return localRealm.objects(MemoItem.self).where {
            ($0.contents.contains(search, options: .caseInsensitive)
             || $0.title.contains(search, options: .caseInsensitive)) && $0.picked == picked
        }.sorted(byKeyPath: "dateUpdated", ascending: false)
    }
    
    func getMemoById(id : ObjectId) -> MemoItem {
        return localRealm.object(ofType: MemoItem.self, forPrimaryKey: id)!
    }
    
    
    func hasFixedOne () -> Bool{
        return getMemoList().count>0
    }
    
    func addMemoItem(item : MemoItem) {
        try! localRealm.write {
            localRealm.add(item)
        }
    }
    
    func updateMemoItem(id: ObjectId, title: String, contents: String) {
        let item = getMemoById(id: id)
        try! localRealm.write {
            item.title = title
            item.contents = contents
            item.dateUpdated = Date()
        }
    }
    
    func toggleFixedStatus(id: ObjectId) {
        let item = getMemoById(id: id)
        try! localRealm.write {
            item.picked = !item.picked
        }
    }
    
    func deleteMemoItem (id: ObjectId){
        let item = getMemoById(id: id)
        try! localRealm.write {
            localRealm.delete(item)
        }
    }
    
}
