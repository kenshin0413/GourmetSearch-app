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
    
    /// 取得した住所
    /// ※ 市の次の階層まで表示する
    @Published var addressText: String?
    
    // MARK: - 内部プロパティ
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    /// 住所解決済みフラグ（多重実行防止）
    private var hasResolvedAddress = false
    
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
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        case .denied, .restricted:
            break
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 内部制御
    
    /// 位置情報の取得を開始する（許可後に呼ばれる）
    private func startUpdatingLocation() {
        hasResolvedAddress = false
        locationManager.startUpdatingLocation()
    }
    
    /// バッテリー節約のため位置情報の取得を停止する
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 緯度・経度から住所（都道府県・市・市の次の階層）を取得する
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            
            if let error {
                print("Geocode error:", error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let prefecture = placemark.administrativeArea
            let city = placemark.locality
            let subArea = placemark.subLocality
            
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
    
    /// 位置情報の利用許可状態が変更されたときに呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 現在の許可状態を保持
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 位置情報の利用が許可されたら、現在地の取得を開始する
            startUpdatingLocation()
            
        default:
            // 未許可・制限中の場合は特に処理しない
            break
        }
    }
    
    /// 位置情報の取得に成功したときに呼ばれる
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // 最新の位置情報を取得
        guard let location = locations.first else { return }
        currentLocation = location
        
        // 精度更新などで複数回呼ばれるケースを防ぐ
        guard !hasResolvedAddress else { return }
        hasResolvedAddress = true
        
        // 緯度・経度から住所を取得する
        reverseGeocode(location: location)
        
        // バッテリー消費を抑えるため、位置情報の更新を停止する
        stopUpdatingLocation()
    }
    
    /// 位置情報の取得に失敗したときに呼ばれる
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // 取得失敗時のエラー内容をログ出力（デバッグ用）
        print("Location error:", error.localizedDescription)
    }
}
