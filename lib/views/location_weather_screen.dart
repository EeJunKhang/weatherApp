import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/modal/forecast_weather_modal.dart';
import 'package:weatherapp/modal/weather_modal.dart';
import 'package:weatherapp/services/image_api.dart';
import 'package:weatherapp/services/weather_api.dart';
import 'package:weatherapp/widgets/text_widget.dart';

class LocationWeatherPage extends StatefulWidget {
  final CurrentWeatherModal weatherModal;
  // final ForecastWeatherModal forecastweatherModal;

  const LocationWeatherPage({super.key, required this.weatherModal});

  @override
  State<LocationWeatherPage> createState() => _LocationWeatherPageState();
}

class _LocationWeatherPageState extends State<LocationWeatherPage> {
  final WeatherServices _weatherServices = WeatherServices();
  final ImageServices _imageServices = ImageServices();

  @override
  void initState() {
    // print(widget.weatherModal.location.name +
    //     widget.weatherModal.current.condition.text);
    super.initState();
  }

  Future<String> fetchImageData() async {
    var temp = await _imageServices.getImage(
        "${widget.weatherModal.location.name} ${widget.weatherModal.current.condition.text} scenery");
    return temp;
  }

  Future<ForecastWeatherModal> fetchForecastWeatherData() async {
    return await _weatherServices
        .getForecastWeather(widget.weatherModal.location.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 59, 132),
      body: Stack(
        children: [
          FutureBuilder(
            future: fetchImageData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              return CachedNetworkImage(
                imageUrl: snapshot.data!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          buildMainScreen(),
        ],
      ),
    );
  }

  Widget buildMainScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  widget.weatherModal.location.name,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                color: Colors.white,
                icon: const Icon(
                  Icons.list,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            DateFormat('E d').format(DateTime.now()).toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Updated as of ${widget.weatherModal.current.lastUpdated}",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Image.network(
            'https:${widget.weatherModal.current.condition.icon}',
            scale: 0.55,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            widget.weatherModal.current.condition.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            "${widget.weatherModal.current.tempC.toInt()}\u00B0\u1d9c",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 55.9,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 35,
          ),
          buildWeatherConditionBox(),
          const SizedBox(
            height: 25,
          ),
          buildForecastWeatherBox(),
        ],
      ),
    );
  }

  Widget buildForecastWeatherBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        color: Colors.grey.withOpacity(0.5),
      ),
      child: FutureBuilder(
        future: fetchForecastWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final forecastData = snapshot.data!;

          List<Widget> columns = [];

          for (int i = 0; i < forecastData.forecast.forecastday.length; i++) {
            columns.add(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  coloredText(
                    DateFormat('E d')
                        .format(forecastData.forecast.forecastday[i].date),
                    15,
                  ),
                  Image.network(
                      'https:${forecastData.forecast.forecastday[i].day.condition.icon}'),
                  coloredText(
                      "${forecastData.forecast.forecastday[i].day.avgtempC}\u2103",
                      15),
                  coloredText(
                      "${forecastData.forecast.forecastday[i].day.maxwindKph}km/h",
                      15),
                ],
              ),
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: columns,
          );
        },
      ),
    );
  }

  Widget buildWeatherConditionBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Colors.white,
                size: 35,
              ),
              coloredText('HUMIDITY', 15),
              coloredText("${widget.weatherModal.current.humidity}%", 15),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.air,
                color: Colors.white,
                size: 35,
              ),
              coloredText('WIND', 15),
              coloredText("${widget.weatherModal.current.windKph}km/h", 15),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.device_thermostat_outlined,
                color: Colors.white,
                size: 35,
              ),
              coloredText('FEELS LIKE', 15),
              coloredText(
                  "${widget.weatherModal.current.feelslikeC}\u2103", 15),
            ],
          )
        ],
      ),
    );
  }
}
