//
//  DistanceFormatter.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/21.
//

import CoreLocation
import Foundation

// MARK: - 現在地からの距離

/// 座標間の距離を表示用テキストに変換するユーティリティ
enum DistanceFormatter {
    /// 現在地と指定座標から距離文字列（ローカライズされた m / km）を生成する
    static func text(
        from userLocation: CLLocation?,
        to latitude: Double,
        longitude: Double
    ) -> String? {
        guard let userLocation else { return nil }
        
        let target = CLLocation(latitude: latitude, longitude: longitude)
        let meters = userLocation.distance(from: target)
        
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        /// 自然な単位（m/km）に自動スケール
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        
        let nf = NumberFormatter()
        nf.maximumFractionDigits = meters >= 1000 ? 1 : 0
        nf.minimumFractionDigits = 0
        formatter.numberFormatter = nf
        
        return formatter.string(from: measurement)
    }
}
