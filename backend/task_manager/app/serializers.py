from rest_framework import serializers
from .models import CustomUser, Project, Task
from django.contrib.auth import authenticate


class RegisterationSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    fullname = serializers.CharField(required=True)
    password = serializers.CharField(write_only=True,required=True)

    class Meta:
        model = CustomUser
        fields = ['email','username', 'fullname', 'password']

    def validate_email(self, value):
        if CustomUser.objects.filter(email__iexact=value.lower()).exists():
            raise serializers.ValidationError('This email is already in use.')
        return value.lower()


    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError('Password must be at least 8 characters long.')
        if not any(char.isupper() for char in value):
            raise serializers.ValidationError('Password must contain at least one uppercase letter.')
        if not any(char.isdigit() for char in value):
            raise serializers.ValidationError('Password must contain at least one number.')
        return value
    
    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            fullname=validated_data['fullname'],
            username=validated_data['fullname'],
            email=validated_data['email'])
        user.set_password(validated_data['password'])
        user.save()
        return user
    

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True,required=True)

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        user_authenticate = authenticate(email=email, password=password)

        if user_authenticate:
            data['user'] = user_authenticate
            return data
            
        raise serializers.ValidationError({'error': 'Invalid credentials'})
    

class ProjectSerializer(serializers.ModelSerializer):
    owner = serializers.StringRelatedField(read_only=True)
    task_count = serializers.SerializerMethodField()
    due_date = serializers.SerializerMethodField()
  
    class Meta:
        model = Project
        fields = ['id', 'title', 'owner', 'created_at', 'updated_at', 'task_count', 'due_date']
        read_only_fields = ['owner', 'created_at', 'updated_at', 'task_count', 'due_date']
    
    def validate(self, data):
        request = self.context['request']
        user = request.user
        title = data.get('title')
        if request.method == 'POST' and Project.objects.filter(owner=user, title=title).exists():
            raise serializers.ValidationError({'title': 'A project with this title already exists for this user.'})
        return data
    
    def get_task_count(self, obj):
        return obj.tasks.count()

    def get_due_date(self, obj):
        latest_task = obj.tasks.order_by('-deadline').first()
        return latest_task.deadline.strftime('%Y-%m-%d') if latest_task else None

    def create(self, validated_data):
        validated_data['owner'] = self.context['request'].user
        return super().create(validated_data)
    

    

class TaskSerializer(serializers.ModelSerializer):
    in_project = ProjectSerializer(read_only=True)

    class Meta:
        model = Task
        fields = ['id', 'title', 'in_project', 'deadline', 'is_completed', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']

    def validate(self, data):
        request = self.context['request']
        project = self.context.get('project') or data.get('in_project')
        title = data.get('title')
        if not Project.objects.filter(id=project.id, owner=request.user).exists():
            raise serializers.ValidationError({'in_project': 'You do not own this project.'})
        if request.method == 'POST' and Task.objects.filter(in_project=project, title=title).exists():
            raise serializers.ValidationError({'title': 'A task with this title already exists in this project.'})
        return data

    def create(self, validated_data):
        validated_data['in_project'] = self.context['project']
        return super().create(validated_data)



class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['email', 'fullname']
        read_only_fields = ['email', 'fullname']