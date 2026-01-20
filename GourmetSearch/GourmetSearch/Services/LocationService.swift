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
    
    /// 取得した住所（例: 東京都 渋谷区 神南）
    /// ※ 市の次の階層まで表示する
    @Published var addressText: String?
    
    // MARK: - 内部プロパティ
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // MARK: - 初期化
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // アプリ起動時に現在の許可状態をチェック
        checkAuthorization()
    }
    
    // MARK: - 公開メソッド
    
    /// 現在の許可状態を確認し、必要なら許可リクエストを行う
    func checkAuthorization() {
        authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // まだ許可されていない場合はダイアログを表示
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            // すでに許可されている場合はすぐ位置取得
            startUpdatingLocation()
            
        case .denied, .restricted:
            errorMessage = "位置情報の使用が許可されていません"
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 内部制御
    
    /// 位置情報の取得を開始する（許可後に呼ばれる）
    private func startUpdatingLocation() {
        errorMessage = nil
        locationManager.startUpdatingLocation()
    }
    
    /// バッテリー節約のため位置情報の取得を停止する
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 緯度・経度から住所（都道府県・市・市の次の階層）を取得する
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error {
                print("Geocode error:", error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            // 住所構成要素
            let prefecture = placemark.administrativeArea   // 都道府県
            let city = placemark.locality                   // 市
            let subArea = placemark.subLocality             // 区・町など（市の次の階層）
            
            let address = [
                prefecture,
                city,
                subArea
            ]
                .compactMap { $0 }
                .joined(separator: " ")
            
            DispatchQueue.main.async {
                self.addressText = address
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// 位置情報の許可状態が変更されたときに呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 許可されたら自動で位置取得
            startUpdatingLocation()
            
        case .denied, .restricted:
            errorMessage = "位置情報の使用が許可されていません"
            
        default:
            break
        }
    }
    
    /// 位置情報の取得に成功したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        
        // 住所を取得
        reverseGeocode(location: location)
        
        // バッテリー節約のため停止
        stopUpdatingLocation()
    }
    
    /// 位置情報の取得に失敗したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}
