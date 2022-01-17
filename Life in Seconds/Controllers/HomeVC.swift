//
//  ViewController.swift
//  Life in Seconds
//
//  Created by Riccardo Carlotto on 22/12/21.
//

import UIKit
import MobileCoreServices
import PhotosUI
import MediaPlayer

private let reuseIdentifier = "MyCell123"

class HomeVC: UIViewController, UICollectionViewDelegate  {
    
    //MARK: - Calendar  and collection Properties
    private var sectionInsets = UIEdgeInsets(top: 70.0, left: 10.0, bottom: 8.0, right: 10.0)
    
    private var itemsPerRow: CGFloat = 7
    
    let calendar = Calendar(identifier: .gregorian)
    
    var selectedIndexPath: IndexPath?
    
    var baseDate: Date = Date()
    
    //objects
    let dataManager = MyDataManger.shared
    let videoHelper = VideoHelper()
    let merger = MergeExport.shared
    
    var arrayDayCell: [DayCell] = [DayCell]()
    
    private lazy var footerView = CalendarPickerFooterView(
        didTapLastMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: -1,
                to: self.baseDate
            ) ?? self.baseDate
            
            self.arrayDayCell = [DayCell]()
            self.selectedIndexPath = nil
            self.getCurrentMonthArray(of: self.baseDate)
            self.getImageInArrayDayCell()
//            self.addOffsetPreviuosMonth()
            
            self.headerView.baseDate = self.baseDate
            
            self.collectionView.reloadData()
            
        },
        didTapNextMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: 1,
                to: self.baseDate
            ) ?? self.baseDate
            
            self.arrayDayCell = [DayCell]()
            self.selectedIndexPath = nil
            
            self.getCurrentMonthArray(of: self.baseDate)
            self.getImageInArrayDayCell()
//            self.addOffsetPreviuosMonth()
            
            self.headerView.baseDate = self.baseDate
            
            self.collectionView.reloadData()
        }
    )
    

    
    private lazy var headerView = CalendarPickerHeaderView {
        [weak self] in
        guard let self = self else { return }
    }

        
    
    //MARK: - VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(headerView)
        view.addSubview(footerView)
        
        headerView.baseDate = baseDate
        
        loadTheData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveToMovies), name: .mergeComplete, object: nil)
        
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints:[NSLayoutConstraint] = []
        
        constraints.append(contentsOf: [
     
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 110),
            
            footerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        headerView.mergingButton.wheel.stopAnimating()
        headerView.mergingButton.icon.isHidden = false
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
   
    
    @objc func moveToMovies () {
        
//            performSegue(withIdentifier: "toMovies", sender: self)
        tabBarController?.selectedIndex = 1
        
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
}


// MARK: - UINavigationControllerDelegate

extension HomeVC: UINavigationControllerDelegate {
    
}


// MARK: - UICollectionViewDataSource

extension HomeVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayDayCell.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCell
        
        cell.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        
        cell.layer.cornerRadius = 15.0
        
        let day = arrayDayCell[indexPath.row].day
        cell.day.text = day
        
        let weekDay = arrayDayCell[indexPath.row].weekDay
        cell.weekDay.text = weekDay
        
        
        if let img: UIImage = arrayDayCell[indexPath.row].image {
            cell.imageView.image = img
            cell.day.textColor = .white
            cell.weekDay.textColor = .white
        } else {
            cell.imageView.image = nil
            cell.day.textColor = nil
            cell.weekDay.textColor = nil
        }
        
        if indexPath == selectedIndexPath {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.black.cgColor
        }
        
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension HomeVC : UICollectionViewDelegateFlowLayout {
    
    // the size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // get the cell all touching each other
        let width = collectionView.bounds.width/4.6
        let height = width
        
        
        return CGSize(width: width, height: height)
    }
    
    // the insets of the collectionView (the padding)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    // minimum spacing between successive rows or columns of a section
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var reloadIndexPaths = [indexPath]
        
        if let deselectIndexPath = selectedIndexPath {
            reloadIndexPaths.append(deselectIndexPath)
        }
        
        baseDate = arrayDayCell[indexPath.row].date
        
        selectedIndexPath = indexPath
        
        // reloadItems works with multiple indexpath so if you have 2 indexes it will reload them both
        
        collectionView.reloadItems(at: reloadIndexPaths)
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.modalPresentationStyle = .popover
        //        alertController.popoverPresentationController? = co
        // to specify the position where the popover start which is in the camera button
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let cameraAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                
                if self.savedPhotosAvailable() {
                    
                    self.videoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
                    
                }
                
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Camera", style: .default) { _ in
            
            DispatchQueue.main.async {
                self.videoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
                
            }
           
        }
        
        alertController.addAction(photoLibraryAction)
        
        
        guard let indexSelected = selectedIndexPath?.row else {return}
        if arrayDayCell[indexSelected].image != nil {
                // only if arraydacell.image is populated add this alert action
                
                let deleteAction = UIAlertAction(title: "Delete Video", style: .destructive)
                { _ in
                    
                    if let indexSelected = self.selectedIndexPath?.row {
                        let dateDayCell = self.arrayDayCell[indexSelected].date
                        
                        for i in self.dataManager.arrayMyData {
                            let dateMyData = i.date
                            
                            let order = Calendar.current.compare(dateDayCell, to: dateMyData, toGranularity: .day)
                            
                            if order == .orderedSame {
                                self.dataManager.remove(i)
                                self.loadTheData()
                            }
                        }
                    }
                }
                
                alertController.addAction(deleteAction)
                 
            }
            
        
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
}

