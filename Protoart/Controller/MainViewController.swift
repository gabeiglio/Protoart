//
//  MainViewController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 11/17/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private var data = [Category]()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.size.width / 2 - 8, height: 200)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 1
        layout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cat = ["Hustle": "👨🏽‍💻","Grind": "🗂","Coding": "🗄", "Office": "🖥", "Landscape":"🌎"]
        self.getData(cat: cat) { (category) in
            self.data.append(category)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
    }
    
    private func getData(cat: [String: String], completion: @escaping (Category) -> ()) {
        for (key, value) in cat {
            Network.getListPhotos(numberOfImages: 4, page: 1, query: key) { (photos) in
                guard let result = photos else { return }
                completion(Category(title: key, icon: value, photos: result))
            }
        }
    }    
}

//Implement Collection View Delegate and Datasource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.data.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data[section].photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("For some reasong the cell is not of type ArtCollectionViewCell")
        }
        
        guard let photoPath = data[indexPath.section].photos[indexPath.row].urls["small"] else { return UICollectionViewCell() }
        
        Network.downloadImage(urlString: photoPath) { (image) in
            guard let result = image else { return }
            DispatchQueue.main.async {
                cell.configure(name: self.data[indexPath.section].photos[indexPath.row].user.name, image: result)
            }
        }
        
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.data[indexPath.section].photos[indexPath.row]
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

//Header UI and Delegate implementation
extension MainViewController: MainHeaderDelegate {
    
    internal func seeMorePressed(key: String) {
        let controller = MoreCollectionViewController(withSearch: key)
        self.navigationController?.show(controller, sender: nil)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as? MainHeaderView else {
                fatalError("Wrong header type")
            }
            headerView.configure(title: self.data[indexPath.section].icon + " " + self.data[indexPath.section].title, key: self.data[indexPath.section].title)
            headerView.delegate = self
            return headerView
        default: assert(false, "Invalid element type")
        }
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
        self.navigationController?.navigationController?.hidesBarsOnTap = false
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
