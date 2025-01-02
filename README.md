# LotteryScanner

A SwiftUI-based iOS application for scanning and checking lottery tickets.

![App usage](https://imgur.com/a/LmFaGl8)

## Features

- 📸 Ticket scanning using device camera
- 🎫 Support for Powerball and Mega Millions
- 📅 Drawing date selection
- ✨ Haptic feedback
- 🔄 Real-time ticket checking

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- RapidAPI Account

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/LotteryScanner.git
```

2. Create `Config.xcconfig` in Resources/Configuration with your API key:
```
RAPID_API_KEY = your_api_key_here
```

3. Open `LotteryScanner.xcodeproj` in Xcode

4. Build and run the project

## API Setup

1. Create an account at [RapidAPI](https://rapidapi.com)
2. Subscribe to the lottery API services: [Powerball](https://rapidapi.com/avoratechnology/api/powerball) and [Mega Millions] (https://rapidapi.com/avoratechnology/api/mega-millions)
3. Copy your API key
4. Create the configuration file as described in the installation section

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details