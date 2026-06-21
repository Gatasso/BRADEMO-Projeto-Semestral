import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String? get apiUrl {
    return dotenv.env['API_URL'];
  }

  static String? get defaultUserPassword {
    return dotenv.env['DEFAULT_USER_PASSWORD'];
  }

  static String? get flaskEnv {
    return dotenv.env['FLASK_ENV'];
  }
}
