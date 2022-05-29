//
//  Memo.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/05/29.
//

import Foundation
import RealmSwift

// メモの格納内容
class Memo: Object {
    @Persisted(primaryKey: true)var id = 0
    @Persisted var pageName = ""
    @Persisted var URL = ""
    @Persisted var memo = ""
}
