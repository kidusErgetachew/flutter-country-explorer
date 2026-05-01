import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';

class DetailScreen extends StatelessWidget {
  final String code;

  const DetailScreen({super.key, required this.code});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final country = snapshot.data!;

            final timezonesStr = country.timezones.join(', ');
            final languagesStr = country.languages.values.join(', ');
            final currenciesStr = country.currencies.values
                .map((v) => (v is Map && v.containsKey('name'))
                    ? v['name'].toString()
                    : v.toString())
                .join(', ');

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
