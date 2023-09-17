//
//  ContentView.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = UsersViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if vm.isRefreshing {
                    ProgressView()
                } else {
                    List {
                        ForEach(vm.users, id: \.id) { user in
                            UserView(user: user)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Users")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
