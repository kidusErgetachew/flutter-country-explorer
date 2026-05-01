import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../models/country.dart';
import '../services/country_api_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CountryApiService _countryService = CountryApiService();
  List<Country> _foundCountries = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _searchDebouncer;
  String _currentQuery = '';

  void _handleSearchInput(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      setState(() {
        _foundCountries = [];
        _searchError = null;
      });
      return;
    }

    if (_searchDebouncer?.isActive ?? false) {
      _searchDebouncer!.cancel();
    }

    _searchDebouncer = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isSearching = true;
        _searchError = null;
      });

      try {
        final data = await _countryService.findCountriesByName(query);
        if (mounted) {
          setState(() {
            _foundCountries = data;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            if (e is ApiException) {
              _searchError = 'Server error: ${e.statusCode}';
            } else {
              final msg = e.toString();
              if (msg.contains('Server error:')) {
                final match = RegExp(r'Server error: \d+').firstMatch(msg);
                _searchError = match != null ? match.group(0)! : msg;
              } else if (msg.contains('No internet connection')) {
                _searchError = 'No internet connection';
              } else if (msg.contains('Request timed out')) {
                _searchError = 'Request timed out. Please try again.';
              } else if (msg.contains('Unexpected data format')) {
                _searchError = 'Unexpected data format received';
              } else {
                _searchError = 'An unexpected error occurred';
              }
            }
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.red.shade50,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _searchError!,
                  style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () => _handleSearchInput(_currentQuery),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Text(
          'No countries found matching your search.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _foundCountries.length,
        itemBuilder: (context, index) {
          final country = _foundCountries[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
              title: Text(
                country.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(country.region, style: TextStyle(color: Colors.grey[600])),
              trailing: const Icon(Icons.chevron_right, size: 20),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Countries', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Discover nations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _handleSearchInput,
            ),
          ),
          if (_isSearching)
            _buildLoadingIndicator()
          else if (_searchError != null)
            _buildErrorState()
          else if (_foundCountries.isEmpty && _currentQuery.isNotEmpty)
            _buildEmptyState()
          else
            _buildSearchResults(),
        ],
      ),
    );
  }
}
