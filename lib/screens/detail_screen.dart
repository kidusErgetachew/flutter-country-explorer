import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';

class DetailScreen extends StatefulWidget {
  final String code;

  const DetailScreen({super.key, required this.code});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Country> _countryFuture;
  final CountryApiService _countryService = CountryApiService();

  @override
  void initState() {
    super.initState();
    _countryFuture = _countryService.getCountryDetailsByCode(widget.code);
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) return 'No internet connection';
    if (error is TimeoutException) return 'Request timed out. Please try again.';
    if (error is FormatException) return 'Unexpected data format received';
    if (error is ApiException) return 'Server error: ${error.statusCode}';
    return 'An unexpected error occurred';
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(Object error) {
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
                  onPressed: () {
                    setState(() {
                      _countryFuture =
                          _countryService.getCountryDetailsByCode(widget.code);
                    });
                  },
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
                _buildDetailRow(Icons.access_time, 'Timezones', country.formattedTimezones),
                _buildDetailRow(Icons.language, 'Languages', country.formattedLanguages),
                _buildDetailRow(Icons.monetization_on, 'Currencies', country.formattedCurrencies),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
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
