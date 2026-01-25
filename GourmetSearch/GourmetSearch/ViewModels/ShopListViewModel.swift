//
//  ShopListViewModel.swift
//  GourmetSearch
//
//  Created by refactor on R 8/01/26.
//

import CoreLocation
import Foundation

/// 店舗検索結果の取得・ページング・エラー状態を管理する ViewModel。
@MainActor
final class ShopListViewModel: ObservableObject {
    // MARK: - 検索条件
    
    @Published var searchRange: Int
    @Published var searchKeyword: String
    
    // MARK: - 検索結果
    
    @Published private(set) var shops: [Shop] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    // MARK: - 内部管理
    
    private let apiService = HotPepperAPIService()
    private var currentStartIndex: Int = 1
    private let fetchCount: Int = 20
    private var canLoadMore: Bool = true
    private var lastRequestedStartIndex: Int = 0
    
    // MARK: - 初期化
    
    init(searchRange: Int = 3, searchKeyword: String = "") {
        self.searchRange = searchRange
        self.searchKeyword = searchKeyword
    }
    
    
    // MARK: - 公開メソッド
    
    /// 初回検索。状態をリセットして1ページ目から取得する。
    func startSearch(from location: CLLocation) async {
        isLoading = false
        currentStartIndex = 1
        lastRequestedStartIndex = 0
        canLoadMore = true
        shops.removeAll()
        await loadMoreShops(from: location)
    }
    
    /// 一覧の最後に到達したら追加読み込みする。
    func loadMoreIfNeeded(currentShop: Shop, location: CLLocation) async {
        guard let lastShop = shops.last else { return }
        guard currentShop.id == lastShop.id else { return }
        await loadMoreShops(from: location)
    }
    
    /// エラー状態のクリア
    func clearError() { errorMessage = nil; showErrorAlert = false }
    
    // MARK: - 内部処理
    
    private func loadMoreShops(from location: CLLocation) async {
        guard !isLoading, canLoadMore else { return }
        guard currentStartIndex != lastRequestedStartIndex else { return }
        lastRequestedStartIndex = currentStartIndex
        
        isLoading = true
        errorMessage = nil
        do {
            let response = try await apiService.fetchShops(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                range: searchRange,
                keyword: searchKeyword,
                startIndex: currentStartIndex,
                fetchCount: fetchCount
            )
            
            let newShops = response.results.shop
            shops.append(contentsOf: newShops)
            
            let returnedCount = newShops.count
            if returnedCount == 0 {
                canLoadMore = false
            } else {
                currentStartIndex += returnedCount
            }
        } catch {
            errorMessage = HotPepperAPIError.userMessage(for: error)
            showErrorAlert = true
            print("❌ Shop fetch error:", error.localizedDescription)
        }
        isLoading = false
    }
}
