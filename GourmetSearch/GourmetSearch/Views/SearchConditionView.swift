//
//  ContentView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI
import CoreLocation

/// 店舗検索の条件を入力見る画面。
/// 現在地の取得と検索条件の入力を行う。
struct SearchConditionView: View {

    // MARK: - 状態管理

    /// 位置情報を管理するサービス
    @StateObject private var locationService = LocationService()

    /// 検索半径（初期値：1km）
    @State private var searchRange: Int = 3

    /// 検索キーワード
    @State private var searchKeyword: String = ""

    // MARK: - 画面構成

    var body: some View {
        NavigationStack {
            Form {
                locationSection
                searchConditionSection
                searchButtonSection
            }
            .navigationTitle("検索条件")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 現在地セクション

    /// 現在地の取得状態を表示するセクション
    private var locationSection: some View {
        Section("現在地") {
            Text(locationStatusText)

            Button("位置情報を取得") {
                locationService.requestLocationPermission()
            }
        }
    }

    // MARK: - 検索条件セクション

    /// 検索半径・キーワードを入力するセクション
    private var searchConditionSection: some View {
        Section("検索条件") {
            Picker("検索半径", selection: $searchRange) {
                Text("300m").tag(1)
                Text("500m").tag(2)
                Text("1km").tag(3)
                Text("2km").tag(4)
                Text("3km").tag(5)
            }

            TextField("キーワード", text: $searchKeyword)
        }
    }

    // MARK: - 検索ボタンセクション

    /// 検索を実行するボタン
    private var searchButtonSection: some View {
        Section {
            Button("検索する") {
                // 今後ここに検索処理・画面遷移を実装する
            }
            .disabled(locationService.currentLocation == nil)
        }
    }

    // MARK: - 表示用テキスト生成

    /// 現在の位置情報状態に応じた表示文言を生成する
    private var locationStatusText: String {
        if let location = locationService.currentLocation {
            return "取得済み: \(location.coordinate.latitude), \(location.coordinate.longitude)"
        }

        switch locationService.authorizationStatus {
        case .notDetermined:
            return "位置情報の許可が必要です"
        case .denied, .restricted:
            return "設定から位置情報を許可してください"
        default:
            return "現在地を取得中..."
        }
    }
}
