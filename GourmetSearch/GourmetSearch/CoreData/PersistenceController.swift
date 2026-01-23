//
//  PersistenceController.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/22.
//

import CoreData
import Foundation

/// CoreDataスタックを管理するクラス
/// NSPersistentContainer の生成・設定を担当する
struct PersistenceController {
    
    /// アプリ全体で共有するシングルトン
    static let shared = PersistenceController()
    
    /// CoreDataのコンテナ
    let container: NSPersistentContainer
    
    /// 初期化
    /// - Parameter inMemory: テスト用にメモリ上のみで動かすかどうか
    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "GourmetSearchModel")
        
        /// メモリ上のみで永続化する設定（UnitTest・Preview用）
        if inMemory {
            container.persistentStoreDescriptions.first?.url =
            URL(fileURLWithPath: "/dev/null")
        }
        
        /// 永続ストアの読み込み
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("❌ CoreData load error: \(error), \(error.userInfo)")
            }
        }
        
        /// 同一オブジェクト競合時は最新の変更を優先する
        container.viewContext.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy
        
        /// バックグラウンド更新を自動的に反映させる
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
