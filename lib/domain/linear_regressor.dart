import 'dart:convert';

import 'package:collection/collection.dart';

class LinearRegressor {
  List<double> _coefficients;
  double _intercept;

  final List<double> _mean;
  final List<double> _stdDev;

  final double _learningRate;

  LinearRegressor(this._coefficients, this._intercept, this._mean, this._stdDev, {double learningRate = 0.01})
      : assert(_coefficients.length == _mean.length && _coefficients.length == _stdDev.length),
        _learningRate = learningRate;

  double predict(List<double> features) {
    assert(features.length == _coefficients.length, 'Feature length must match coefficient length');

    final scaledFeatures = _scaleFeatures(features);
    return _coefficients.mapIndexed((i, e) => e * scaledFeatures[i]).sum + _intercept;
  }

  void update(List<double> features, double target) {
    assert(features.length == _coefficients.length, 'Feature length must match coefficient length');

    final prediction = predict(features);
    final error = target - prediction;

    final scaledFeatures = _scaleFeatures(features);
    _coefficients = _coefficients.mapIndexed((i, e) => e + _learningRate * error * scaledFeatures[i]).toList();
    _intercept += _learningRate * error;
  }

  List<double> _scaleFeatures(List<double> features) {
    return features.mapIndexed((i, e) => (e - _mean[i]) / _stdDev[i]).toList();
  }

  String toJSON() {
    final modelData = {
      'coefficients': _coefficients,
      'intercept': _intercept,
      'scaling_parameters': {
        'mean': _mean,
        'std': _stdDev,
      }
    };

    return jsonEncode(modelData);
  }

  static LinearRegressor fromJSON(String json) {
    final data = jsonDecode(json);

    return LinearRegressor(
      List<double>.from(data['coefficients']),
      data['intercept'],
      List<double>.from(data['scaling_parameters']['mean']),
      List<double>.from(data['scaling_parameters']['std']),
    );
  }
}
