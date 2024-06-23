import 'package:flutter/material.dart';
import 'package:flutter_samples/samples/ui/rive_app/assets.dart' as app_assets;

class TranslationModel {
  TranslationModel({
    this.id,
    this.languagePair = "",
    this.description = "",
    this.examples = "",
    this.color = Colors.white,
    this.image = "",
  });

  UniqueKey? id = UniqueKey();
  String languagePair, description, examples, image;
  Color color;

  static List<TranslationModel> languagePairs = [
    TranslationModel(
      languagePair: "English - Chichewa",
      description: "Common phrases and vocabulary",
      examples: "Hello - Moni, Thank you - Zikomo",
      color: const Color(0xFF7850F0),
      image: app_assets.topic_1,
    ),
    TranslationModel(
      languagePair: "Chichewa - English",
      description: "Basic grammar and conjugation",
      examples: "Moni - Hello, Zikomo - Thank you",
      color: const Color(0xFF6792FF),
      image: app_assets.topic_2,
    ),
   
  ];

  static List<TranslationModel> translationTopics = [
    TranslationModel(
      languagePair: "Chichewa",
      color: const Color(0xFF9CC5FF),
      image: app_assets.topic_2,
    ),

      TranslationModel(
      languagePair: "Tumbuka",

      color: const Color(0xFF40E0D0),
      image: app_assets.topic_2,
    ),

    TranslationModel(
      languagePair: "Korean ",
      
      color: const Color(0xFFBBA6FF),
      image: app_assets.topic_2,
    ),
  ];
}
