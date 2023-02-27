//
//  Continuation.swift
//  SwiftConcurrency
//
//  Created by VinhHoang on 22/02/2023.
//

import SwiftUI

class ContinuationNetworkManager {
    
    
    func getData(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        })
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    
    func getHeartImageFromDatabse() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class ContinuationViewmodel: ObservableObject {
    @Published var image: UIImage? = nil
    let manager = ContinuationNetworkManager()
    
    func getImage() async {
        let image = await manager.getHeartImageFromDatabse()
        await MainActor.run {
            self.image = image
        }
    }
}

struct Continuation: View {
    @StateObject private var viewModel = ContinuationViewmodel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
           
        }
        .task {
            await viewModel.getImage()
        }
        
    }
}

struct Continuation_Previews: PreviewProvider {
    static var previews: some View {
        Continuation()
    }
}
