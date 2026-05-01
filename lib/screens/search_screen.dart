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
  final CountryApiService _api = CountryApiService();
  List<Country> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final data = await _api.searchCountries(query);
        if (mounted) {
          setState(() {
            _results = data;
            _isLoading = false;
          });
        }
      } on SocketException {
        if (mounted) {
          setState(() {
            _errorMessage = 'No internet connection';
            _isLoading = false;
          });
        }
      } on TimeoutException {
        if (mounted) {
          setState(() {
            _errorMessage = 'Request timed out. Please try again.';
            _isLoading = false;
          });
        }
      } on FormatException {
        if (mounted) {
          setState(() {
            _errorMessage = 'Unexpected data format received';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            if (e is ApiException) {
              _errorMessage = 'Server error: ${e.statusCode}';
            } else {
              final msg = e.toString();
              if (msg.contains('Server error:')) {
                final match = RegExp(r'Server error: \d+').firstMatch(msg);
                _errorMessage = match != null ? match.group(0)! : msg;
              } else if (msg.contains('No internet connection')) {
                _errorMessage = 'No internet connection';
              } else if (msg.contains('Request timed out')) {
                _errorMessage = 'Request timed out. Please try again.';
              } else if (msg.contains('Unexpected data format')) {
                _errorMessage = 'Unexpected data format received';
              } else {
                _errorMessage = 'An unexpected error occurred';
              }
            }
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Countries'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search country...',
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final country = _results[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
