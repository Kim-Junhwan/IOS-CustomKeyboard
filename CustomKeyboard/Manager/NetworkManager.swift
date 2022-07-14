//
//  NetworkManager.swift
//  CustomKeyboard
//
//  Created by JunHwan Kim on 2022/07/11.
//

import Foundation

enum NetworkError : Error {
    case url
    case network
    case decode
}

class NetworkManager{
    
    func fetchReviews(start: Int, completion : @escaping (Result<[ReviewModel], NetworkError>) -> Void){
        let urlStr = "https://api.plkey.app/theme/review?themeId=6&start=\(start)&count=20"
        guard let url = URL(string: urlStr) else {
            completion(.failure(.url))
            return
        }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.network))
                return
            }
            let decorder = JSONDecoder()
            guard let data = try? decorder.decode(ReviewList.self, from: data) else {
                completion(.failure(.decode))
                return
            }
            completion(.success(data.data))
        }.resume()
    }
    
    func uploadPost(with data : PostReviewModel, completion : @escaping (Bool)->Void){
        guard let url = URL(string: "https://api.plkey.app/tmp/theme/PLKEY0-L-81/review") else {
            completion(false)
            return
        }
        guard let data = try? JSONEncoder().encode(data) else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else{
                return
            }
            print(response.statusCode)
            completion(true)
        }.resume()
    }
}
