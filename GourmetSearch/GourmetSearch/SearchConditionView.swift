//
//  ContentView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI
import CoreLocation

struct SearchConditionView: View {
    // searchConditionSectionの初期値
    @State private var searchRange: Int = 3
    @State private var searchKeyword: String = ""
    // 画面遷移制御
    @State private var showResultScreen = false
    
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
    
    // MARK: - 各セクション
    
    private var locationSection: some View {
        Section("現在地") {
            Button("位置情報を取得") {
                
            }
        }
    }
    
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
    
    private var searchButtonSection: some View {
        Section {
            Button("検索する") {
                
            }
        }
    }
}
