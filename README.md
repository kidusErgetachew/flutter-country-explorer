# Flutter Country Explorer

## Student Info
- **Name:** Kidus Ergetachew
- **ID:** ATE/3349/15

## Description
A Flutter app that fetches and displays country data using the RestCountries API. Users can browse, search, and view detailed country information.

## Features
- Browse all countries fetched from the RestCountries API
- Search countries by name with debounced input (400ms delay)
- View detailed country information (capital, region, population, area, languages, currencies, timezones)
- Client-side pagination (20 countries per page, load-more on demand)
- In-memory caching with 5-minute TTL to reduce unnecessary network calls
- Typed error handling with user-friendly messages and retry support
- Clean architecture: dedicated service layer, model layer, and screen layer

## Setup Instructions
1. Run `flutter pub get` to install dependencies.
2. Run `flutter run` to launch the application.

## API Endpoints Used
- `GET /v3.1/all`
- `GET /v3.1/name/{name}`
- `GET /v3.1/alpha/{code}`

## Known Limitations
- No persistent offline storage (cache is in-memory only and is lost on app restart)
- Pagination is client-side; all country data is fetched in a single request on first load
- Flag rendering depends on emoji support, which may vary across devices and OS versions
