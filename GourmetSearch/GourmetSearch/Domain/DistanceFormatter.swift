//
//  DistanceFormatter.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/21.
//

import CoreLocation

/// 座標間の距離を表示用テキストに変換するユーティリティ
enum DistanceFormatter {
    
    /// 現在地と指定座標から距離文字列（m / km）を生成する
    static func text(
        from userLocation: CLLocation?,
        to latitude: Double,
        longitude: Double
    ) -> String? {
        
        guard let userLocation else { return nil }
        
        let shopLocation = CLLocation(latitude: latitude, longitude: longitude)
        let meters = userLocation.distance(from: shopLocation)
        
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let km = meters / 1000
            return String(format: "%.1fkm", km)
        }
    }
}
