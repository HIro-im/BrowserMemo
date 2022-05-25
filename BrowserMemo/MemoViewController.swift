//
//  MemoViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/05/26.
//

import UIKit

class MemoViewController: UIViewController {
    
    
    
    // 遷移元を識別するための情報
    var previewName: Int?
    
    // webビューから値を受け取るための変数
    var nameFromWebView: String?
    var urlFromWebView: String?
    
    // 保存ボタンの処理を切り替えるための変数
    var saveProcess: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
