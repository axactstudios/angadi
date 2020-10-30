part of values;

class Gradients {
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment(0.5, 1),
    end: Alignment(0.51711, -0.06443),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(0, 255, 255, 255),
      Color.fromARGB(66, 0, 0, 0),
    ],
  );
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment(0.9661, 0.5),
    end: Alignment(0, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 86, 115),
      Color.fromARGB(255, 255, 140, 72),
    ],
  );

  static const Gradient secondaryGradient2 = LinearGradient(
    begin: Alignment(0, 1.0),
    end: Alignment(1.0, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
//      AppColors.secondaryElement,
//      AppColors.secondaryElement,
      Color(0xFF6b3600), Color(0xFF6b3600)
    ],
  );
  static const Gradient fullScreenOverGradient = LinearGradient(
    begin: Alignment(0.51436, 1.07565),
    end: Alignment(0.51436, -0.03208),
    stops: [
      0,
      0.25098,
      1,
    ],
    colors: [
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 17, 17, 17),
      Color.fromARGB(105, 45, 45, 45),
    ],
  );

  static const Gradient footerOverlayGradient = LinearGradient(
    begin: Alignment(0.51436, 1.07565),
    end: Alignment(0.51436, -0.03208),
    stops: [
      0,
      0.17571,
      1,
    ],
    colors: [
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 8, 8, 8),
      Color.fromARGB(105, 45, 45, 45),
    ],
  );

  static const Gradient restaurantDetailsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(0, 0, 0, 0.39),
      Color.fromRGBO(255, 255, 255, 0),
      Color.fromRGBO(0, 0, 0, 0.43),
//      Color.fromARGB(105, 45, 45, 45),
//      Color(0x00000000),
//      Color(0xFFFFFFff),
//      Color(0x0000006E),
    ],
  );
  static const Gradient italianGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient chineseGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient mexicanGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient thaiGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient arabianGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient indianGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient americanGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
  static const Gradient koreanGradient = LinearGradient(
    colors: [
      Color(0xFFFFB303),
      Color(0xFFFFB303),
    ],
  );
}
