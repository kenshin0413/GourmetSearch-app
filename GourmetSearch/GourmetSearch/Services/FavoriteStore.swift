//
//  FavoriteStore.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/22.
//

import CoreData
import Foundation

// MARK: - お気に入り店舗管理

/// CoreData を利用して永続化・読み込み・追加・削除を行う
@MainActor
final class FavoriteStore: ObservableObject {
    
    // MARK: - 公開プロパティ
    
    /// 画面が監視するお気に入り店舗一覧
    /// 変更されるとUIが自動的に更新される
    @Published private(set) var favorites: [Shop] = []
    
    // MARK: - 内部プロパティ
    
    /// CoreData の操作に使用するコンテキスト
    private let context: NSManagedObjectContext
    
    // MARK: - 初期化
    
    /// 初期化時に CoreData からお気に入りを読み込む
    init(context: NSManagedObjectContext) {
        self.context = context
        loadFavorites()
    }
    
    // MARK: - 読み込み処理
    
    /// CoreData からお気に入り店舗を取得する
    /// 作成日時の降順で並び替える
    func loadFavorites() {
        let request = FavoriteShopEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            let entities = try context.fetch(request)
            
            /// Entity → Shop に変換して保持する
            favorites = entities.compactMap { Shop(entity: $0) }
        } catch {
            print("❌ Favorite fetch error:", error.localizedDescription)
            favorites = []
        }
    }
    
    // MARK: - 状態判定
    
    /// 指定した店舗IDがお気に入りに登録されているか判定する
    func isFavorite(id: String) -> Bool {
        favorites.contains { $0.id == id }
    }
    
    // MARK: - 追加・削除処理
    
    /// お気に入りに店舗を追加する
    func add(_ shop: Shop) {
        /// すでに登録済みの場合は何もしない
        guard !isFavorite(id: shop.id) else { return }
        
        let entity = FavoriteShopEntity(context: context)
        shop.apply(to: entity)
        entity.createdAt = Date()
        
        saveAndReload()
    }
    
    /// 指定したIDの店舗をお気に入りから削除する
    func remove(id: String) {
        let request = FavoriteShopEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            if let entity = result.first {
                context.delete(entity)
                saveAndReload()
            }
        } catch {
            print("❌ Favorite delete error:", error.localizedDescription)
        }
    }
    
    /// IndexSet を指定して複数件削除する
    func remove(at offsets: IndexSet) {
        let ids = offsets.compactMap { index in
            favorites.indices.contains(index) ? favorites[index].id : nil
        }
        ids.forEach { remove(id: $0) }
    }
    
    // MARK: - 保存処理
    
    /// CoreData に保存し、再読み込みする
    private func saveAndReload() {
        do {
            if context.hasChanges {
                try context.save()
            }
            loadFavorites()
        } catch {
            print("❌ CoreData save error:", error.localizedDescription)
        }
    }
}
