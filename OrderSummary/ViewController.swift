//
//  ViewController.swift
//  OrderSummary
//
//  Created by Alexandre Gravelle on 2018-07-12.
//  Copyright © 2018 Alexandre Gravelle. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let kHeaderSectionTag: Int = 6900;
    
    @IBOutlet weak var tableView: UITableView!
    
    let animalType: String = "Curious Cat"
    
    let loadingView = UIView()
    let loadingLabel = UILabel()
    let spinner = UIActivityIndicatorView()
    
    // MARK: - Properties
    var orderData = [Order]()
    var p: Int!
    
    var dataDictionary = [String: [Order]]()
    var dataSectionTitles = [String]()

    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "customCell")
        
        tableView.backgroundColor = UIColor.colorWithHexString(hexStr: "#393e46")
        self.tableView!.tableFooterView = UIView()
        
        p = 0
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Order Summary"
        
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithHexString(hexStr: "#393e46")
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        setLoadingScreen()
        
        fetchData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchData() {
        Alamofire.request("https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6")
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        print("Error while fetching tags: \(String(describing: response.result.error))")
                        return
                }
                
                _ = JSON(value)["orders"].array!.map { json in
                    let orderNumber = json["order_number"].description
                    let firstName = json["customer"]["first_name"].description
                    let lastName = json["customer"]["last_name"].description
                    let province = json["customer"]["default_address"]["province"].description
                    let totalPrice = json["total_price"].description
                    let currency = json["currency"].description
                    let processed_date = json["processed_at"].description

                    if (province != "null"){
                        let order = Order.init(orderNumber: orderNumber, firstName: firstName, lastName: lastName, province: province, totalPrice: totalPrice, currency: currency, processed_date: processed_date)
                            self.orderData.append(order)
                    }
                    
                }
                
                self.sort()
                
                self.removeLoadingScreen()
                self.tableView.reloadData()
        }
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if dataSectionTitles.count > 0 {
            tableView.backgroundView = nil
            return dataSectionTitles.count
        }
            return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let dataKey = dataSectionTitles[section]
            if let dataValues = dataDictionary[dataKey] {
                return dataValues.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dataKey = dataSectionTitles[section]
        let sectionData = dataDictionary[dataKey]
        
         if let sectionData = sectionData {
            if (self.dataSectionTitles.count != 0) {
                let headerString = self.dataSectionTitles[section] + " (" + String(sectionData.count) + ")"
                return headerString
            }
        }
        
        return ""
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#393e46")
        header.textLabel?.textColor = UIColor.white
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(ViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 131.5;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0;
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [""]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        
        // Configure the cell...
        let dataKey = dataSectionTitles[indexPath.section]
        let dataValues = dataDictionary[dataKey]
        cell.customInit(order: dataValues![indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = ((self.view.frame.width) / 2) - (width / 2)
        let y = ((self.view.frame.height) / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        self.view.addSubview(loadingView)
    }
    
    func sort() {
        self.dataDictionary.removeAll()
        self.dataSectionTitles.removeAll()
        if self.p == 0 {
            // 1
            for d in self.orderData {
                let dataKey = String(d.province)
                if var dataValues = self.dataDictionary[dataKey] {
                    dataValues.append(d)
                    self.dataDictionary[dataKey] = dataValues
                } else {
                    self.dataDictionary[dataKey] = [d]
                }
            }
            
            // 2
            self.dataSectionTitles = [String](self.dataDictionary.keys)
            self.dataSectionTitles = self.dataSectionTitles.sorted(by: { $0 < $1 })
            
        } else {
            // 1
            for d in self.orderData {
                let dataKey = String(d.processed_date.prefix(4))
                if var dataValues = self.dataDictionary[dataKey] {
                    dataValues.append(d)
                    self.dataDictionary[dataKey] = dataValues
                } else {
                    self.dataDictionary[dataKey] = [d]
                }
            }
            
            // 2
            self.dataSectionTitles = [String](self.dataDictionary.keys)
            self.dataSectionTitles = self.dataSectionTitles.sorted(by: { $0 > $1 })
        }
        
        for d in self.dataDictionary {
            let dataKey = d.key
            let dataValues = self.dataDictionary[dataKey]
            self.dataDictionary[dataKey] = dataValues?.sorted(by: { $0.orderNumber > $1.orderNumber })
        }
    
    }
    
    private func removeLoadingScreen() {
        self.navigationItem.leftBarButtonItem?.isEnabled = true;
        self.navigationItem.rightBarButtonItem?.isEnabled = true;
        self.view.isUserInteractionEnabled = true
        
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
    }
    
    @IBAction func SwitchCustomTableViewAction(_ sender: UISegmentedControl) {
        p = sender.selectedSegmentIndex
        sort()
        self.expandedSectionHeaderNumber = -1
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let dataKey = dataSectionTitles[section]
        let sectionData = dataDictionary[dataKey]
        
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData?.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            
            if let sectionData = sectionData {
                for i in 0 ..< sectionData.count {
                    let index = IndexPath(row: i, section: section)
                    indexesPath.append(index)
                }
                self.tableView!.beginUpdates()
                self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tableView!.endUpdates()
            }
        
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let dataKey = dataSectionTitles[section]
        let sectionData = dataDictionary[dataKey]
        
        if (sectionData?.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            
            if let sectionData = sectionData {
                for i in 0 ..< sectionData.count {
                    let index = IndexPath(row: i, section: section)
                    indexesPath.append(index)
                }
                self.expandedSectionHeaderNumber = section
                self.tableView!.beginUpdates()
                self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tableView!.endUpdates()
            
            
            }
        }
    }
    
}

