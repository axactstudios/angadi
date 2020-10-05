import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  Future<void> saveText(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
    print('setting ' + key + '  as ' + value);
  }

  Future<String> getText(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String value = pref.get(key);
    return value;
  }

  Future<void> setList(String key, List<String> value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(key, value);
    print('$key saved!');
  }

  Future<List<String>> getList(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList(key);
    return list;
  }

  Future<void> clear() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear().then((value) => print('shared preferences cleared!'));
  }
}
