//
//  MainViewController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 11/17/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit
import collection_view_layouts

class MainViewController: UIViewController {
    
    
    private let data = Art.getArt()
    //private let searchBarController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout: BaseLayout = FlickrLayout()
        layout.delegate = self
        layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)

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
        self.initialSetup()
    }
    
}

//Implement Collection View Delegate and Datasource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artCell", for: indexPath) as? ArtCollectionViewCell else {
            fatalError("For some reasong the cell is not of type ArtCollectionViewCell")
        }
        cell.configure(name: self.data[indexPath.row].name, image: self.data[indexPath.row].image)
        return cell
    }
    
    internal func cellSize(indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 10, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = PreviewViewController()
        controller.initWith(config: ARAugmentedRealityConfig(with: self.data[indexPath.row].image, size: self.data[indexPath.row].size))
        self.navigationController?.pushViewController(controller, animated: true)
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

        //self.searchBarController.searchResultsUpdater = self
//        self.searchBarController.hidesNavigationBarDuringPresentation = false
//        self.searchBarController.dimsBackgroundDuringPresentation = false
//        self.navigationItem.searchController = self.searchBarController
        
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
