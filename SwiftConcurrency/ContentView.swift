//
//  ContentView.swift
//  SwiftConcurrency
//
//  Created by VinhHoang on 20/02/2023.
//

import SwiftUI


class SomeViewModel: ObservableObject {
    @MainActor @Published var images: [String] = []
    
    
    func downloadPhoto(named: String) async -> String {
        await try? Task.sleep(for: .seconds(2))
        print("downloading photo: \(named)")
        return named + "Photo"
    }

    func downloadPhotos() async {
        async let firstPhoto = downloadPhoto(named: "first")
        async let secondPhoto = downloadPhoto(named: "second")
        async let thirdPhoto = downloadPhoto(named: "third")
        async let fourthPhoto = downloadPhoto(named: "fourth")
        let photos = await [firstPhoto, secondPhoto, thirdPhoto, fourthPhoto]
        await MainActor.run {
            self.images = photos
        }
        print(photos)
    }

    
    
}

struct ContentView: View {
    
    @StateObject var viewModel = SomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.images, id: \.self) { image in
                    Text(image)
                }
            }
        }
        .task {
            await viewModel.downloadPhotos()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
