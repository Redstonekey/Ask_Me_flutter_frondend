# AskMe - Anonymous Question App

A Flutter app where friends can ask each other questions anonymously. Share your profile link with people you know and let them ask you anything!

## Features

- **Anonymous Questioning**: Friends can ask you questions without revealing their identity
- **Public Landing Page**: Showcase the app features to attract new users
- **Personal Dashboard**: See your newest questions and recent answers (logged-in users)
- **Profile Sharing**: Easy link sharing to let friends find your profile
- **Login Wall**: Non-logged-in users can see profiles and questions but must login to see answers
- **Question Management**: Answer or ignore questions as you choose
- **Privacy-First**: Only people with your link can ask you questions

## App Structure

### Pages

1. **Landing** (`/`) - Public page for non-logged-in users showcasing features
2. **Home** (`/home`) - Personal dashboard for logged-in users
3. **Login** (`/login`) - User authentication
4. **Signup** (`/signup`) - New user registration  
5. **User Profile** (`/user/<username>`) - Public profile (login required for answers)
6. **User Questions** (`/user/<username>/questions`) - Manage questions (login required)

### Key Features

- **Public Access**: Anyone can view profiles and see questions that have been asked
- **Login Wall**: Only answers are hidden behind login/signup for non-users
- **Profile Link Sharing**: Copy and share your unique profile link
- **Personal Feed**: See your unanswered questions and recent answers
- **Anonymous Questions**: All questions are completely anonymous
- **Friend-to-Friend**: No public discovery - only people with your link can ask
- **Clean Interface**: Simple, focused design for easy use

## How It Works

### For Non-Logged-In Users:
1. **Visit landing page** to learn about the app
2. **View public profiles** via shared links
3. **See questions** that have been asked but answers are hidden
4. **Must login/signup** to see answers or ask questions

### For Logged-In Users:
1. **Personal dashboard** shows your questions and answers
2. **Share your profile link** with friends via social media, messaging, etc.
3. **Friends visit your link** and can ask questions anonymously
4. **You get notifications** of new questions on your dashboard
5. **Answer or ignore** questions as you prefer
6. **Your answers** are visible to all users (logged-in and public)

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
