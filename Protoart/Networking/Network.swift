//
//  Network.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/9/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit


class Network {
    static private let url = URL(string: "https://api.unsplash.com/photos/?client_id=\(Key.access)")
    
    //Get list of photos encoded into swift structs
    static public func getListPhotos(completion: @escaping ([Photo]?) -> ()) {
        guard let URL = self.url else { return }
        
        let session = URLSession.shared.dataTask(with: URL) { (data, response, error) in
            guard error == nil else { return completion(nil) }
            
            //Encode JSON data into swift structs
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode([Photo].self, from: data!)
                completion(result)
            } catch { return completion(nil) }
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
