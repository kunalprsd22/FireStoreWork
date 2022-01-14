//
//  ThirdVC.swift
//  Demo
//
//  Created by Appinventiv on 9/12/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import Contacts
import AVFoundation
import SwiftSVG
import CoreLocation
import FirebaseFirestore
import GeoFire


// 1000 = 1 KM in CLLocationDistance

class ThirdVC: UIViewController {
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        FireStoreHelper.shared.sendDriverCoodinateToFireStore()
    }
    
    
    @IBAction func getPoints(_ sender: Any) {
        observeChanges()
    }
    
    func observeChanges(){
        let center = CLLocationCoordinate2D(latitude: 40.41486, longitude: -3.70683)
        let docRef = db.collection("drivers")
        let radiusInM: Double = 5000
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
        
        let queries = queryBounds.map { bound -> Query in
            return db.collection("drivers")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        var matchingDocs = [QueryDocumentSnapshot]()
        // Collect all the query results together into a single list
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            for document in documents {
                if let geoPoint = document.data()["geopoint"] as? GeoPoint{
                    let lat = geoPoint.latitude
                    let lng = geoPoint.longitude
                    let coordinates = CLLocation(latitude: lat, longitude: lng)
                    let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
                    
                    // We have to filter out a few false positives due to GeoHash accuracy, but
                    // most will match
                    let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                    print("distance  ", distance)
                    if distance <= radiusInM {
                        matchingDocs.append(document)
                        print(document.documentID)
                    }
                }
            }
        }
        
        // After all callbacks have executed, matchingDocs contains the result. Note that this
        // sample does not demonstrate how to wait on all callbacks to complete.
        for query in queries {
            query.getDocuments(completion: getDocumentsCompletion)
            query.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New city: \(diff.document.data())" , " ","documentId", diff.document.documentID)
                    }
                    if (diff.type == .modified) {
                        print("Modified city: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data())")
                    }
                }
            }
        }
    }
    
    
    func observeChangesInUserCollection(){
        db.collection("Users").whereField("isActive", isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New city: \(diff.document.data())")
                    }
                    if (diff.type == .modified) {
                        print("Modified city: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data())")
                    }
                }
            }
    }
    
}


