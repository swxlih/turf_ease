class Usermodel {
  String? uid;
  String? name;
  String? role;
  String? turfname;
  String? email;
  String? number;
  String? city;
  List<String>? citylist;
  String? address;
  String? morningRate; // 🆕 added
  String? eveningRate; // 🆕 added
  String? turfimage;
  String? createdAt;
  String? timeStamp;

  // Default features and game categories
  Map<String, bool> features;
  Map<String, bool> gameCategories;

  Usermodel({
    this.uid,
    this.name,
    this.role,
    this.turfname,
    this.email,
    this.number,
    this.city,
    this.citylist,
    this.address,
    this.morningRate,
    this.eveningRate,
    this.turfimage,
    this.createdAt,
    this.timeStamp,
    Map<String, bool>? features,
    Map<String, bool>? gameCategories,
  })  : features = features ??
            {
              "bathroom": false,
              "restArea": false,
              "parking": false,
              "shower": false,
            },
        gameCategories = gameCategories ??
            {
              "Football": false,
              "Cricket": false,
              "Badminton": false,
            };

  factory Usermodel.fromJson(Map<String, dynamic> json) => Usermodel(
        uid: json["uid"],
        name: json["name"],
        role: json["role"],
        turfname: json["turfname"],
        email: json["email"],
        number: json["number"],
        city: json["city"],
        citylist: json["citylist"] == null
            ? []
            : List<String>.from(json["citylist"].map((x) => x)),
        address: json["address"],
        morningRate: json["morningRate"], // 🆕 added
        eveningRate: json["eveningRate"], // 🆕 added
        turfimage: json["turfimage"],
        createdAt: json["createdAt"],
        timeStamp: json["timeStamp"],
        features: json["features"] == null
            ? {
                "bathroom": false,
                "restArea": false,
                "parking": false,
                "shower": false,
              }
            : Map<String, bool>.from(json["features"]),
        gameCategories: json["game categories"] == null
            ? {
                "Football": false,
                "Cricket": false,
                "Badminton": false,
              }
            : Map<String, bool>.from(json["game categories"]),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "role": role,
        "turfname": turfname,
        "email": email,
        "number": number,
        "city": city,
        "citylist":
            citylist == null ? [] : List<dynamic>.from(citylist!.map((x) => x)),
        "address": address,
        "morningRate": morningRate, // 🆕 added
        "eveningRate": eveningRate, // 🆕 added
        "turfimage": turfimage,
        "createdAt": createdAt,
        "timeStamp": timeStamp,
        "features": features,
        "game categories": gameCategories,
      };
}
