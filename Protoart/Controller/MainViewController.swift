//
//  MainViewController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 11/17/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private var data = [Photo]()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.size.width / 2 - 8, height: 200)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ArtCollectionViewCell.self, forCellWithReuseIdentifier: "artCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Network.getListPhotos { (photos) in
            guard let result = photos else { return }
            self.data = result
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.initialSetup()
    }
    
}

//Implement Collection View Delegate and Datasource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artCell", for: indexPath) as? ArtCollectionViewCell else {
            fatalError("For some reasong the cell is not of type ArtCollectionViewCell")
        }
        
        Network.downloadImage(urlString: data[indexPath.row].urls["small"]!) { (image) in
            guard let result = image else { return }
            
            DispatchQueue.main.async {
                cell.configure(name: self.data[indexPath.row].user.name, image: result)
            }
        }
        
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = PreviewViewController()
//        controller.initWith(config: ARAugmentedRealityConfig(with: self.data[indexPath.row].image, size: self.data[indexPath.row].size))
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

//Setup any view and data here, this function will get called in viewdidload
extension MainViewController {
    private func initialSetup() {
        
        //Self
        self.title = "Gallery"
        self.view.backgroundColor = .groupTableViewBackground
        
        //Navigation bar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)

        //Add collection View to view
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 5),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
