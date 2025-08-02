from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.LogoutView.as_view(), name='logout'),
    path('projects/', views.CreateProjectView.as_view(), name='project-list'),
    path('projects/<int:project_id>/', views.CreateProjectView.as_view(), name='project-detail'),
    path('projects/<int:project_id>/tasks/', views.CreateTaskView.as_view(), name='task-list'),
    path('projects/<int:project_id>/tasks/<int:task_id>/', views.TaskDetailView.as_view(), name='task-detail'),
    path('profile/', views.ProfileView.as_view(), name='profile')
]