//
//  ShopListView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI
import CoreLocation

struct ShopListView: View {
    
    @ObservedObject var viewModel: ShopSearchViewModel
    let location: CLLocation?
    
    var body: some View {
        List {
            ForEach(viewModel.shops, id: \.id) { shop in
                NavigationLink {
                    // これから店の詳細を表示するViewを追加する
                } label: {
                    // これから店リストを表示するViewを追加する
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
    }
}
