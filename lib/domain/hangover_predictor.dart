import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'bac/bac_entry.dart';
import 'diary/diary_entry.dart';
import 'diary/hangover_severity.dart';
import 'linear_regressor.dart';

class HangoverSeverityPredictor {
  static Future<HangoverSeverityPredictor> createFromBundle(AssetBundle bundle, String assetName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = File('${directory.path}/model_params.json');

    if (await path.exists()) {
      final raw = await path.readAsString();
      final model = LinearRegressor.fromJSON(raw);
      return HangoverSeverityPredictor(model);
    } else {
      final raw = bundle.loadString(assetName);
      final model = LinearRegressor.fromJSON(await raw);
      return HangoverSeverityPredictor(model);
    }
  }

  final LinearRegressor _model;

  HangoverSeverityPredictor(this._model);

  HangoverSeverity predict(DiaryEntry diaryEntry, BACEntry maxBAC) {
    final features = [
      diaryEntry.stomachFullness!.index.toDouble(),
      diaryEntry.drinkingDuration.inMinutes.toDouble(),
      diaryEntry.glassesOfWater.toDouble(),
      diaryEntry.gramsOfAlcohol.toDouble(),
      maxBAC.value,
    ];

    final prediction = _model.predict(features);

    // Since we're using a linear model we need to clamp the prediction to the enum range
    final index = prediction.clamp(0, HangoverSeverity.values.length - 1).round();

    return HangoverSeverity.values[index];
  }

  void fitToNewData(DiaryEntry diaryEntry, BACEntry maxBAC, HangoverSeverity severity) {
    final features = [
      diaryEntry.stomachFullness!.index.toDouble(),
      diaryEntry.drinkingDuration.inMinutes.toDouble(),
      diaryEntry.glassesOfWater.toDouble(),
      diaryEntry.gramsOfAlcohol.toDouble(),
      maxBAC.value,
    ];

    _model.update(features, severity.index.toDouble());
  }

  Future<void> save() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = File('${directory.path}/model_params.json');

    await path.writeAsString(_model.toJSON());
  }
}
