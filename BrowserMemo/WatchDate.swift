//
//  WatchDate.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/06/13.
//

import Foundation
import RealmSwift

class WatchDate :Object {
    @Persisted var pageName = ""
    @Persisted var URL = ""
    @Persisted var watchDate = ""
}
