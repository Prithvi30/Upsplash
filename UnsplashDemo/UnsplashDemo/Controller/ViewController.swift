//
//  ViewController.swift
//  UnsplashDemo
//
//  Created by Prithvi Raj on 17/03/19.
//  Copyright © 2019 Prithvi Raj. All rights reserved.
//

import UIKit
import SDWebImage
import UnsplashKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let apiKey = "96a1c0fb0df4e13205530b5a607c742742d63ac89d0ba005960bd66035e6cf0b"

    var images:[BaseModel] = []
    fileprivate var numberOfImages: Int = 0
    var searchQuary = String()
    var pageNumber = 1
    var numberOfPage = 2

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = 175
        
        self.getCurrentData()
        // Do any additional setup after loading the view, typically from a nib.
    }


        func getCurrentData() {
            APIImagesManager(apiKey: apiKey).featchCurrent(quary:searchQuary, pageNumber: pageNumber) { (result) in
                switch result {
                case .Seccess(let currentImage):
                    for image in currentImage! {
                        self.images.append(image as! BaseModel)
                        print(self.images.count)
                    }
                    
                    self.tableView.reloadData()
                    
                case .Failure(let Error as NSError):
                    
                    let alertController = UIAlertController(title: "Unable to get data", message: "\(Error.localizedDescription)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                default: break
                }
            }
    }
    
    func loadMoreData() {
        for _ in 1..<20 {
            let lastItem = images.count
            let newNum = lastItem + 1
            self.numberOfPage = newNum
        }
        let numOfPage = self.pageNumber + 1
        self.pageNumber = numOfPage
        
        tableView.reloadData()
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        let finalKeywords = keyword?.replacingOccurrences(of: " ", with: "+")
        
        searchQuary = finalKeywords ?? "rose"
        
        self.images.removeAll()
        self.pageNumber = 1
        self.tableView.reloadData()
        
        getCurrentData()
        
        tableView.isPagingEnabled = true
        self.view.endEditing(true)
    }
    
    
    
    
    
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let someImage = images[indexPath.row]
        
        let url = URL(string: someImage.smallURL)
        let imageData = NSData(contentsOf: url!)
        
        cell?.cellImage.image = UIImage(data: imageData! as Data)
        return cell!
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastItem = images.count - 1
        
        if indexPath.row == lastItem {
            loadMoreData()
            getCurrentData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectImage"{
            if let vc = segue.destination as? DetailsViewController{
                let image = sender as? BaseModel
                vc.selectImage = image
            }
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectImage = images[indexPath.row]
        performSegue(withIdentifier: "selectImage", sender: selectImage)
    }
    
    
}

extension UIImageView {
    
    func setImageUsingUrl(_ imageUrl: String?){
        self.sd_setImage(with: URL(string: imageUrl!), placeholderImage:nil)
    }
    
}
