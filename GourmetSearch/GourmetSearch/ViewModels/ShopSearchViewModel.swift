//
//  ShopSearchViewModel.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import Foundation
import CoreLocation

@MainActor
final class ShopSearchViewModel: ObservableObject {
    
    // MARK: - Search Conditions
    
    @Published var searchRange: Int = 3
    @Published var searchKeyword: String = ""
    
    // MARK: - Search Results
    
    @Published private(set) var shops: [Shop] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let apiService = HotPepperAPIService()
    private var currentStartIndex: Int = 1
    private let fetchCount: Int = 20
    private var canLoadMore: Bool = true
    private var lastRequestedStartIndex: Int = 0
    
    /// 新しい条件で検索を開始する
    func startSearch(from location: CLLocation) async {
        isLoading = false
        currentStartIndex = 1
        lastRequestedStartIndex = 0
        canLoadMore = true
        shops.removeAll()
        
        await loadMoreShops(from: location)
    }
    
    /// 一覧の最後までスクロールしたら次のページを取得する
    func loadMoreIfNeeded(currentShop: Shop, location: CLLocation) async {
        guard let lastShop = shops.last else { return }
        guard currentShop.id == lastShop.id else { return }
        await loadMoreShops(from: location)
    }
    
    // MARK: - Private
    
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
            
            shops.append(contentsOf: response.results.shop)
            
            let returnedCount = Int(response.results.resultsReturned) ?? 0
            currentStartIndex += returnedCount
            canLoadMore = returnedCount > 0
            
        } catch {
            errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }
        
        isLoading = false
    }
}
