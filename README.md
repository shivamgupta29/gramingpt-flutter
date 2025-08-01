GraminGPT - AI Voice Assistant for Rural India
GraminGPT is a socially impactful mobile application designed to bridge the digital and information divide for rural populations in India. The app functions as a voice-first AI assistant, operating entirely in Hindi to overcome literacy and technological barriers. It provides users with instant, location-aware answers to questions about healthcare, agriculture, and government schemes, using just their voice.

Our mission is to bring usable and accessible AI to Bharat, starting with the most critical needs of its communities.

Features
Voice-Only Interface: Fully hands-free experience. Users speak their questions and hear the AI's answers in a natural Hindi voice.

Speech-to-Text: Integrates with the device's native speech recognition to accurately transcribe spoken Hindi.

Text-to-Speech: Provides clear, spoken responses in a natural Indian accent.

Location-Aware AI: The AI assistant uses the device's GPS to provide hyperlocal, context-aware answers, such as recommending the nearest hospital or clinic.

Healthcare Directory: A dedicated feature to find and list nearby hospitals, pharmacies, and clinics based on the user's current location.

Persistent Conversation History: All conversations are saved to a local database on the device, allowing users to access and continue their past chats at any time.

Tech Stack
This project is a collaboration between a Flutter frontend and a Python backend.

Frontend (by Shivam Gupta)
Framework: Flutter

State Management: StatefulWidget / setState

Voice & Speech:
speech_to_text: For capturing and transcribing user's voice input.
flutter_tts: For speaking the AI's text responses.

Location:
geolocator: For fetching the device's GPS coordinates.
permission_handler: For robustly managing microphone and location permissions.

Database:
sqflite: For creating and managing the local database for conversation history.
path: To find the correct local path for the database file.

Networking:
http: For making API calls to the backend.

Backend (by Sarthak Sukhral)

Framework: Python with FastAPI

AI Model: Sarvam-M from Sarvam AI

Location Services: OpenStreetMap (via Overpass API) for querying nearby health centers.

Deployment: Dockerized and hosted on Render.

How to Run
Clone the repository:
git clone https://github.com/shivamgupta29/gramingpt-flutter-app.git

Navigate to the project directory:
cd gramingpt-flutter-app

Install dependencies:
flutter pub get

Run the app:
flutter run

Credits
This project was a collaborative effort:

Frontend Development: Shivam Gupta

Backend Development: @sarthwa8
