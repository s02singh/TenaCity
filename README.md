# Tenacity

## Login Credentials and Testing Tips
Username: Dummy  
Password: password  

Note: you can create your own account using Google auth, but we suggest using this test account.  
Also, for optimal testing, please test after March 23, 2024, 3PM to ensure you have a full quota Firebase to work with. Regardless, you can test whenever needed.  

After you create a new health based habit, please close and relaunch the app to link your Health data to our app. This was to prevent unnecessary Firebase writes
and ensure a working app during testing. Also, to test the Health linking, please use your physical device instead of a simulator.

Please note, when building, you may have to assign the personal team (to yourself) and create a unique bundle identifier.

Please note, that although this should not happen, if the app ever freezes (eg. on the splash screen view), or if it ever says "User data not available", restart the application and it should work as expected.

## Overview
On average, it typically requires 66 days for a behavior to solidify into a habit, with consistent daily practice often posing a challenge (such as maintaining a daily workout routine). In aiding users in the growth of daily habits, we propose TenaCity, an iOS application designed for tracking habit streaks. Each habit will be represented by a building, and users will find motivation through features like creating a city of buildings and observing their friends' progress in their own cities, with the ability to create group habits with them.

# Developers:
- Shikhar Gupta: [ShikharGupta77](https://github.com/ShikharGupta77)
- Sahilbir Singh: [s02singh](https://github.com/s02singh)
- Divya Raj: [goldenfries100](https://github.com/goldenfries100)
- Lena Ray: [lenaray](https://github.com/lenaray)

## Features
### 1. Create and strengthen personal habits
### 2. Set up habits with friends
### 3. Sync your health app with your habits
### 4. View your friends habits


## Implementation Details
### SwiftUI Framework
- The app is built using SwiftUI

### Packages
- https://github.com/firebase/firebase-ios-sdk
- https://github.com/google/GoogleSignIn-iOS


### AuthManager
- manages user authentication status and signin
- stores signin bool and userName
- signOut() function
- store userID

### FirestoreManager
- has functions to write and read data from the firebase for all of our collections (User, Habit, Post, Building, Skin)
- also has a function to populate firebase with sample data


### UI Design
The application UI is based on a city-skyline theme to play along with the app's name. Each view has a basic skyline background to invoke the feeling that one is working hard to achieve their goals in the city.

Our goal was the keep each view very clean and simple so that it's easy for any user to use the app well. We also implemented an info button at the top of every view so that the user has a place that explicitly explains the usage of each page. The navigation bar also plays a large role in aiding smoother page changes, since it allows the user to see the main views that they can interact with.

To match the city theme of the app, we created sets of skins for the buildings, each set containing a base log cabin view, a bigger house, and a skyscraper skin. These skins 

### Technical Implementation
We are using Firebase to store user profile and habit data as well as Apple Health Kit to obtain Step counts, Distance, and Calories for automatic habit tracking. We integrated Google Auth to enable sign-in with Google.

## Views
### 1. SplashScreen
Displays an animation of the app name and logo.

### 2. LoginView
Allows the user to sign-in with Google or with a username & password.

### 3. SettingsView
Allows the user to modify their username & password, and sign out of the application entirely.

### 4. BuildingView
Allows the user to view all of their habits in a scrollable list format, create new habits, monitor the progress of each current habit, and view more in-depth details about each habit.

### 5. FriendsView
Allows the user to view all of their friends in a scrollable list format, add new friends, create group habits, and accept or deny friend requests.

### 6. GroupHabitsView
Allows the user to view the progress of all of their group habits in a scrollable grid format and create new group habits. 

## Contact
For any questions, please contact Sahilbir Singh at scsingh@ucdavis.edu. 

You can also reach out to Divya Raj at draj@ucdavis.edu.

You can also reach out to Lena Ray at lenray@ucdavis.edu.

You can also reach out to Shikhar Gupta at shkgupta@ucdavis.edu
