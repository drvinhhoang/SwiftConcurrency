//
//  Sendable.swift
//  SwiftConcurrency
//
//  Created by VinhHoang on 25/02/2023.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyUserInfo) -> String {
        return userInfo.name
    }
    
    
}

struct MyUserInfo: Sendable {
    let name: String
}

class SendableViewModel: ObservableObject {
    let manager = CurrentUserManager()
    @Published var name: String = ""
    
    @MainActor
    func updateCurrentUserInfo() async {
        let info = MyUserInfo(name: "info")
        self.name = await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootCamp: View {
    
    @StateObject private var viewModel = SendableViewModel()
    var body: some View {
        Text(viewModel.name)
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

struct Sendable_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootCamp()
    }
}
