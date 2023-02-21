//
//  DoTryCatch.swift
//  SwiftConcurrency
//
//  Created by VinhHoang on 20/02/2023.
//

import SwiftUI

class DoTryCatchThrowsManager {
    var isActive = false
    func getTitle() throws -> String {
        if isActive {
            return "NEW TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}


class DoTryCatchThrowsVM: ObservableObject {
    @Published var text: String = "Starting text"
    let manager = DoTryCatchThrowsManager()
    
    func fetchTitle() {
        do {
            let newTitle = try manager.getTitle()
            self.text = newTitle

        } catch let error {
            self.text = error.localizedDescription
        }
        
    }
}

struct DoTryCatch: View {
    
    @StateObject private var viewModel = DoTryCatchThrowsVM()
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoTryCatch_Previews: PreviewProvider {
    static var previews: some View {
        DoTryCatch()
    }
}
