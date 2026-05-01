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
  late Future<List<Country>> _countriesFuture;
  final CountryApiService _countryService = CountryApiService();

  List<Country> _allCountries = [];
  List<Country> _visibleCountries = [];
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    setState(() {
      _currentPage = 1;
      _countriesFuture = _countryService.getAllCountries();
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

  Widget _buildLoadingState() {
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
                  onPressed: _loadCountries,
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
        'No countries available right now',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  Widget _buildCountryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      itemCount: _visibleCountries.length + 1,
      itemBuilder: (context, index) {
        if (index == _visibleCountries.length) {
          if (_visibleCountries.length < _allCountries.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentPage++;
                  });
                },
                child: const Text('Load More'),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text('No more data', style: TextStyle(color: Colors.grey)),
              ),
            );
          }
        }

        final country = _visibleCountries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Text(country.flag, style: const TextStyle(fontSize: 32)),
            title: Text(
              country.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(country.region, style: TextStyle(color: Colors.grey[700])),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(code: country.alpha3Code),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Country Explorer', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Explore the world', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: FutureBuilder<List<Country>>(
        future: _countriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            _allCountries = snapshot.data!;
            _visibleCountries = _allCountries.take(_currentPage * _itemsPerPage).toList();
            return Column(
              children: [
                if (_countryService.isFromCache)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Cached data',
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                Expanded(child: _buildCountryList()),
              ],
            );
          }
        },
      ),
    );
  }
}
