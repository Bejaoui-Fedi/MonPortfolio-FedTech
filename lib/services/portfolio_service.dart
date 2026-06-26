import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/project.dart';
import '../models/experience.dart';
import '../models/work_service.dart';
import '../models/education.dart';
import '../models/message.dart';
import '../models/iot_design.dart';
import '../models/skill.dart';
import '../models/study_document.dart';

class PortfolioService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  String _name = '';
  String _headline = '';
  String _bio = '';
  String _profileImageUrl = '';

  List<Project> _projects = [];
  List<Experience> _experiences = [];
  List<WorkService> _services = [];
  List<Skill> _skills = [];
  List<Education> _education = [];
  List<Message> _messages = [];
  List<IoTDesign> _iotDesigns = [];
  List<StudyDocument> _studyDocuments = [];

  final Map<String, String> _contact = {
    'email': '',
    'phone': '',
    'linkedin': '',
    'github': '',
  };

  PortfolioService() {
    loadData();
  }

  Future<String?> uploadImage(PlatformFile file, String path) async {
    try {
      final fileExtension = file.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = '$path/$fileName';

      if (file.bytes != null) {
        await _supabase.storage.from('portfolio').uploadBinary(
              storagePath,
              file.bytes!,
              fileOptions: FileOptions(contentType: 'image/$fileExtension'),
            );
      } else if (file.path != null) {
        final ioFile = File(file.path!);
        await _supabase.storage.from('portfolio').upload(
              storagePath,
              ioFile,
              fileOptions: FileOptions(contentType: 'image/$fileExtension'),
            );
      } else {
        throw 'No file data or path available';
      }

      final imageUrl = _supabase.storage.from('portfolio').getPublicUrl(storagePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      try {
        final buckets = await _supabase.storage.listBuckets();
        debugPrint('Available buckets: ${buckets.map((b) => b.name).toList()}');
      } catch (be) {
        debugPrint('Could not list buckets: $be');
      }
      rethrow;
    }
  }

  Future<String?> uploadDocument(PlatformFile file, String path) async {
    try {
      final fileExtension = file.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = '$path/$fileName';

      String contentType = 'application/octet-stream';
      if (fileExtension.toLowerCase() == 'pdf') contentType = 'application/pdf';
      else if (['ppt', 'pptx'].contains(fileExtension.toLowerCase())) contentType = 'application/vnd.ms-powerpoint';
      else if (['doc', 'docx'].contains(fileExtension.toLowerCase())) contentType = 'application/msword';

      if (file.bytes != null) {
        await _supabase.storage.from('portfolio').uploadBinary(
              storagePath,
              file.bytes!,
              fileOptions: FileOptions(contentType: contentType),
            );
      } else if (file.path != null) {
        final ioFile = File(file.path!);
        await _supabase.storage.from('portfolio').upload(
              storagePath,
              ioFile,
              fileOptions: FileOptions(contentType: contentType),
            );
      } else {
        throw 'No file data or path available';
      }

      final fileUrl = _supabase.storage.from('portfolio').getPublicUrl(storagePath);
      return fileUrl;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      rethrow;
    }
  }

  Future<void> loadData() async {
    try {
      // Load Profile
      final profileData = await _supabase.from('profile').select().single();
      _name = profileData['name'];
      _headline = profileData['headline'];
      _bio = profileData['bio'];
      _profileImageUrl = profileData['profile_image_url'];
      
      if (profileData['contact_info'] != null) {
        final Map<String, dynamic> contactInfo = profileData['contact_info'];
        contactInfo.forEach((key, value) {
          if (_contact.containsKey(key)) {
            _contact[key] = value.toString();
          }
        });
      }

      // Load Projects
      final projectsData = await _supabase.from('projects').select().order('created_at');
      _projects = projectsData.map((map) => Project.fromMap(map)).toList();
      _sortProjects();

      // Load Experiences
      final expData = await _supabase.from('experiences').select().order('start_date', ascending: false);
      _experiences = expData.map((map) => Experience.fromMap(map)).toList();

      // Load Education
      final eduData = await _supabase.from('education').select().order('created_at');
      _education = eduData.map((map) => Education.fromMap(map)).toList();

      // Load Services
      final servicesData = await _supabase.from('services').select().order('created_at');
      _services = servicesData.map((map) => WorkService.fromMap(map)).toList();

      // Load Skills
      final skillsData = await _supabase.from('skills').select();
      _skills = skillsData.map((map) => Skill.fromMap(map)).toList();

      // Load IoT Designs
      final iotData = await _supabase.from('iot_designs').select().order('created_at');
      _iotDesigns = iotData.map((map) => IoTDesign.fromMap(map)).toList();

      // Load Messages
      await loadMessages();

      // Load Study Documents
      try {
        final docsData = await _supabase.from('study_documents').select().order('created_at', ascending: false);
        _studyDocuments = docsData.map((map) => StudyDocument.fromMap(map)).toList();
      } catch (e) {
        debugPrint('Error loading study documents: $e');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  // Getters
  String get name => _name;
  String get headline => _headline;
  String get bio => _bio;
  String get profileImageUrl => _profileImageUrl;
  List<Project> get projects => List.unmodifiable(_projects);
  List<Experience> get experiences => List.unmodifiable(_experiences);
  List<WorkService> get services => List.unmodifiable(_services);
  List<Skill> get skills => List.unmodifiable(_skills);
  List<Education> get education => List.unmodifiable(_education);
  Map<String, String> get contact => Map.unmodifiable(_contact);
  List<Message> get messages => List.unmodifiable(_messages);
  List<IoTDesign> get iotDesigns => List.unmodifiable(_iotDesigns);
  List<StudyDocument> get studyDocuments => List.unmodifiable(_studyDocuments);
  int get unreadMessageCount => _messages.where((m) => !m.isRead).length;

  // Setters for Profile
  Future<void> updateProfile({String? name, String? headline, String? bio, String? profileImageUrl}) async {
    final updates = <String, dynamic>{};
    if (name != null) { _name = name; updates['name'] = name; }
    if (headline != null) { _headline = headline; updates['headline'] = headline; }
    if (bio != null) { _bio = bio; updates['bio'] = bio; }
    if (profileImageUrl != null) { _profileImageUrl = profileImageUrl; updates['profile_image_url'] = profileImageUrl; }

    try {
      await _supabase.from('profile').update(updates).eq('id', 'main_profile'); // Assuming a single profile with ID 'main_profile'
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> updateAdminPassword(String newPassword) async {
    try {
      await _supabase.from('profile').update({
        'admin_password': newPassword,
      }).eq('id', 'main_profile');
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  // Projects CRUD
  Future<void> addProject(Project project) async {
    try {
      await _supabase.from('projects').insert(project.toMap());
      _projects.add(project);
      _sortProjects();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding project: $e');
    }
  }

  Future<void> updateProject(Project updatedProject) async {
    try {
      await _supabase.from('projects').update(updatedProject.toMap()).eq('id', updatedProject.id);
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        _projects[index] = updatedProject;
        _sortProjects();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating project: $e');
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _supabase.from('projects').delete().eq('id', id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting project: $e');
    }
  }

  // Experiences CRUD
  Future<void> addExperience(Experience exp) async {
    try {
      await _supabase.from('experiences').insert(exp.toMap());
      _experiences.add(exp);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding experience: $e');
    }
  }

  Future<void> updateExperience(Experience updatedExp) async {
    try {
      await _supabase.from('experiences').update(updatedExp.toMap()).eq('id', updatedExp.id);
      final index = _experiences.indexWhere((e) => e.id == updatedExp.id);
      if (index != -1) {
        _experiences[index] = updatedExp;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating experience: $e');
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _supabase.from('experiences').delete().eq('id', id);
      _experiences.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting experience: $e');
    }
  }

  // Education CRUD
  Future<void> addEducation(Education edu) async {
    try {
      await _supabase.from('education').insert(edu.toMap());
      _education.add(edu);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding education: $e');
    }
  }

  Future<void> updateEducation(Education updatedEdu) async {
    try {
      await _supabase.from('education').update(updatedEdu.toMap()).eq('id', updatedEdu.id);
      final index = _education.indexWhere((e) => e.id == updatedEdu.id);
      if (index != -1) {
        _education[index] = updatedEdu;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating education: $e');
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await _supabase.from('education').delete().eq('id', id);
      _education.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting education: $e');
    }
  }

  // Services CRUD
  Future<void> addService(WorkService service) async {
    try {
      await _supabase.from('services').insert(service.toMap());
      _services.add(service);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding service: $e');
    }
  }

  Future<void> updateService(WorkService updatedService) async {
    try {
      await _supabase.from('services').update(updatedService.toMap()).eq('id', updatedService.id);
      final index = _services.indexWhere((s) => s.id == updatedService.id);
      if (index != -1) {
        _services[index] = updatedService;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating service: $e');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _supabase.from('services').delete().eq('id', id);
      _services.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting service: $e');
    }
  }

  // Skills CRUD
  Future<void> addSkill(Skill skill) async {
    try {
      final data = skill.toMap();
      debugPrint('[PortfolioService] Adding skill: $data');
      await _supabase.from('skills').insert(data);
      // Reload from DB to confirm what was actually saved
      final skillsData = await _supabase.from('skills').select();
      _skills = skillsData.map((map) => Skill.fromMap(map)).toList();
      debugPrint('[PortfolioService] Skills after insert: ${_skills.map((s) => "${s.name}:${s.logoUrl}").join(", ")}');
      notifyListeners();
    } catch (e) {
      debugPrint('[PortfolioService] Error adding skill: $e');
      rethrow;
    }
  }

  Future<void> updateSkill(Skill oldSkill, Skill newSkill) async {
    try {
      final data = newSkill.toMap();
      debugPrint('[PortfolioService] Updating skill: $data (matching name: ${oldSkill.name})');
      await _supabase.from('skills').update(data).eq('name', oldSkill.name);
      // Reload from DB to confirm what was actually saved
      final skillsData = await _supabase.from('skills').select();
      _skills = skillsData.map((map) => Skill.fromMap(map)).toList();
      debugPrint('[PortfolioService] Skills after update: ${_skills.map((s) => "${s.name}:${s.logoUrl}").join(", ")}');
      notifyListeners();
    } catch (e) {
      debugPrint('[PortfolioService] Error updating skill: $e');
      rethrow;
    }
  }

  Future<void> deleteSkill(String skillName) async {
    try {
      await _supabase.from('skills').delete().eq('name', skillName);
      _skills.removeWhere((s) => s.name == skillName);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting skill: $e');
    }
  }

  // Contact Update
  Future<void> updateContact(String key, String value) async {
    try {
      if (_contact.containsKey(key)) {
        _contact[key] = value;
        notifyListeners();
        
        await _supabase.from('profile').update({
          'contact_info': _contact,
        }).eq('id', 'main_profile');
      }
    } catch (e) {
      debugPrint('Error updating contact: $e');
    }
  }

  // IoT Designs CRUD
  Future<void> addIoTDesign(IoTDesign design) async {
    try {
      await _supabase.from('iot_designs').insert(design.toMap());
      await loadData(); // Refresh all
    } catch (e) {
      debugPrint('Error adding IoT design: $e');
    }
  }

  Future<void> updateIoTDesign(IoTDesign updatedDesign) async {
    try {
      await _supabase.from('iot_designs').update(updatedDesign.toMap()).eq('id', updatedDesign.id);
      await loadData();
    } catch (e) {
      debugPrint('Error updating IoT design: $e');
    }
  }

  Future<void> deleteIoTDesign(String id) async {
    try {
      await _supabase.from('iot_designs').delete().eq('id', id);
      _iotDesigns.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting IoT design: $e');
    }
  }

  // Study Documents CRUD
  Future<void> _loadStudyDocuments() async {
    final docsData = await _supabase.from('study_documents').select().order('created_at', ascending: false);
    _studyDocuments = docsData.map((map) => StudyDocument.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addStudyDocument(StudyDocument doc) async {
    try {
      await _supabase.from('study_documents').insert(doc.toMap());
      await _loadStudyDocuments();
    } catch (e) {
      debugPrint('Error adding study document: $e');
    }
  }

  Future<void> updateStudyDocument(StudyDocument doc) async {
    try {
      await _supabase.from('study_documents').update(doc.toMap()).eq('id', doc.id);
      await _loadStudyDocuments();
    } catch (e) {
      debugPrint('Error updating study document: $e');
    }
  }

  Future<void> deleteStudyDocument(String id) async {
    try {
      await _supabase.from('study_documents').delete().eq('id', id);
      _studyDocuments.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting study document: $e');
    }
  }

  // Messages
  Future<bool> sendMessage(String name, String email, String content) async {
    try {
      final message = Message(
        id: '',
        name: name,
        email: email,
        content: content,
        createdAt: DateTime.now(),
      );
      await _supabase.from('messages').insert(message.toMap());
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<void> loadMessages() async {
    try {
      final data = await _supabase.from('messages').select().order('created_at', ascending: false);
      _messages = data.map((m) => Message.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _supabase.from('messages').delete().eq('id', id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> markMessageAsRead(String id) async {
    try {
      await _supabase.from('messages').update({'is_read': true}).eq('id', id);
      
      // Update local state explicitly
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        final msg = _messages[index];
        _messages[index] = Message(
          id: msg.id,
          name: msg.name,
          email: msg.email,
          content: msg.content,
          createdAt: msg.createdAt,
          isRead: true,
        );
        _messages = List.from(_messages); // Force list reference change
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  void _sortProjects() {
    _projects.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return b.startDate!.compareTo(a.startDate!);
    });
  }
}
