//
//  Network.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/9/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

//`https://api.unsplash.com/search/photos?query=${searchTerm}&page=${nextPage}&per_page=100&client_id=${UNSPLASH_ACCESS_KEY}`;

class Network {
    
    //Get list of photos encoded into swift structs
    static public func getListPhotos(numberOfImages: Int = 10, page: Int = 1, query: String, completion: @escaping ([Photo]?) -> ()) {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?&query=\(query)&per_page=\(numberOfImages)&page=\(page)&client_id=\(Key.access)") else { return }

        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return completion(nil) }
                                    
            //Encode JSON data into swift structs
            let decoder = JSONDecoder()
                
            do {
                let result = try decoder.decode(Wrapper.self, from: data!)
                completion(result.results)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        
        session.resume()
    }
    
    //Download an url into an UIImage
    static public func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else { return completion(nil) }
        
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return completion(nil) }
            
            guard let image = UIImage(data: data!) else { return completion(nil) }
            completion(image)
        }
        
        session.resume()
    }
}
