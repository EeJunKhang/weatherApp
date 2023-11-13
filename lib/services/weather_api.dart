import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weatherapp/constant.dart';
import 'package:weatherapp/modal/forecast_weather_modal.dart';
import 'package:weatherapp/modal/weather_modal.dart';

class WeatherServices {
  Future<CurrentWeatherModal> getCurrentWeather(String location) async {
    var url = Uri.https('api.weatherapi.com', '/v1/current.json',
        {'key': weatherapikey, 'q': location, 'aqi': 'no'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return CurrentWeatherModal.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else if(response.statusCode == 400){
      throw Exception('Invalid city name');
    }
    else{
      throw Exception('Failed to load data');
    }
  }

  Future<ForecastWeatherModal> getForecastWeather(String location) async {
    var url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$weatherapikey&q=$location&days=4&aqi=no&alerts=no');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return ForecastWeatherModal.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
