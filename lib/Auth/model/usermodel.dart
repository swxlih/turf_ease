// To parse this JSON data, do
//
//     final usermodel = usermodelFromJson(jsonString);

import 'dart:convert';

Usermodel usermodelFromJson(String str) => Usermodel.fromJson(json.decode(str));

String usermodelToJson(Usermodel data) => json.encode(data.toJson());

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
    String? rateperhour;
    String? createdAt;

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
        this.rateperhour,
        this.createdAt,
    });

    factory Usermodel.fromJson(Map<String, dynamic> json) => Usermodel(
        uid: json["uid"],
        name: json["name"],
        role: json["role"],
        turfname: json["turfname"],
        email: json["email"],
        number: json["number"],
        city: json["city"],
        citylist: json["citylist"] == null ? [] : List<String>.from(json["citylist"]!.map((x) => x)),
        address: json["address"],
        rateperhour: json["rateperhour"],
        createdAt: json["createdAt"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "role": role,
        "turfname": turfname,
        "email": email,
        "number": number,
        "city": city,
        "citylist": citylist == null ? [] : List<dynamic>.from(citylist!.map((x) => x)),
        "address": address,
        "rateperhour": rateperhour,
        "createdAt": createdAt,
    };
}
