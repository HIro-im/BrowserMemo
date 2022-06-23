//
//  TableViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/06/02.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let realm = try! Realm()

    // IDの個数でセルの個数を確保するための変数
    var countRecord: Int = 0
    
    // Realm<Memo>からテーブル全体を引き出した内容を確保するための変数
    var objects: Results<Memo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableviewの構成や振る舞い(高さやタップ時の処理など)に影響する
        tableView.delegate = self
        // Tableviewのデータに関する内容(何行あるか、何を代入するか)に影響する
        tableView.dataSource = self
        
//        print("全てのデータ(viewDidLoad時)\(objects)")

    }
    
    // ビューが現れる前に処理する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 挙動観測のための一文
        print("table viewWillAppear")
        
        // realm内のテーブルを取り出して、メンバ変数への格納と件数を取得する
        memoObjects()
        print("全てのデータ(viewWillAppear時)\(objects)")
        
        // リストビューを再読込する
        tableView.reloadData()
        
    }
    
    
    // 挙動観測のため
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("table viewDidAppear")
    }

    // 挙動観測のため
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("table viewWillDisappear")
    }

    // 挙動観測のため
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("table viewDidDisappear")
    }
    
    // realm内のテーブルを取り出して、メンバ変数への格納と件数を取得するメソッド(重複するのでメソッド化)
    func memoObjects() {
        objects = realm.objects(Memo.self)
        countRecord = objects.count
    }
    
    // TableViewに表示するテーブル行の数(ここでは配列の個数を参照している)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countRecord
    }
    
    // テーブル行分のデータをセルに当てはめる
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに表示するのは配列の中身で、indexPath.rowを要素数にして引き出した値をCellに当てはめている
        // Cellは入れ物で、配列とindexPathが紐付いているので、選択時のindexPath.rowがわかれば、そのデータが取れる
        cell.textLabel?.text = objects[indexPath.row].pageName
        
        return cell
    }
    
    // リストをタップすることで、詳細画面へ遷移する処理
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 遷移先のビューコントローラのインスタンスを用意する
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MemoView") as? MemoViewController {
            
            // リストからタップされたIDを渡す
            vc.receivedId = objects[indexPath.row].id
            
            vc.openMode = switchOpenMode.forReference.rawValue
            
            // 遷移を実行させる(階層をつなげた遷移(=ナビゲーションバーのbackが使える)を実現したいのでpushする
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
