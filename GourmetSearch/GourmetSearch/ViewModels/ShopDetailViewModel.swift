//
//  ShopDetailViewModel.swift
//  GourmetSearch
//
//  Created by refactor on R 8/01/26.
//

import Combine
import CoreLocation
import Foundation

/// 店舗詳細画面の表示ロジックを管理する ViewModel。
@MainActor
final class ShopDetailViewModel: ObservableObject {
    // MARK: - 入力データ
    
    let shop: Shop
    
    // MARK: - 公開状態
    
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var distanceText: String? = nil
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    // MARK: - 依存（遅延バインド）
    
    private var favoriteStore: FavoriteStore?
    private var locationService: LocationService?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - 初期化
    
    init(shop: Shop) {
        self.shop = shop
    }
    
    /// View側で EnvironmentObject を渡して購読を開始する
    func bind(favoriteStore: FavoriteStore, locationService: LocationService) {
        // すでに同じ依存がバインド済みならスキップ
        if self.favoriteStore === favoriteStore && self.locationService === locationService { return }
        
        self.favoriteStore = favoriteStore
        self.locationService = locationService
        cancellables.removeAll()
        
        // 初期値反映
        self.isFavorite = favoriteStore.isFavorite(id: shop.id)
        self.distanceText = DistanceFormatter.text(
            from: locationService.currentLocation,
            to: shop.lat,
            longitude: shop.lng
        )
        
        // お気に入りの変更を監視
        favoriteStore.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.isFavorite = favoriteStore.isFavorite(id: self.shop.id)
            }
            .store(in: &cancellables)
        
        // 現在地の変更を監視
        locationService.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self else { return }
                self.distanceText = DistanceFormatter.text(
                    from: location,
                    to: self.shop.lat,
                    longitude: self.shop.lng
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - アクション
    
    func toggleFavorite() {
        guard let favoriteStore else { return }
        if favoriteStore.isFavorite(id: shop.id) {
            favoriteStore.remove(id: shop.id)
        } else {
            favoriteStore.add(shop)
        }
    }
    
    /// UIからのトグルに紐づくトースト制御も含めたアクション
    func favoriteTapped() {
        let wasFavorite = isFavorite
        toggleFavorite()
        toastMessage = wasFavorite ? "お気に入りから削除しました" : "お気に入りに追加しました"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showToast = false
        }
    }
    
    // MARK: - 表示用プロパティ
    
    var mapsURL: URL? {
        let encodedAddress = shop.address
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(encodedAddress)")
    }
    
    var websiteURL: URL? {
        guard !shop.urls.pc.isEmpty else { return nil }
        return URL(string: shop.urls.pc)
    }
    
    var cardText: String { shop.card.isEmpty ? "不明" : shop.card }
    var parkingText: String { shop.parking.isEmpty ? "不明" : shop.parking }
    var formattedAccessText: String {
        shop.access
            .replacingOccurrences(of: "/", with: "/\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
