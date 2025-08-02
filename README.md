Task Manager Mobile App


Overview

Task Manager is a mobile application designed to help users organize and manage projects and tasks efficiently. Built with Flutter for the frontend and Django REST Framework for the backend, this app provides a seamless user experience with features like task creation, deletion, and dynamic due date tracking. This is my first mobile app, showcasing a clean UI and robust functionality for task management.
Features

User Authentication: Secure login and signup with JWT-based authentication.
Project Management:
Create, view, and delete projects.
Display project details, including title, description, task count, and due date (based on the latest task deadline).
Visual project indicators (e.g., "P1", "P2" for project index).


Task Management:
Add, view, and delete tasks within a project.
Swipe-to-delete tasks with a dismissible UI.
Display task details: title, description, due date, and completion status.


Dynamic Due Date: Project due date automatically updates to the latest task deadline.
Responsive UI: Clean and intuitive interface with real-time updates for task and project data.

Tech Stack

Frontend: Flutter (Dart)
Backend: Django REST Framework (Python)
Database: SQLite (default, configurable for PostgreSQL)
Dependencies:
Frontend: http, flutter_secure_storage, intl, google_fonts
Backend: djangorestframework, djangorestframework-simplejwt, django-cors-headers



Setup Instructions
Prerequisites

Flutter: Version 3.0.0 or higher
Dart: Version 2.17.0 or higher
Python: Version 3.8 or higher
Django: Version 4.2 or higher
Node.js (optional for local development tools)
Git: For cloning the repository

Backend Setup

Clone the Repository:
git clone <repository-url>
cd task_manager_backend


Set Up Virtual Environment:
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate


Install Dependencies:
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers


Apply Migrations:
python manage.py makemigrations
python manage.py migrate


Create Superuser:
python manage.py createsuperuser --username admin --email test@example.com


Configure CORS:Update task_manager_backend/settings.py:
CORS_ALLOWED_ORIGINS = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://10.0.2.2:8000',
    # Add your device IP for physical device testing
]


Run the Server:
python manage.py runserver 0.0.0.0:8000



Frontend Setup

Navigate to Frontend Directory:
cd task_manager_flutter


Install Dependencies:
flutter pub get


Configure API Base URL:Update lib/api_service.dart based on your environment:

Same PC: static const String baseUrl = 'http://127.0.0.1:8000/api/';
Android Emulator: static const String baseUrl = 'http://10.0.2.2:8000/api/';
Physical Device: static const String baseUrl = 'http://192.168.1.x:8000/api/'; (replace 192.168.1.x with your machine’s IP)


Run the App:
flutter run -d chrome  # For web
flutter run -d emulator  # For Android emulator
flutter run -d device  # For physical device



API Endpoints

Login: POST /api/login/ (e.g., {"email": "test@example.com", "password": "Test1234"})
Signup: POST /api/register/ (e.g., {"fullname": "Test User", "email": "test@example.com", "password": "Test1234"})
Projects: 
List/Create: GET/POST /api/projects/
Delete: DELETE /api/projects/<project_id>/


Tasks:
List/Create: GET/POST /api/projects/<project_id>/tasks/
Update: PUT /api/projects/<project_id>/tasks/<task_id>/
Delete: DELETE /api/projects/<project_id>/tasks/<task_id>/



Usage

Sign Up/Login: Create an account or log in with your credentials.
Create Projects: Add new projects with a title and optional description.
Manage Tasks: Navigate to a project, add tasks with titles, descriptions, and deadlines, and mark them as completed or delete them.
View Updates: Project due dates and task counts update automatically when tasks are added or deleted.

Project Structure
task_manager/
├── task_manager_backend/  # Django backend
│   ├── api/
│   │   ├── migrations/
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   └── utils.py
│   ├── manage.py
│   └── settings.py
├── task_manager_flutter/  # Flutter frontend
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── project_list.dart
│   │   │   ├── project_detail.dart
│   │   │   └── new_task.dart
│   │   ├── api_service.dart
│   │   └── main.dart
│   └── pubspec.yaml

Screenshots
(Add screenshots of the app here, e.g., project list, task creation screen)
Future Improvements

Add task editing functionality.
Implement push notifications for task deadlines.
Enhance UI with custom themes and animations.
Support offline mode with local storage.

Contributing
Contributions are welcome! Please submit a pull request or open an issue for bugs, features, or improvements.
License
This project is licensed under the MIT License.
