//
//  ViewController.swift
//  MapLocationProject
//
//  Created by Bruna Fernanda Drago on 29/06/20.
//  Copyright © 2020 Bruna Fernanda Drago. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    //Properties
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    var previousLocation : CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //após a tela carregar , este método verifica se o app tem a autorização que precisa
        checkLocationService()
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Método que verifica se o app tem a autorização do usuário para acessar sua localização
    func checkLocationService(){
        
        if CLLocationManager.locationServicesEnabled(){
            //Quando a autorização está habilitada
            setUpLocationManager()
            checkLocationAuthorization()
        }
        else{
            //exibir um alerta informando o usuário que o serviço de localização está desabilitado
        }
    }
  
    //Método que verifica se o app tem a autorização do usuário para acessar sua localização e implementa o código de acordo com cada situação
    func checkLocationAuthorization(){
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            //mostrar um alerta mostrando como autoriza
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //mostrar um alerta mostrando o que aconteceu
            break
        case .authorizedAlways:
            break
        }
    }
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView)-> CLLocation{
      
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }

}

extension ViewController:CLLocationManagerDelegate{
    
    //Toda vez que a localização do usuário atualiza, este método ajusta o mapView de acordo, como você mostra a localização do usuário em um mapa e faz a atualização quando ela muda.
  /*  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
        
    }*/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       checkLocationAuthorization()
    }
}

extension ViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else{return}
        
        guard center.distance(from: previousLocation) > 50 else{return}
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self](placemark, error) in
            
            guard let self = self else{return}
            
            if let _ = error {
                //Se ocorrer um erro , mostrar um alerta informando o usuario
                return
            }
            guard let placemark = placemark?.first else{
                //Mostrar um alerta avisando o usuário
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetName),\(streetNumber)"
            }
        }
    }
}
