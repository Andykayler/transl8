import 'package:flutter/material.dart';
import 'package:flutter_samples/samples/ui/rive_app/components/hcard.dart';
import 'package:flutter_samples/samples/ui/rive_app/components/vcard.dart';
import 'package:flutter_samples/samples/ui/rive_app/models/courses.dart';

import 'package:flutter_samples/samples/ui/rive_app/theme.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<TranslationModel> _languagePairs = TranslationModel.languagePairs;
  final List<TranslationModel> _translationTopics = TranslationModel.translationTopics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: RiveAppTheme.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
              bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Language Pairs",
                  style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _languagePairs
                      .map(
                        (pair) => Padding(
                          key: pair.id,
                          padding: const EdgeInsets.all(10),
                          child: VCard(translation: pair),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Text(
                  "Topics",
                  style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  children: List.generate(
                    _translationTopics.length,
                    (index) => Container(
                      key: _translationTopics[index].id,
                      width: MediaQuery.of(context).size.width > 992
                          ? ((MediaQuery.of(context).size.width - 20) / 2)
                          : MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: HCard(section: _translationTopics[index]),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
