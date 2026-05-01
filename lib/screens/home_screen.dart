import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Country>> _futureCountries;
  final CountryApiService _apiService = CountryApiService();

  @override
  void initState() {
    super.initState();
    _futureCountries = _apiService.fetchAllCountries();
  }

  void _retry() {
    setState(() {
      _futureCountries = _apiService.fetchAllCountries();
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
      ),
      body: FutureBuilder<List<Country>>(
        future: _futureCountries,
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
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final countries = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  title: Text(
                    '${country.flag} ${country.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(country.region),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(code: country.alpha3Code),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
