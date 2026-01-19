//
//  LocationService.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import CoreLocation

/// 端末の現在地を取得・管理するサービスクラス。
/// 位置情報の許可リクエストと現在地取得を担当する。
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - 公開状態
    
    /// 現在取得できている位置情報
    @Published var currentLocation: CLLocation?
    
    /// 位置情報の利用許可状態
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// 位置情報取得時のエラーメッセージ
    @Published var errorMessage: String?
    
    // MARK: - 内部プロパティ
    
    private let locationManager = CLLocationManager()
    
    // MARK: - 初期化
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - 公開メソッド
    
    /// 位置情報の使用許可をリクエストする
    func requestLocationPermission() {
        print("requestLocationPermission called")
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - 内部制御
    
    /// 位置情報の取得を開始する（許可後に呼ばれる）
    private func startUpdatingLocation() {
        print("startUpdatingLocation called")
        errorMessage = nil
        locationManager.startUpdatingLocation()
    }
    
    /// バッテリー節約のため位置情報の取得を停止する
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// 位置情報の許可状態が変更されたときに呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization changed:", authorizationStatus.rawValue)
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        case .denied, .restricted:
            errorMessage = "位置情報の使用が許可されていません"
            
        default:
            break
        }
    }
    
    /// 位置情報の取得に成功したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated:", locations)
        
        guard let location = locations.first else { return }
        currentLocation = location
        stopUpdatingLocation()
    }
    
    /// 位置情報の取得に失敗したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
        errorMessage = error.localizedDescription
    }
}
