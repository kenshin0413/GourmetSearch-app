//
//  FavoriteStore.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/22.
//

import Foundation

/// お気に入り店舗を管理するストア
final class FavoriteStore: ObservableObject {
    
    /// お気に入り店舗一覧
    @Published private(set) var favorites: [Shop] = []
    
    /// 指定した店舗がお気に入りかどうか
    func isFavorite(_ shop: Shop) -> Bool {
        favorites.contains { $0.id == shop.id }
    }
    
    /// お気に入り追加
    func add(_ shop: Shop) {
        guard !isFavorite(shop) else { return }
        favorites.append(shop)
    }
    
    /// お気に入り削除
    func remove(_ shop: Shop) {
        favorites.removeAll { $0.id == shop.id }
    }
    
    /// IndexSet指定で削除
    func remove(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
    }
    
    /// 追加・削除をトグル
    func toggle(_ shop: Shop) {
        if isFavorite(shop) {
            remove(shop)
        } else {
            add(shop)
        }
    }
}
