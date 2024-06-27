
class RecipeRecognition {
  List<RecognitionResults>? recognitionResults;
  RecipeRecognition({
    this.recognitionResults,
  });

  RecipeRecognition.fromJson(Map<String, dynamic> json) {

    if (json['recognition_results'] != null) {
      recognitionResults = <RecognitionResults>[];
      json['recognition_results'].forEach((v) {
        recognitionResults!.add(RecognitionResults.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};


    if (recognitionResults != null) {
      data['recognition_results'] =
          recognitionResults!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class RecognitionResults {
  String? name;
  double? prob;

  RecognitionResults({
    this.name,
    this.prob,
  });

  RecognitionResults.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    prob = json['prob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['prob'] = prob;
    return data;
  }
}
