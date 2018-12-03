//
//  ViewController.swift
//  WeatherApp
//
//  Template provided by Angela Yu.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "67e83e3e0ab77bc559dab9a1cbdc7d95"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        initApp()
        
        
    }
    
    func initApp() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //accuracy range
        locationManager.requestWhenInUseAuthorization()                     // Asking permission to access location
        locationManager.startUpdatingLocation()                             // Grabing location
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    func getWeatherData(url : String, parameters : [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json : weatherJSON)
                
                print(weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    func updateWeatherData(json : JSON) {
        
        if json["main"]["temp"].double != nil {
            weatherDataModel.temperature = Int(json["main"]["temp"].double! - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather Unavailable"

        }
        
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData () {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1] // last estimated location - most accurate
        
        //valid location
        if location.horizontalAccuracy > 0 {
            // stop updating location
            locationManager.stopUpdatingLocation()
            // stop taking data once a valid location is found
            locationManager.delegate = nil
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            print("\(location.coordinate.longitude) \(location.coordinate.latitude)")
            
            // dictionary with coordinates and apid to inject to the link
            let params : [String : String] = ["lat" : String(latitude), "lon" : String(longitude), "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    // No location detected
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
    
    
    
    
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appID" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserChangesCity" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            // set WeatherViewController as a delegate of ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
    
    
    
}


