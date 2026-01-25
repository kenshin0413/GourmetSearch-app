//
//  ShopSearchViewModel.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import CoreLocation
import Foundation

/// 店舗検索の状態管理とAPI通信を担当するViewModel。
/// 検索条件・検索結果・ページング制御を管理する。
@MainActor
final class ShopSearchViewModel: ObservableObject {
    
    // MARK: - 検索条件
    
    /// 検索半径
    @Published var searchRange: Int = 3
    
    /// 検索キーワード
    @Published var searchKeyword: String = ""
    
    // MARK: - 検索結果
    
    /// 取得した店舗一覧
    @Published private(set) var shops: [Shop] = []
    
    /// データ取得中かどうか
    @Published private(set) var isLoading: Bool = false
    
    /// エラー発生時のメッセージ
    @Published private(set) var errorMessage: String?
    
    // MARK: - 内部管理
    
    /// 店舗検索APIサービス
    private let apiService = HotPepperAPIService()
    
    /// 次に取得する検索開始位置
    private var currentStartIndex: Int = 1
    
    /// 1回のリクエストで取得する件数
    private let fetchCount: Int = 20
    
    /// 追加取得が可能かどうか
    private var canLoadMore: Bool = true
    
    /// 同じ開始位置での二重リクエスト防止用
    private var lastRequestedStartIndex: Int = 0
    
    // MARK: - 公開メソッド
    
    /// 初回検索
    /// 検索条件をリセットして1ページ目から再取得する
    func startSearch(from location: CLLocation) async {
        // ローディング状態をリセット
        isLoading = false
        
        /// 1件目から検索し直す
        currentStartIndex = 1
        lastRequestedStartIndex = 0
        
        /// 次ページ取得を許可
        canLoadMore = true
        
        /// 前回の検索結果を削除
        shops.removeAll()
        
        /// 1ページ目を取得
        await loadMoreShops(from: location)
    }
    
    /// 一覧の最後まで表示されたら次のデータを取得する
    func loadMoreIfNeeded(
        currentShop: Shop,
        location: CLLocation
    ) async {
        guard let lastShop = shops.last else { return }
        
        /// 表示中のセルが最後のセルだった場合のみ次のページを取得する
        guard currentShop.id == lastShop.id else { return }
        
        /// 次のページを取得
        await loadMoreShops(from: location)
    }
    
    // MARK: - 内部処理
    
    /// 店舗データを取得して一覧に追加する
    private func loadMoreShops(from location: CLLocation) async {
        // 通信中、またはこれ以上取得できない場合は処理しない
        guard !isLoading, canLoadMore else { return }
        
        // 同じページを二重で取得しないように制御する
        guard currentStartIndex != lastRequestedStartIndex else { return }
        lastRequestedStartIndex = currentStartIndex
        
        // ローディング状態に切り替え、エラーをリセット
        isLoading = true
        errorMessage = nil
        
        do {
            // 現在の検索条件で次のページをAPIから取得する
            let response = try await apiService.fetchShops(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                range: searchRange,
                keyword: searchKeyword,
                startIndex: currentStartIndex,
                fetchCount: fetchCount
            )
            
            // 取得した店舗データ
            let newShops = response.results.shop
            
            // 取得した店舗データを一覧に追加する
            shops.append(contentsOf: newShops)
            
            // 実際に取得できた件数を使用する
            let returnedCount = newShops.count
            
            // 取得件数が0件なら、これ以上取得しない
            if returnedCount == 0 {
                canLoadMore = false
            } else {
                // 次回取得する開始位置を更新する
                currentStartIndex += returnedCount
            }
            
        } catch {
            // 通信エラー発生時のエラーメッセージを保持する
            errorMessage = HotPepperAPIError.userMessage(for: error)
            print("❌ Shop fetch error:", error.localizedDescription)
        }
        
        // ローディング状態を解除する
        isLoading = false
    }

    // エラーメッセージは HotPepperAPIError 側で行う

    // MARK: - エラー状態のクリア
    func clearError() {
        errorMessage = nil
    }
}
