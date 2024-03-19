# Movies TV App

This project is an iOS application developed using SwiftUI and The Composable Architecture (TCA). It serves as a platform for users to explore information about movies and TV shows, similar to the IMDb app. The app utilizes the TMDB (The Movie Database) API to fetch data regarding movies and TV shows.

## Features

### 1. Home Screen Tab
- Features a horizontal sliding collection of trending, popular movies, and TV shows.
- Includes a search bar to search movies, series and people by keyword.

### 2. Movies Tab
- Displays a grid collection view of movies.
- Movies are sorted by top-rated, now playing, and popular.

### 3. TV Shows Tab
- Displays a grid collection view of TV series.
- Series are sorted by top-rated, now playing, and popular.

### 4. Favorites Tab
- Shows a list of the logged in user's favorite movies and TV shows.

### 5. Details View
- Tapping on any movie or TV show pushes a details view.
- Details view includes the title, poster, rating, overview, trailer, cast, list of reviews and info about last season (for TV series only).

## Technologies Used

- SwiftUI: For building the user interface.
- The Composable Architecture (TCA): For managing application state and logic in a modular and testable way.
- Kingfisher Library: For efficient image loading and caching.

## Usage

To run the project, open it in Xcode and build/run it on your iOS simulator or physical device.
