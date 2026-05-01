class Country {
  final String name;
  final String flag;
  final String region;
  final String capital;
  final int population;
  final Map<String, dynamic> currencies;
  final Map<String, dynamic> languages;
  final double area;
  final List<dynamic> timezones;
  final String alpha3Code;

  const Country({
    required this.name,
    required this.flag,
    required this.region,
    required this.capital,
    required this.population,
    required this.currencies,
    required this.languages,
    required this.area,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: (json['name'] as Map<String, dynamic>?)?['common'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
      region: json['region'] as String? ?? '',
      capital: (json['capital'] is List && (json['capital'] as List).isNotEmpty)
          ? (json['capital'] as List).first as String
          : 'N/A',
      population: json['population'] as int? ?? 0,
      currencies: json['currencies'] as Map<String, dynamic>? ?? <String, dynamic>{},
      languages: json['languages'] as Map<String, dynamic>? ?? <String, dynamic>{},
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      timezones: json['timezones'] as List<dynamic>? ?? <dynamic>[],
      alpha3Code: json['cca3'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'flag': flag,
      'region': region,
      'capital': capital,
      'population': population,
      'currencies': currencies,
      'languages': languages,
      'area': area,
      'timezones': timezones,
      'alpha3Code': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flag,
    String? region,
    String? capital,
    int? population,
    Map<String, dynamic>? currencies,
    Map<String, dynamic>? languages,
    double? area,
    List<dynamic>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flag: flag ?? this.flag,
      region: region ?? this.region,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
