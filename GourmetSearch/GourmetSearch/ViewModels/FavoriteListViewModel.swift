//
//  FavoriteListViewModel.swift
//  GourmetSearch
//
//  Created by refactor on R 8/01/26.
//

import Combine
import Foundation
import SwiftUI

/// お気に入り一覧画面のロジックを担う ViewModel。
@MainActor
final class FavoriteListViewModel: ObservableObject {
    // MARK: - 公開状態
    
    /// 表示用に保持するお気に入り一覧
    @Published private(set) var favorites: [Shop] = []
    /// 削除確認アラートの表示制御
    @Published var showDeleteAlert: Bool = false
    /// 削除対象のIndexSet
    @Published var pendingDeleteOffsets: IndexSet? = nil
    /// リストの編集モード
    @Published var editMode: EditMode = .inactive
    
    // MARK: - 依存関係
    
    /// データ永続化を担うお気に入りリポジトリ
    private var favoriteStore: FavoriteStore?
    /// お気に入り配列の購読を保持する
    private var cancellable: AnyCancellable?
    
    /// EnvironmentObject の FavoriteStore をバインドし、購読を開始する
    func bind(favoriteStore: FavoriteStore) {
        if self.favoriteStore === favoriteStore { return }
        self.favoriteStore = favoriteStore
        
        // 初期反映
        self.favorites = favoriteStore.favorites
        
        // 更新購読
        cancellable = favoriteStore.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shops in
                self?.favorites = shops
            }
    }
    
    /// 件数の表示テキスト
    var countText: String { "\(favorites.count)件を保存中" }
    
    /// 一覧が空かどうか
    var isEmpty: Bool { favorites.isEmpty }
    
    /// 削除（IndexSetをIDに変換してFavoriteStoreへ委譲）
    func delete(at offsets: IndexSet) {
        guard let favoriteStore else { return }
        let ids = offsets.compactMap { index in
            favorites.indices.contains(index) ? favorites[index].id : nil
        }
        ids.forEach { favoriteStore.remove(id: $0) }
    }
    
    // MARK: - UIイベントハンドリング
    
    /// 削除確認アラートを表示
    func promptDelete(offsets: IndexSet) {
        pendingDeleteOffsets = offsets
        showDeleteAlert = true
    }
    
    /// 削除を確定して実行、編集モードを解除
    func confirmDelete() {
        if let offsets = pendingDeleteOffsets {
            delete(at: offsets)
        }
        pendingDeleteOffsets = nil
        showDeleteAlert = false
        editMode = .inactive
    }
    
    /// 削除をキャンセルして状態をクリア
    func cancelDelete() {
        pendingDeleteOffsets = nil
        showDeleteAlert = false
    }
    
    /// 編集モードをトグル
    func toggleEditMode() {
        editMode = (editMode == .active) ? .inactive : .active
    }
}
