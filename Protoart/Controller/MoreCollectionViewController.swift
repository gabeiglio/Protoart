//
//  MoreCollectionViewController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/11/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class MoreCollectionViewController: UICollectionViewController {
    
    private var photos = [Photo]()
    private let key: String
    
    public init(withSearch key: String) {
        self.key = key
        
        //Init layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width / 2 - 8, height: 200)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Network.getListPhotos(numberOfImages: 30, page: 1, query: self.key) { (photos) in
            guard let result = photos else { return }
            self.photos = result
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.setupViews()
    }
    
}

//Setup Collectionview delegate
extension MoreCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("For some reasong the cell is not of type ArtCollectionViewCell")
        }
        
        guard let photoPath = self.photos[indexPath.row].urls["small"] else { return UICollectionViewCell() }
        
        Network.downloadImage(urlString: photoPath) { (image) in
            guard let result = image else { return }
            DispatchQueue.main.async {
                cell.configure(name: self.photos[indexPath.row].user.name, image: result)
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.photos[indexPath.row]
        guard let photoPath = photo.urls["full"] else { return }
        
        
        
        Network.downloadImage(urlString: photoPath) { (image) in
            guard let result = image else { return }
            
            DispatchQueue.main.async {
                let controller = PreviewViewController()
                controller.initWith(config: ARAugmentedRealityConfig(with: result, size: CGSize(width: photo.width.getSizeInMeters(), height: photo.height.getSizeInMeters())))
                self.navigationController?.show(controller, sender: nil)
            }
        }
    }
}

//Setup views
extension MoreCollectionViewController {
    private func setupViews() {
        
        //Self
        self.title = key
        
        //Navigation bar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.hidesBarsOnSwipe = false
        
        //Collection View
        self.collectionView.backgroundColor = .groupTableViewBackground
        self.collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        
    }
}
