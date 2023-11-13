import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weatherapp/constant.dart';

class ImageServices{
  Future<String> getImage(String query) async{
    var url = Uri.parse(
        'https://api.unsplash.com/search/photos/?client_id=$imageapikey&query=$query&orientation=portrait&order_by=revelant&color=black');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String,dynamic>;
      return data['results'][0]['urls']['raw'];
    }
    else{
      throw Exception('failed to load data');
    }
  }
}