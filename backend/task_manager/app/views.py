import jwt
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, timedelta, timezone
from django.conf import settings
from .serializers import RegisterationSerializer, LoginSerializer, ProjectSerializer, TaskSerializer, ProfileSerializer
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.throttling import AnonRateThrottle
from .authentication import JWTAuthentication
from .models import BlacklistedToken, Project, Task, CustomUser
from rest_framework.pagination import PageNumberPagination


def generate_token(user):
    try:
        expire_time = datetime.now(timezone.utc) + timedelta(days=7)
        payload = {
            'user_id': user.id,
            'username': user.username,
            'exp': expire_time,
            'iat': datetime.now(timezone.utc),
        }
        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        return token, expire_time
    except Exception as e:
        raise Exception(f"Failed to generate token: {str(e)}")

class RegisterView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    authentication_classes = []
    def post(self, request):
        serializer = RegisterationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, expire_time = generate_token(user)
            return Response({"status": "success", "data": {"token": token, "expires_at": expire_time}}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, expire_time = generate_token(user)
            return Response({"status": "success", "data": {"token": token, "expires_at": expire_time}}, status=status.HTTP_200_OK)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_401_UNAUTHORIZED)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    authentication_classes = [JWTAuthentication]
    def post(self, request):
        try:
            token = request.auth
            BlacklistedToken.objects.create(token=token)
            return Response({"status": "success", "message": "Successfully logged out"}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CreateProjectView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    def post(self, request):
        serializer = ProjectSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    
    def get(self, request):
        try:
            all_projects = Project.objects.filter(owner=request.user)
            paginator = self.pagination_class()
            page = paginator.paginate_queryset(all_projects, request)
            serializer = ProjectSerializer(page, many=True, context={'request': request})
            return paginator.get_paginated_response({"status": "success", "data": serializer.data})
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
    def delete(self, request, project_id):
        try:
            project = Project.objects.get(id=project_id, owner=request.user)
            tasks = Task.objects.filter(in_project=project)
            tasks.delete()
            project.delete()
            return Response({"status": "success", "message": "Project deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found or not owned by user"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        


class CreateTaskView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    def post(self, request, project_id):
        try:
            project = Project.objects.get(id=project_id, owner=request.user)
            serializer = TaskSerializer(data=request.data, context={'request': request, 'project': project})
            if serializer.is_valid():
                serializer.save()
                return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
            return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found or not owned by user"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def get(self, request, project_id):
        try:
            project = Project.objects.get(id=project_id, owner=request.user)
            all_tasks = Task.objects.filter(in_project=project)
            paginator = self.pagination_class()
            page = paginator.paginate_queryset(all_tasks, request)
            serializer = TaskSerializer(page, many=True, context={'request': request})
            return paginator.get_paginated_response({"status": "success", "data": serializer.data})
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found or not owned by user"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class TaskDetailView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def get(self, request, project_id, task_id):
        try:
            project = Project.objects.get(id=project_id, owner=request.user)
            task = Task.objects.get(in_project=project, id=task_id)
            serializer = TaskSerializer(task, context={'request': request})
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found or not owned by user"}, status=status.HTTP_404_NOT_FOUND)
        except Task.DoesNotExist:
            return Response({"status": "error", "message": "Task not found"}, status=status.HTTP_404_NOT_FOUND)
    
    
    def delete(self, request, project_id, task_id):
        try:
            project = Project.objects.get(id=project_id, owner=request.user)
            task = Task.objects.get(in_project=project, id=task_id)
            task.delete()
            return Response({"status": "success", "message": "Task deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found or not owned by user"}, status=status.HTTP_404_NOT_FOUND)
        except Task.DoesNotExist:
            return Response({"status": "error", "message": "Task not found"}, status=status.HTTP_404_NOT_FOUND)


class ProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    def patch(self, request):
        serializer = ProfileSerializer(
            request.user,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)