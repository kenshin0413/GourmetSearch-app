//
//  ShopRowViewModel.swift
//  GourmetSearch
//
//  Created by refactor on R 8/01/26.
//

import CoreLocation
import Foundation

/// 店舗一覧セルの表示用ロジックを保持する ViewModel。
@MainActor
final class ShopRowViewModel: ObservableObject {
    let shop: Shop
    @Published private(set) var distanceText: String?
    
    init(shop: Shop) {
        self.shop = shop
    }
    
    /// 現在地からの距離テキストを更新する
    func updateDistance(with userLocation: CLLocation?) {
        distanceText = DistanceFormatter.text(
            from: userLocation,
            to: shop.lat,
            longitude: shop.lng
        )
    }
}
