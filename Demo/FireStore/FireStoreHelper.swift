//
//  FireStore.swift
//  Demo
//
//  Created by Admin on 13/01/22.
//  Copyright © 2022 Appinventiv. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import GeoFire

class FireStoreHelper {
    
    static let shared = FireStoreHelper()
    var db = Firestore.firestore()
    
    //MARK: - Sent Updated Lat long data to FireSotre
    func sendDriverCoodinateToFireStore(){
        
        let coodinate = CLLocationCoordinate2D(latitude: 40.41785727186494, longitude: -3.697110638022423)
        let geoPoint = GeoPoint(latitude: coodinate.latitude , longitude: coodinate.longitude)
        let geoHash = GFUtils.geoHash(forLocation: coodinate)
        let documentId = "13131318"
        let params = ["name":"mumbai11","geopoint":geoPoint,"geohash":geoHash] as [String : Any]
        db.collection("drivers").document(documentId).setData(params) { error in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    

    
    func nearByQuery(){
        let location = CLLocationCoordinate2D(latitude: 40.41486, longitude: -3.70683)
        let radius = 100
        let (maxCoord, minCoord) =  location.boundingBox(radius: CLLocationDistance(radius))
        
        let maxPoint = GeoPoint(
            latitude: maxCoord.latitude,
            longitude: maxCoord.longitude
        )
        let minPoint = GeoPoint(
            latitude: minCoord.latitude,
            longitude: minCoord.longitude
        )
        
        let docRef = db.collection("drivers")
        let query = docRef
            .whereField("geopoint", isGreaterThan: minPoint)
            .whereField("geopoint", isLessThan: maxPoint)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        
    }
    
    func sendUserData(){
        
        let documentId = "103"
        let params = ["isActive":true]
        db.collection("Users").document(documentId).setData(params) { error in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
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
    
}


extension CLLocationCoordinate2D {
    func boundingBox(radius: CLLocationDistance) -> (max: CLLocationCoordinate2D, min: CLLocationCoordinate2D) {
        // 0.0000089982311916 ~= 1m
        let offset = 0.0000089982311916 * radius
        let latMax = self.latitude + offset
        let latMin = self.latitude - offset
        
        // 1 degree of longitude = 111km only at equator
        // (gradually shrinks to zero at the poles)
        // So need to take into account latitude too
        let lngOffset = offset * cos(self.latitude * .pi / 180.0);
        let lngMax = self.longitude + lngOffset;
        let lngMin = self.longitude - lngOffset;
        
        
        let max = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        let min = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
        
        return (max, min)
    }
    
    func isWithin(min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) -> Bool {
        return
            self.latitude > min.latitude &&
                self.latitude < max.latitude &&
                self.longitude > min.longitude &&
                self.longitude < max.longitude
    }

    
}
