//
//  MainView.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = MusicianViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if vm.isRefreshing {
                    ProgressView()
                } else {
                    List {
                        ForEach(vm.musician, id: \.id) { musician in
                            MusicianView(musician: musician)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(" Apple Music")
            .onAppear(perform: vm.fetchUsersNew)
            .alert(isPresented: $vm.hasError,
                   error: vm.error) {
                Button(action: vm.fetchUsersNew) {
                    Text("Retry")
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
