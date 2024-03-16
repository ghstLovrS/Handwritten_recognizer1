//lib/models/prediction.dart
class Prediction {
  final double confidence;
  final int index;
  final String label;

  Prediction({this.confidence = 0.0, this.index = 0, this.label = ''});

  factory Prediction.fromJson(Map<dynamic, dynamic> json) {
    return Prediction(
      confidence: json['confidence'] ?? 0.0,
      index: json['index'] ?? 0,
      label: json['label'] ?? '',
    );
  }
}
