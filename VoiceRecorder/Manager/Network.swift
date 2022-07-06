//
//  Network.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/05.
//

import Foundation

class Network {
    private let session = URLSession.shared
    
    func fetchData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
                return
            }
        }.resume()
    }
}
