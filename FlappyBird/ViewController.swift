//
//  ViewController.swift
//  FlappyBird
//
//  Created by 三村文子 on 2020/02/12.
//  Copyright © 2020 三村文子. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // SKViewに型を変換する
        let skView = self.view as! SKView
      
        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
       }
        // Do any additional setup after loading the view.
        
   //ステータスバーを消す
    override var prefersStatusBarHidden: Bool   {
        get {
            return true
        }
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


