//
//  HistoryViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/06/13.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    let realm = try! Realm()
    
    var countRecord: Int!
    
    var objects: Results<WatchDate>!
    
    let maxRow: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Tableviewの構成や振る舞い(高さやタップ時の処理など)に影響する
        tableView.delegate = self
        // Tableviewのデータに関する内容(何行あるか、何を代入するか)に影響する
        tableView.dataSource = self

        
    }
    
    // ビューが現れる前に処理する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 挙動観測のための一文
        print("table viewWillAppear")
        
        // realm内のテーブルを取り出して、メンバ変数への格納と件数を取得する(日付が新しい順番で取得する)
        objects = realm.objects(WatchDate.self).sorted(byKeyPath: "watchDate", ascending: false)
        countRecord = objects.count
        print("全てのデータ(viewWillAppear時)\(objects)")
        
        // リストビューを再読込する
        tableView.reloadData()
        
    }
    
    // TableViewに表示するテーブル行の数(ここでは配列の個数を参照している)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if countRecord < maxRow {
            return countRecord
        }
        return maxRow
    }
    
    // テーブル行分のデータをセルに当てはめる
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに表示するのは配列の中身で、indexPath.rowを要素数にして引き出した値をCellに当てはめている
        // Cellは入れ物で、配列とindexPathが紐付いているので、選択時のindexPath.rowがわかれば、そのデータが取れる
        cell.textLabel?.text = objects[indexPath.row].pageName
        cell.detailTextLabel?.text = objects[indexPath.row].watchDate
        
        return cell
    }
    
    // リストをタップすることで、詳細画面へ遷移する処理
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タブバーコントロール内の一番左のビューに遷移するため、[0]のビューを示し、ナビゲーションコントローラとしてキャストする
        if let nextVC = tabBarController?.viewControllers?[0] as? UINavigationController {
            // そこの最初のスタック(スタック内の一番最後にある部分を示している?)が遷移したいビューコントローラクラスなら、値を入れる
            if let topVC = nextVC.topViewController as? ViewController {
                topVC.receiveUrl = objects[indexPath.row].URL
                tabBarController?.selectedViewController = nextVC
            }
        }
    }

}
