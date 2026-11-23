
class PrevisionJour {
  final DateTime date;
  final double tMax;
  final double tMin;
  final double pluie;

  const PrevisionJour({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.pluie,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tMax': tMax,
      'tMin': tMin,
      'pluie': pluie,
    };
  }

  factory PrevisionJour.fromJson(Map<String, dynamic> json) {
    return PrevisionJour(
      date: DateTime.parse(json['date'] as String),
      tMax: (json['tMax'] as num).toDouble(),
      tMin: (json['tMin'] as num).toDouble(),
      pluie: (json['pluie'] as num).toDouble(),
    );
  }
}

class Meteo {
  final double temperature;
  final int humiditeAir;
  final double vent;
  final List<PrevisionJour> previsions;

  const Meteo({
    required this.temperature,
    required this.humiditeAir,
    required this.vent,
    required this.previsions,
  });

  double get pluieTotale =>
      previsions.fold(0.0, (somme, p) => somme + p.pluie);

  // JSON utilisé pour le stockage local
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humiditeAir': humiditeAir,
      'vent': vent,
      'previsions': previsions.map((p) => p.toJson()).toList(),
    };
  }

  // Lecture des données originales de l'API Open-Meteo
  factory Meteo.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final tMax = daily['temperature_2m_max'] as List<dynamic>;
    final tMin = daily['temperature_2m_min'] as List<dynamic>;
    final pluie = daily['precipitation_sum'] as List<dynamic>;

    final List<PrevisionJour> previsions = [];

    for (var i = 0; i < dates.length; i++) {
      previsions.add(
        PrevisionJour(
          date: DateTime.parse(dates[i] as String),
          tMax: (tMax[i] as num).toDouble(),
          tMin: (tMin[i] as num).toDouble(),
          pluie: (pluie[i] as num).toDouble(),
        ),
      );
    }

    return Meteo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humiditeAir:
      (current['relative_humidity_2m'] as num).round(),
      vent: (current['wind_speed_10m'] as num).toDouble(),
      previsions: previsions,
    );
  }

  // Lecture des données sauvegardées dans SharedPreferences
  factory Meteo.fromCacheJson(Map<String, dynamic> json) {
    return Meteo(
      temperature: (json['temperature'] as num).toDouble(),
      humiditeAir: (json['humiditeAir'] as num).toInt(),
      vent: (json['vent'] as num).toDouble(),
      previsions: (json['previsions'] as List)
          .map(
            (p) => PrevisionJour.fromJson(
          Map<String, dynamic>.from(p as Map),
        ),
      )
          .toList(),
    );
  }
}

