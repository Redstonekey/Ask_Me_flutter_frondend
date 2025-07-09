# AskMe - Anonymous Question App

A Flutter app where friends can ask each other questions anonymously. Share your profile link with people you know and let them ask you anything!

## Features

- **Anonymous Questioning**: Friends can ask you questions without revealing their identity
- **Personal Dashboard**: See your newest questions and recent answers
- **Profile Sharing**: Easy link sharing to let friends find your profile
- **Question Management**: Answer or ignore questions as you choose
- **Privacy-First**: Only people with your link can ask you questions

## App Structure

### Pages

1. **Home** (`/`) - Your personal dashboard with recent questions and answers
2. **Login** (`/login`) - User authentication
3. **Signup** (`/signup`) - New user registration  
4. **User Profile** (`/user/<username>`) - View someone's profile and ask questions
5. **User Questions** (`/user/<username>/questions`) - Manage your questions

### Key Features

- **Profile Link Sharing**: Copy and share your unique profile link
- **Personal Feed**: See your unanswered questions and recent answers
- **Anonymous Questions**: All questions are completely anonymous
- **Friend-to-Friend**: No public discovery - only people with your link can ask
- **Clean Interface**: Simple, focused design for easy use

## How It Works

1. **Sign up** and get your unique profile
2. **Share your profile link** with friends via social media, messaging, etc.
3. **Friends visit your link** and can ask questions anonymously
4. **You get notifications** of new questions on your home dashboard
5. **Answer or ignore** questions as you prefer
6. **Your answers** are visible on your public profile

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Backend Integration

The app is designed to work with a Flask backend and Supabase for:
- User authentication
- Question storage
- User profiles
- Real-time features

## UI/UX Highlights

- **Personal Dashboard**: Home screen shows your questions and sharing options
- **Clean Material Design 3** theme with intuitive navigation
- **Prominent Profile Sharing**: Easy copy-to-clipboard functionality
- **Question Organization**: Clear separation of new vs. answered questions
- **Anonymous Focus**: All questions are clearly marked as anonymous
- **Mobile-First**: Responsive design optimized for mobile sharing

The app creates a safe space for friends to ask each other questions anonymously, similar to AskFM but focused on personal networks rather than public discovery.
