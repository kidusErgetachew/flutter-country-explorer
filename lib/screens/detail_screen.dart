import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';

class DetailScreen extends StatelessWidget {
  final String code;

  const DetailScreen({super.key, required this.code});

  String _getErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('Server error:')) {
      final match = RegExp(r'Server error: \d+').firstMatch(msg);
      return match != null ? match.group(0)! : msg;
    }
    if (msg.contains('No internet connection')) return 'No internet connection';
    if (msg.contains('Request timed out')) return 'Request timed out. Please try again.';
    if (msg.contains('Unexpected data format')) return 'Unexpected data format received';
    return 'An unexpected error occurred';
  }

  @override
  Widget build(BuildContext context) {
    final api = CountryApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
      ),
      body: FutureBuilder<Country>(
        future: api.fetchCountryByCode(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getErrorMessage(snapshot.error!),
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        (context as Element).markNeedsBuild();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final country = snapshot.data!;

            final timezonesStr = country.timezones.join(', ');
            final languagesStr = country.languages.values.join(', ');
            final currenciesStr = country.currencies.entries.map((e) {
              final val = e.value;
              final name = (val is Map && val.containsKey('name'))
                  ? val['name'].toString()
                  : val.toString();
              return '${e.key} ($name)';
            }).join(', ');

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: Text(
                    '${country.flag} ${country.name}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Capital: ${country.capital}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Region: ${country.region}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Population: ${country.population}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Area: ${country.area}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Timezones: $timezonesStr',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Languages: $languagesStr',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Currencies: $currenciesStr',
                    style: const TextStyle(fontSize: 18)),
              ],
            );
          }
        },
      ),
    );
  }
}
