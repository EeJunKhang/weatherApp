import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/modal/weather_modal.dart';
import 'package:weatherapp/services/weather_api.dart';
import 'package:weatherapp/views/location_weather_screen.dart';
import 'package:weatherapp/widgets/search_widget.dart';
import 'package:weatherapp/widgets/text_widget.dart';
import 'package:country_state_city/country_state_city.dart'
    as country_state_city;

class LocationListPage extends StatefulWidget {
  const LocationListPage({super.key});

  @override
  State<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final WeatherServices _weatherServices = WeatherServices();
  List<String> allLocationCities = [];
  List<String> listOfLocation = [];
  List<CurrentWeatherModal> listOfWeather = [];
  bool isDataLoaded = false;
  bool isCitiesLoaded = false;
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  @override
  void initState() {
    fetchData();
    fetchSearchLocationData();
    super.initState();
  }

  void fetchSearchLocationData() async {
    final cities = await country_state_city.getAllCities();
    allLocationCities = cities.map((city) => city.name).toList();
    isCitiesLoaded = true;
  }

  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    if (prefs.getStringList('locations') != null) {
      listOfLocation = prefs.getStringList('locations')!;
      listOfWeather = [];
      for (var cityName in listOfLocation) {
        listOfWeather.add(await _weatherServices.getCurrentWeather(cityName));
      }
    }
    isDataLoaded = true;
    setState(() {});
  }

  void addNewLocation() async {
    final result = await showSearch(
      context: context,
      delegate: SearchLocationDelegate(searchResults: allLocationCities),
    );
    if (result != null) {
      try {
        await _weatherServices.getCurrentWeather(result);
        setState(() {
          isDataLoaded = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getStringList('locations') != null) {
          var tempList = prefs.getStringList('locations');
          tempList?.add(result);
          prefs.setStringList('locations', tempList!);
        } else {
          prefs.setStringList('locations', [result]);
        }
        fetchData();
        tooltipkey.currentState?.ensureTooltipVisible();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void removeLocation(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final templist = prefs.getStringList('locations');
    final removedlocation = listOfLocation.removeAt(index);
    templist?.remove(removedlocation);
    prefs.setStringList('locations', templist!);
    listOfWeather.removeAt(index);
    setState(() {});
  }

  void searchSavedLocation() async {
    final searchResult = await showSearch(
      context: context,
      delegate: SearchLocationDelegate(searchResults: listOfLocation),
    );
    if (searchResult != null) {
      setState(() {
        isDataLoaded = false;
      });
      listOfLocation.remove(searchResult);
      List<String> newList = [searchResult, ...listOfLocation];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('locations', newList);
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final scaffoldcontext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Saved Locations",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () => searchSavedLocation(),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.blue, Color.fromARGB(255, 17, 59, 132)],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Column(
          children: <Widget>[
            isDataLoaded && isCitiesLoaded
                ? Expanded(
                    child: listOfLocation.isEmpty
                        ? const Center(
                            child: Text(
                              "No locations saved",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: listOfWeather.length,
                            itemBuilder: (context, index) {
                              return OpenContainer(
                                transitionDuration: Duration(seconds: 1),
                                closedColor: Colors.transparent,
                                closedElevation: 0,
                                closedBuilder:
                                    (context, VoidCallback openContainer) =>
                                        customCard(index, openContainer),
                                openBuilder: (context, _) =>
                                    LocationWeatherPage(
                                  weatherModal: listOfWeather[index],
                                ),
                              );
                            },
                          ),
                  )
                : const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
            addNewLocationBox(),
          ],
        ),
      ),
    );
  }

  Widget customCard(int index, VoidCallback ontapfunc) {
    return GestureDetector(
      onTap: ontapfunc,
      onLongPress: () {
        removeLocation(index);
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listOfWeather[index].location.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    coloredText(
                      listOfWeather[index].current.condition.text,
                      18,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        coloredText(
                          'Humidity ',
                          14,
                        ),
                        Text(
                          '${listOfWeather[index].current.humidity}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        coloredText(
                          'Wind',
                          14,
                        ),
                        Text(
                          ' ${listOfWeather[index].current.windKph.toString()}km/h',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Image.network(
                      'https:${listOfWeather[index].current.condition.icon}'),
                  Text(
                    '${listOfWeather[index].current.tempC.toInt()}\u2103',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addNewLocationBox() {
    return Center(
      child: GestureDetector(
        onTap: () => addNewLocation(),
        child: Tooltip(
          key: tooltipkey,
          triggerMode: TooltipTriggerMode.manual,
          showDuration: const Duration(seconds: 1),
          message: "Press and hold on a location to delete it",
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
