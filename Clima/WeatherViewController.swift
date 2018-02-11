//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "9b14215db8e143d72f93611413de274a"

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var weatherDataModelObject = WeatherDataModel()

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, param: [String:String]){
        Alamofire.request(url, method: .get, parameters: param).responseJSON {
            response in
            //Whenever you see an 'in,' it means that you are in a closure.
            if response.result.isSuccess {
                print("Success! Got the weather data")
                //This actually comes from SwiftyJSON
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error: \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/

    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double {
            weatherDataModelObject.temperature = Int(tempResult - 273.15)
            weatherDataModelObject.city = json["name"].stringValue
            weatherDataModelObject.condition = json["weather"][0]["id"].intValue
            weatherDataModelObject.weatherIconName = weatherDataModelObject.updateWeatherIcon(condition: weatherDataModelObject.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModelObject.city
        temperatureLabel.text = String(weatherDataModelObject.temperature) + "°"
        weatherIcon.image = UIImage(named: weatherDataModelObject.weatherIconName)
        
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil;
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, param: params)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }

}


