 import 'package:medical_app/UserApp/Homepage/model/card_model.dart';

List<CardModel> turflist = [
    CardModel(
      turfname: "Mud Turf",
      address: "Angadipuram",
      rate: 700,
      imageUrl:
          "https://5.imimg.com/data5/SELLER/Default/2022/12/FS/AR/TM/47983915/mud-football-turf.jpeg",
    ),
    CardModel(
      turfname: "Lakana Club",
      address: "Pattikkad",
      rate: 800,
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSd8b9Y9GlcGGO2qKpHVEsCrA2TtxCqPEO7Lw&s",
    ),
    CardModel(
      turfname: "Garima Sports",
      address: "Calicut Road",
      rate: 750,
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4gVx04zpuJkjN8QW1Rf4YWHpJqMsI8G3s8Q&s",
    ),
    CardModel(
      turfname: "Pk Sloapy",
      address: "Angadippuram",
      rate: 600,
      imageUrl:
          "https://d26dp53kz39178.cloudfront.net/media/uploads/products/ZeeZoo1.jpg",
    ),
    CardModel(
      turfname: "Cricket Turf",
      address: "Angadipuram",
      rate: 700,
      imageUrl:
          "https://5.imimg.com/data5/SELLER/Default/2022/9/FJ/LX/DE/11336583/box-cricket-ground-constrcution.jpg",
    ),

    CardModel(
      turfname: "Garima Sports",
      address: "Calicut Road",
      rate: 750,
      imageUrl:
          "https://content.jdmagicbox.com/comp/def_content/mini-football-fields/mini-football-fields-1-mini-football-fields-1-gi722.jpg",
    ),
    CardModel(
      turfname: "Sloapy Cluppy",
      address: "Pattikkad",
      rate: 650,
      imageUrl:
          "https://turftown.in/_next/image?url=https%3A%2F%2Fturftown.s3.ap-south-1.amazonaws.com%2Fsuper_admin%2Ftt-1744394552699.webp&w=828&q=75",
    ),
    CardModel(
      turfname: "Pk Sloapy",
      address: "Angadippuram",
      rate: 600,
      imageUrl:
          "https://turftown.in/_next/image?url=https%3A%2F%2Fturftown.s3.ap-south-1.amazonaws.com%2Fsuper_admin%2Ftt-1744394552699.webp&w=828&q=75",
    ),
  ];

  // Add this list inside your _HomePageState
  final List<String> categories = [
    "Football",
    "Tennis",
    "Badminton",
    "Cricket",
    "Hockey",
  ];


  int selectedIndex = 0;

  List<CardModel> filteredTurfs = [];