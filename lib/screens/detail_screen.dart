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

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _getErrorMessage(error),
                  style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Country details unavailable',
        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDetails(Country country) {
    final timezonesStr = country.timezones.join(', ');
    final languagesStr = country.languages.values.join(', ');
    final currenciesStr = country.currencies.entries.map((e) {
      final val = e.value;
      final name = (val is Map && val.containsKey('name')) ? val['name'].toString() : val.toString();
      return '${e.key} ($name)';
    }).join(', ');

    final formattedPopulation = country.population.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Center(
          child: Column(
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 8),
              Text(
                country.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildDetailRow(Icons.location_city, 'Capital', country.capital),
                _buildDetailRow(Icons.map, 'Region', country.region),
                _buildDetailRow(Icons.people, 'Population', formattedPopulation),
                _buildDetailRow(Icons.landscape, 'Area', '${country.area} km²'),
                _buildDetailRow(Icons.access_time, 'Timezones', timezonesStr.isNotEmpty ? timezonesStr : 'N/A'),
                _buildDetailRow(Icons.language, 'Languages', languagesStr.isNotEmpty ? languagesStr : 'N/A'),
                _buildDetailRow(Icons.monetization_on, 'Currencies', currenciesStr.isNotEmpty ? currenciesStr : 'N/A'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryService = CountryApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<Country>(
        future: countryService.getCountryDetailsByCode(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error!);
          } else if (!snapshot.hasData) {
            return _buildEmptyState();
          } else {
            return _buildCountryDetails(snapshot.data!);
          }
        },
      ),
    );
  }
}