// MARK: - CALENDAR DATA GENERATION
extension HomeVC {
    
    func loadTheData() {
        
        arrayDayCell = [DayCell]()
        
        getCurrentMonthArray(of: baseDate)
        getImageInArrayDayCell()
        //addOffsetPreviuosMonth()
        //getTodaySelected()
        collectionView.reloadData()
    }
    
    func getCurrentMonthArray(of dateInput: Date) {
        
        //get number of days in the month
        guard
            
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: dateInput)?.count,
            
                let firstDayOfMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month, .hour], from: dateInput))
                
        else {
            fatalError("calendar generation fatal error")
        }
        for i in 0..<numberOfDaysInMonth {
            
            let nextDate = calendar.date(byAdding: .day, value: i, to: firstDayOfMonth)!
            
            let element = DayCell(date: nextDate, image: nil)
            
            arrayDayCell.append(element)
        }
        
    }
    
    func getImageInArrayDayCell() {
        for x in 0..<arrayDayCell.count {
            let date1 = arrayDayCell[x].date
            
            for y in 0..<dataManager.arrayMyData.count {
                let date2 = dataManager.arrayMyData[y].date
                
                let order = Calendar.current.compare(date1, to: date2, toGranularity: .day)
                
                switch order {
                case .orderedSame:
                    let nameVideo = dataManager.arrayMyData[y].nameVideo
                    
                    let image =  self.dataManager.generateThumbnail(fromMovie: nameVideo)
                    arrayDayCell[x].image = image
                    
                    
                default: break
                }
            }
        }
    }
    
    func getTodaySelected() {
        let today = Date()
        
        let dF = DateFormatter()
        
        dF.dateFormat = "dd"
        let day = dF.string(from: today)
        
        dF.dateFormat = "MMMM"
        let month = dF.string(from: today)
        
        dF.dateFormat = "yyyy"
        let year = dF.string(from: today)
        
        
        if
            arrayDayCell.isEmpty == false &&
                arrayDayCell[0].year == year &&
                arrayDayCell[0].month == month &&
                arrayDayCell[(Int(day)!-1)].day == day {
          
        }
        
        
        
        
    }
    
    
    
    
}


//MARK: - savedPhotosAvailable
extension HomeVC {
    
    func savedPhotosAvailable() -> Bool {
        guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        else { return true }
        
        let alert = UIAlertController(
            title: "Not Available",
            message: "No Saved Album found",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        present(alert, animated: true, completion: nil)
        return false
    }
}


//MARK: UIImagePickerControllerDelegate
extension HomeVC: UIImagePickerControllerDelegate {

    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        else { return }
        
        //      let avAsset = AVAsset(url: url)
        
        
        
        if selectedIndexPath != nil {
            
            //save video in file manager and the new url in the array
            dataManager.saveVideoInDocuments(url: url, date: baseDate)
              
        }
      
        let alert = UIAlertController(
            title: "Video Loaded",
            message: "press ok to continue",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        
        print ("dataManager.arrayMyData", dataManager.arrayMyData)
        present(alert, animated: true, completion: loadTheData)
    }
    
    
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alert.view.layoutIfNeeded() // to make it faster to load
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
