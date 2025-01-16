# 🍳 CulinaryCompass

Your personal guide to discovering and cooking delicious recipes from around the world.

## 🌟 About

CulinaryCompass is a modern recipe discovery app that helps you:
- Find recipes based on ingredients you have
- Learn cooking techniques with step-by-step instructions
- Cook hands-free with voice commands
- Save your favorite recipes for offline access
- Explore cuisines from different cultures

## ✨ Features

### 🔍 Advanced Search
- Search by ingredients
- Filter by cooking time
- Filter by difficulty level
- Filter by cuisine type
- Voice search capabilities

### 📱 Smart UI
- Beautiful grid layout for recipes
- Detailed recipe views with step-by-step instructions
- Category-based browsing
- Trending and popular recipes sections
- Dark/Light theme support

### 👨‍🍳 Cooking Mode
- Hands-free voice commands
- Step-by-step instructions
- Keep screen on while cooking
- Voice control commands:
  - Next/Previous step
  - Repeat current step
  - View ingredients
  - Timer controls

### 💾 Offline Support
- Save recipes for offline access
- Automatic caching of viewed recipes
- Search through saved recipes
- Manage favorite recipes

## 🏗️ Architecture

The app follows a clean architecture pattern with:
- Feature-based folder structure
- Riverpod for state management
- Repository pattern for data handling
- Service layer for API communication

### Project Structure

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [TheMealDB API](https://www.themealdb.com/api.php) - Recipe data
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Local storage
- [Speech to Text](https://pub.dev/packages/speech_to_text) - Voice commands

## 📱 Screenshots

<p float="left">
  <img src="screenshots/home.png" width="200" />
  <img src="screenshots/search.png" width="200" /> 
  <img src="screenshots/detail.png" width="200" />
  <img src="screenshots/cooking.png" width="200" />
</p>

### Home Screen
The home screen features trending recipes, categories, and quick access to your favorites.

### Search & Filters
Advanced search with multiple filters helps you find the perfect recipe.

### Recipe Details
Detailed view with ingredients, instructions, and nutritional information.

### Cooking Mode
Hands-free cooking with voice commands and step-by-step guidance.



