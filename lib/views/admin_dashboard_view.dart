import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../models/project.dart';
import '../models/experience.dart';
import '../models/education.dart';
import '../models/work_service.dart';
import '../models/iot_design.dart';
import '../models/skill.dart';
import '../models/study_document.dart';
import '../widgets/main_layout.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    // Charger les messages dès l'ouverture pour le badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioService>().loadMessages();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioService>();

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: Text('CONTROL PANEL', style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withAlpha(12)),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00E5FF),
          labelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
          tabs: [
            const Tab(text: 'PROFILE'),
            const Tab(text: 'PROJECTS'),
            const Tab(text: 'EXPERIENCE'),
            const Tab(text: 'EDUCATION'),
            const Tab(text: 'SERVICES'),
            const Tab(text: 'SKILLS'),
            const Tab(text: 'IoT DESIGNS'),
            const Tab(text: 'CONTACT'),
            const Tab(text: 'DOCS'),
            Consumer<PortfolioService>(
              builder: (context, p, _) => Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Tab(text: 'MESSAGES'),
                  ),
                  if (p.unreadMessageCount > 0)
                    Positioned(
                      right: 0,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFBD00FF), shape: BoxShape.circle),
                        child: Text(p.unreadMessageCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().logout(),
            icon: const Icon(Icons.logout, color: Color(0xFFBD00FF)),
            tooltip: 'LOGOUT',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileEditor(context, portfolio),
          _buildProjectsList(context, portfolio),
          _buildExperienceList(context, portfolio),
          _buildEducationList(context, portfolio),
          _buildServicesList(context, portfolio),
          _buildSkillsList(context, portfolio),
          _buildIoTDesignsList(context, portfolio),
          _buildContactEditor(context, portfolio),
          _buildStudyDocumentsList(context, portfolio),
          _buildMessagesList(context, portfolio),
        ],
      ),
    );
  }

  Widget _buildStudyDocumentsList(BuildContext context, PortfolioService portfolio) {
    final sortedDocs = [...portfolio.studyDocuments]
      ..sort((a, b) {
        final dateA = a.startDate ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.startDate ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // décroissant : plus récent en premier
      });
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final doc = sortedDocs[index];
            return _buildListItem(
              title: doc.title,
              subtitle: 'Type: ${doc.type.toUpperCase()} • ${doc.description ?? ""}',
              onEdit: () => _showStudyDocumentDialog(context, portfolio, doc: doc),
              onDelete: () => portfolio.deleteStudyDocument(doc.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showStudyDocumentDialog(context, portfolio),
            backgroundColor: const Color(0xFF00E5FF),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _showStudyDocumentDialog(BuildContext context, PortfolioService portfolio, {var doc}) {
    final titleController = TextEditingController(text: doc?.title);
    final descController = TextEditingController(text: doc?.description);
    final urlController = TextEditingController(text: doc?.fileUrl);
    // type est auto-détecté depuis l'extension du fichier
    String detectedType = doc?.type ?? 'pdf';
    DateTime? startDate = doc?.startDate;
    DateTime? endDate = doc?.endDate;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: const Color(0xFF0A0E21),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5)),
            title: Text(
              doc == null ? 'NEW STUDY DOCUMENT' : 'EDIT STUDY DOCUMENT',
              style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(titleController, 'TITLE'),
                  _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(urlController, 'FILE URL')),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _pickAndUploadDocument(
                          portfolio, 'study_docs', urlController, context,
                          onTypeDetected: (t) => setStateDialog(() => detectedType = t),
                        ),
                        icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
                        tooltip: 'UPLOAD DOCUMENT',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sélecteurs de dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) setStateDialog(() => startDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'DATE DÉBUT',
                              labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                            ),
                            child: Text(
                              startDate != null
                                  ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
                                  : "Sélectionner",
                              style: TextStyle(color: startDate != null ? Colors.white : Colors.white38),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) setStateDialog(() => endDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'DATE FIN',
                              labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endDate != null
                                      ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                                      : "En cours",
                                  style: TextStyle(color: endDate != null ? Colors.white : Colors.white38),
                                ),
                                if (endDate != null)
                                  GestureDetector(
                                    onTap: () => setStateDialog(() => endDate = null),
                                    child: const Icon(Icons.clear, size: 16, color: Colors.white38),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Badge type auto-détecté (lecture seule)
                  Row(
                    children: [
                      const Text('TYPE DÉTECTÉ :', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00E5FF).withAlpha(80)),
                        ),
                        child: Text(
                          detectedType.toUpperCase(),
                          style: GoogleFonts.orbitron(color: const Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newDoc = StudyDocument(
                    id: doc?.id ?? DateTime.now().toString(),
                    title: titleController.text,
                    description: descController.text,
                    fileUrl: urlController.text,
                    type: detectedType,
                    startDate: startDate,
                    endDate: endDate,
                    createdAt: doc?.createdAt ?? DateTime.now(),
                  );
                  if (doc == null) {
                    await portfolio.addStudyDocument(newDoc);
                  } else {
                    await portfolio.updateStudyDocument(newDoc);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
                child: const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadDocument(
    PortfolioService portfolio,
    String path,
    TextEditingController urlController,
    BuildContext context, {
    required void Function(String type) onTypeDetected,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx', 'zip', 'rar'],
    );
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload en cours...')));
      try {
        final file = result.files.single;
        final url = await portfolio.uploadDocument(file, path);
        if (url != null) {
          urlController.text = url;

          // Détecter l'extension depuis extension ou depuis le nom du fichier
          final ext = (file.extension ?? file.name.split('.').last).toLowerCase().trim();
          String detectedType;
          if (['ppt', 'pptx'].contains(ext)) {
            detectedType = 'ppt';
          } else if (['doc', 'docx'].contains(ext)) {
            detectedType = 'doc';
          } else if (['zip', 'rar'].contains(ext)) {
            detectedType = 'zip';
          } else {
            detectedType = 'pdf';
          }
          onTypeDetected(detectedType);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fichier $ext uploadé !')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Widget _buildProfileEditor(BuildContext context, PortfolioService portfolio) {
    final nameController = TextEditingController(text: portfolio.name);
    final headlineController = TextEditingController(text: portfolio.headline);
    final bioController = TextEditingController(text: portfolio.bio);
    final imageController = TextEditingController(text: portfolio.profileImageUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PERSONAL INFORMATION'),
          const SizedBox(height: 24),
          _buildTextField(nameController, 'FULL NAME'),
          _buildTextField(headlineController, 'HEADLINE'),
          _buildTextField(bioController, 'BIO', maxLines: 4),
          Row(
            children: [
              Expanded(child: _buildTextField(imageController, 'PROFILE IMAGE URL')),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _pickAndUploadImage(portfolio, 'profile', imageController),
                icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
                tooltip: 'UPLOAD IMAGE',
              ),
              IconButton(
                onPressed: () => _registerFace(portfolio, imageController),
                icon: const Icon(Icons.camera_alt, color: Color(0xFFBD00FF)),
                tooltip: 'REGISTER FACE (CAMERA)',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await portfolio.updateProfile(
                  name: nameController.text,
                  headline: headlineController.text,
                  bio: bioController.text,
                  profileImageUrl: imageController.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF00E5FF)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('SAVE CHANGES', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 48),
          _buildSectionHeader('SECURITY SETTINGS'),
          const SizedBox(height: 24),
          _buildPasswordField(context, portfolio),
        ],
      ).animate().fadeIn(),
    );
  }

  bool _obscureDashboardPassword = true;

  Widget _buildPasswordField(BuildContext context, PortfolioService portfolio) {
    final passwordController = TextEditingController();
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFBD00FF).withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBD00FF).withAlpha(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHANGE ADMIN PASSWORD',
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscureDashboardPassword,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ENTER NEW PASSWORD',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFBD00FF))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureDashboardPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () => setStateLocal(() => _obscureDashboardPassword = !_obscureDashboardPassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.isNotEmpty) {
                      try {
                        await portfolio.updateAdminPassword(passwordController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Color(0xFFBD00FF)),
                          );
                          passwordController.clear();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update password. Ensure "admin_password" column exists.'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBD00FF).withAlpha(40),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFBD00FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('UPDATE PASSWORD', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectsList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: portfolio.projects.length,
          itemBuilder: (context, index) {
            final project = portfolio.projects[index];
            return _buildListItem(
              title: project.title,
              subtitle: project.technologies.join(', '),
              imageUrl: project.imageUrl,
              onEdit: () => _showProjectDialog(context, portfolio, project: project),
              onDelete: () => portfolio.deleteProject(project.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showProjectDialog(context, portfolio),
            backgroundColor: const Color(0xFF00E5FF),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: portfolio.experiences.length,
          itemBuilder: (context, index) {
            final exp = portfolio.experiences[index];
            return _buildListItem(
              title: exp.role,
              subtitle: '${exp.company} • ${exp.location}',
              onEdit: () => _showExperienceDialog(context, portfolio, experience: exp),
              onDelete: () => portfolio.deleteExperience(exp.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showExperienceDialog(context, portfolio),
            backgroundColor: const Color(0xFFBD00FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: portfolio.education.length,
          itemBuilder: (context, index) {
            final edu = portfolio.education[index];
            return _buildListItem(
              title: edu.degree,
              subtitle: edu.school,
              onEdit: () => _showEducationDialog(context, portfolio, education: edu),
              onDelete: () => portfolio.deleteEducation(edu.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showEducationDialog(context, portfolio),
            backgroundColor: const Color(0xFF00E5FF),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: portfolio.services.length,
          itemBuilder: (context, index) {
            final service = portfolio.services[index];
            return _buildListItem(
              title: service.title,
              subtitle: service.description,
              onEdit: () => _showServiceDialog(context, portfolio, service: service),
              onDelete: () => portfolio.deleteService(service.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showServiceDialog(context, portfolio),
            backgroundColor: const Color(0xFFBD00FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: portfolio.skills.map((skill) => GestureDetector(
              onTap: () => _showSkillDialog(context, portfolio, oldSkill: skill),
              child: Chip(
                avatar: skill.resolvedLogoUrl != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: skill.resolvedLogoUrl!.toLowerCase().endsWith('.svg')
                            ? SvgPicture.network(
                                skill.resolvedLogoUrl!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) => const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF00E5FF)),
                                ),
                              )
                            : Image.network(
                                skill.resolvedLogoUrl!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.code, size: 10, color: Color(0xFF00E5FF)),
                              ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.bolt_outlined, size: 12, color: Color(0xFF00E5FF)),
                      ),
                label: Text(skill.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: const Color(0xFF00E5FF).withAlpha(30),
                side: const BorderSide(color: Color(0xFF00E5FF)),
                deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFFBD00FF)),
                onDeleted: () => portfolio.deleteSkill(skill.name),
              ),
            )).toList(),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showSkillDialog(context, portfolio),
            backgroundColor: const Color(0xFF00E5FF),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildContactEditor(BuildContext context, PortfolioService portfolio) {
    return const _ContactEditorWidget();
  }

  Widget _buildMessagesList(BuildContext context, PortfolioService portfolio) {
    return _MessagesListWidget();
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays} jours';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        color: const Color(0xFF00E5FF),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    String? imageUrl,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: imageUrl != null 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.white10, width: 60, height: 60),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work, color: Color(0xFF00E5FF)),
            ),
        title: Text(
          title,
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF00E5FF), size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFBD00FF), size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDialog(BuildContext context, PortfolioService portfolio, {Project? project}) {
    final titleController = TextEditingController(text: project?.title);
    final descController = TextEditingController(text: project?.description);
    final imageController = TextEditingController(text: project?.imageUrl);
    final videoController = TextEditingController(text: project?.videoUrl);
    final techController = TextEditingController(text: project?.technologies.join(', '));
    String selectedCategory = project?.category ?? 'IoT';
    DateTime? startDate = project?.startDate;
    DateTime? endDate = project?.endDate;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0E21),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5)),
              title: Text(
                project == null ? 'NEW PROJECT' : 'EDIT PROJECT',
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(titleController, 'TITLE'),
                    _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(imageController, 'IMAGE URL')),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => _pickAndUploadImage(portfolio, 'projects', imageController),
                          icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
                          tooltip: 'UPLOAD IMAGE',
                        ),
                      ],
                    ),
                    _buildTextField(videoController, 'VIDEO URL'),
                    _buildTextField(techController, 'TECHNOLOGIES (comma separated)'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => startDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'START DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Text(
                                startDate != null
                                    ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
                                    : "Sélectionner",
                                style: TextStyle(color: startDate != null ? Colors.white : Colors.white38),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => endDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'END DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    endDate != null
                                        ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                                        : "En cours",
                                    style: TextStyle(color: endDate != null ? Colors.white : Colors.white38),
                                  ),
                                  if (endDate != null)
                                    GestureDetector(
                                      onTap: () => setStateDialog(() => endDate = null),
                                      child: const Icon(Icons.clear, size: 16, color: Colors.white38),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF0A0E21),
                      decoration: InputDecoration(
                        labelText: 'CATEGORY',
                        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
                      ),
                      items: ['IoT', 'Embarqué', 'Infrastructure Réseaux', 'Dev Mobile', 'Dev Web', 'Dev Logiciel']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedCategory = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newProject = Project(
                      id: project?.id ?? DateTime.now().toString(),
                      title: titleController.text,
                      description: descController.text,
                      imageUrl: imageController.text,
                      videoUrl: videoController.text,
                      technologies: techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      category: selectedCategory,
                      startDate: startDate,
                      endDate: endDate,
                    );
                    if (project == null) {
                      await portfolio.addProject(newProject);
                    } else {
                      await portfolio.updateProject(newProject);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
                  child: const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showExperienceDialog(BuildContext context, PortfolioService portfolio, {Experience? experience}) {
    final companyController = TextEditingController(text: experience?.company);
    final roleController = TextEditingController(text: experience?.role);
    final descController = TextEditingController(text: experience?.description);
    final locationController = TextEditingController(text: experience?.location);
    DateTime startDate = experience?.startDate ?? DateTime.now();
    DateTime? endDate = experience?.endDate;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0E21),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5)),
              title: Text(
                experience == null ? 'NEW EXPERIENCE' : 'EDIT EXPERIENCE',
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(companyController, 'COMPANY'),
                    _buildTextField(roleController, 'ROLE'),
                    _buildTextField(locationController, 'LOCATION'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => startDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'START DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Text(
                                "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => endDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'END DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    endDate != null 
                                      ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                                      : "Present",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  if (endDate != null)
                                    GestureDetector(
                                      onTap: () => setStateDialog(() => endDate = null),
                                      child: const Icon(Icons.clear, size: 16, color: Colors.white38),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newExp = Experience(
                      id: experience?.id ?? DateTime.now().toString(),
                      company: companyController.text,
                      role: roleController.text,
                      location: locationController.text,
                      description: descController.text,
                      startDate: startDate,
                      endDate: endDate,
                    );
                    if (experience == null) {
                      await portfolio.addExperience(newExp);
                    } else {
                      await portfolio.updateExperience(newExp);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEducationDialog(BuildContext context, PortfolioService portfolio, {Education? education}) {
    final degreeController = TextEditingController(text: education?.degree);
    final schoolController = TextEditingController(text: education?.school);
    final descController = TextEditingController(text: education?.description);
    
    // Tentative de parsing des dates à partir du string period
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    
    if (education != null && education.period.isNotEmpty) {
      try {
        final parts = education.period.split(' - ');
        if (parts.length >= 1) {
          final yearStart = int.tryParse(parts[0].split(' ')[0]);
          if (yearStart != null) startDate = DateTime(yearStart);
        }
        if (parts.length >= 2) {
          final yearEnd = int.tryParse(parts[1].split(' ')[0]);
          if (yearEnd != null) endDate = DateTime(yearEnd);
        }
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0E21),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5)),
              title: Text(
                education == null ? 'NEW EDUCATION' : 'EDIT EDUCATION',
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(degreeController, 'DEGREE'),
                    _buildTextField(schoolController, 'SCHOOL'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => startDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'START DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Text(
                                "${startDate.year}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setStateDialog(() => endDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'END DATE',
                                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    endDate != null ? "${endDate!.year}" : "En cours",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  if (endDate != null)
                                    GestureDetector(
                                      onTap: () => setStateDialog(() => endDate = null),
                                      child: const Icon(Icons.clear, size: 16, color: Colors.white38),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String period = "${startDate.year}";
                    if (endDate != null) {
                      period += " - ${endDate!.year}";
                    } else {
                      period += " - Présent (en cours)";
                    }

                    final newEdu = Education(
                      id: education?.id ?? DateTime.now().toString(),
                      degree: degreeController.text,
                      school: schoolController.text,
                      period: period,
                      description: descController.text,
                    );
                    if (education == null) {
                      await portfolio.addEducation(newEdu);
                    } else {
                      await portfolio.updateEducation(newEdu);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showServiceDialog(BuildContext context, PortfolioService portfolio, {WorkService? service}) {
    final titleController = TextEditingController(text: service?.title);
    final descController = TextEditingController(text: service?.description);
    final iconController = TextEditingController(text: service?.iconName);

    _showCustomDialog(
      context,
      title: service == null ? 'NEW SERVICE' : 'EDIT SERVICE',
      content: [
        _buildTextField(titleController, 'TITLE'),
        _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
        Row(
          children: [
            Expanded(child: _buildTextField(iconController, 'ICON NAME OR IMAGE URL')),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _pickAndUploadImage(portfolio, 'services', iconController),
              icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
              tooltip: 'UPLOAD IMAGE',
            ),
          ],
        ),
      ],
      onSave: () async {
        final newService = WorkService(
          id: service?.id ?? DateTime.now().toString(),
          title: titleController.text,
          description: descController.text,
          iconName: iconController.text,
        );
        if (service == null) {
          await portfolio.addService(newService);
        } else {
          await portfolio.updateService(newService);
        }
      },
    );
  }

  void _showSkillDialog(BuildContext context, PortfolioService portfolio, {Skill? oldSkill}) {
    final skillController = TextEditingController(text: oldSkill?.name);
    final logoController = TextEditingController(text: oldSkill?.logoUrl);
    _showCustomDialog(
      context,
      title: oldSkill == null ? 'ADD SKILL' : 'EDIT SKILL',
      content: [
        _buildTextField(skillController, 'SKILL NAME'),
        Row(
          children: [
            Expanded(child: _buildTextField(logoController, 'LOGO IMAGE URL (Optional)')),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _pickAndUploadImage(portfolio, 'skills', logoController),
              icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
              tooltip: 'UPLOAD IMAGE',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          child: Text(
            'Tip: Use a direct image URL (PNG/SVG). Leave empty to use auto-detected logo.',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ),
      ],
      onSave: () async {
        final name = skillController.text.trim();
        final logo = logoController.text.trim();
        debugPrint('[SkillDialog] Saving skill: name="$name", logo="$logo"');
        if (name.isNotEmpty) {
          final newSkill = Skill(
            name: name,
            logoUrl: logo.isNotEmpty ? logo : null,
          );
          if (oldSkill == null) {
            await portfolio.addSkill(newSkill);
          } else {
            await portfolio.updateSkill(oldSkill, newSkill);
          }
        }
      },
    );
  }

  void _showCustomDialog(BuildContext context, {required String title, required List<Widget> content, required Future<void> Function() onSave}) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AsyncSaveDialog(
        title: title,
        content: content,
        onSave: onSave,
        parentContext: context,
      ),
    );
  }

  Future<void> _registerFace(PortfolioService portfolio, TextEditingController controller) async {
    try {
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OPENING LIVE CAMERA...'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(seconds: 2),
            ),
          );
        }

        final authService = context.read<AuthService>();
        final bool enrolled = await authService.enrollWithLiveCamera();

        if (enrolled && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('FACE ENROLLED SUCCESSFULLY!'),
              backgroundColor: Color(0xFFBD00FF),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('COULD NOT ENROLL FACE. TRY AGAIN.'), backgroundColor: Colors.red),
          );
        }
        return; // Exit early since we handled web live camera
      }

      // Fallback for mobile
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('EXTRACTING FACE FEATURES...'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Step 1: Enroll Face (Generate Descriptor)
        final authService = context.read<AuthService>();
        final bool enrolled = await authService.enrollFace(base64Image);

        if (!enrolled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('COULD NOT DETECT FACE. TRY AGAIN.'), backgroundColor: Colors.red),
            );
          }
          return;
        }

        // Step 2: Upload Image for UI purposes
        final platformFile = PlatformFile(
          name: photo.name,
          size: bytes.length,
          bytes: bytes,
          path: kIsWeb ? null : photo.path,
        );

        final url = await portfolio.uploadImage(platformFile, 'profile');
        if (url != null) {
          controller.text = url;
          await portfolio.updateProfile(profileImageUrl: url);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('FACE REGISTERED AND ENROLLED SUCCESSFULLY!'),
                backgroundColor: Color(0xFFBD00FF),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage(PortfolioService portfolio, String path, TextEditingController controller) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.single.bytes != null || (result?.files.single.path != null)) {
        final url = await portfolio.uploadImage(result!.files.single, path);
        if (url != null) {
          controller.text = url;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully!'), backgroundColor: Color(0xFF00E5FF)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e\nCheck if "Portefeuille" bucket exists and is public.'),
            backgroundColor: const Color(0xFFBD00FF),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
        ),
      ),
    );
  }

  Widget _buildIoTDesignsList(BuildContext context, PortfolioService portfolio) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: portfolio.iotDesigns.length,
          itemBuilder: (context, index) {
            final design = portfolio.iotDesigns[index];
            return _buildListItem(
              title: design.title,
              subtitle: design.description,
              imageUrl: design.thumbnailUrl,
              onEdit: () => _showIoTDesignDialog(context, portfolio, design: design),
              onDelete: () => portfolio.deleteIoTDesign(design.id),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showIoTDesignDialog(context, portfolio),
            backgroundColor: const Color(0xFFBD00FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showIoTDesignDialog(BuildContext context, PortfolioService portfolio, {IoTDesign? design}) {
    final titleController = TextEditingController(text: design?.title);
    final descController = TextEditingController(text: design?.description);
    final proteusController = TextEditingController(text: design?.proteusUrl);
    final codeController = TextEditingController(text: design?.codeUrl);
    final thumbController = TextEditingController(text: design?.thumbnailUrl);

    _showCustomDialog(
      context,
      title: design == null ? 'NEW IoT DESIGN' : 'EDIT IoT DESIGN',
      content: [
        _buildTextField(titleController, 'TITLE'),
        _buildTextField(descController, 'DESCRIPTION', maxLines: 3),
        Row(
          children: [
            Expanded(child: _buildTextField(proteusController, 'PROTEUS FILE URL (.pdsprj)')),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  final url = await portfolio.uploadImage(result.files.single, 'iot/designs');
                  if (url != null) proteusController.text = url;
                }
              },
              icon: const Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
              tooltip: 'UPLOAD PROTEUS FILE',
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField(codeController, 'ARDUINO CODE URL (.ino / .zip)')),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  final url = await portfolio.uploadImage(result.files.single, 'iot/code');
                  if (url != null) codeController.text = url;
                }
              },
              icon: const Icon(Icons.code, color: Color(0xFFBD00FF)),
              tooltip: 'UPLOAD CODE FILE',
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField(thumbController, 'THUMBNAIL IMAGE URL')),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _pickAndUploadImage(portfolio, 'iot/thumbs', thumbController),
              icon: const Icon(Icons.image_outlined, color: Color(0xFF00E5FF)),
              tooltip: 'UPLOAD THUMBNAIL',
            ),
          ],
        ),
      ],
      onSave: () async {
        final newDesign = IoTDesign(
          id: design?.id ?? '',
          title: titleController.text,
          description: descController.text,
          proteusUrl: proteusController.text,
          codeUrl: codeController.text,
          thumbnailUrl: thumbController.text,
          createdAt: design?.createdAt ?? DateTime.now(),
        );
        if (design == null) {
          await portfolio.addIoTDesign(newDesign);
        } else {
          await portfolio.updateIoTDesign(newDesign);
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
// Stateful Contact Editor (prevents reset on rebuild)
// ─────────────────────────────────────────────
class _ContactEditorWidget extends StatefulWidget {
  const _ContactEditorWidget();

  @override
  State<_ContactEditorWidget> createState() => _ContactEditorWidgetState();
}

class _ContactEditorWidgetState extends State<_ContactEditorWidget> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final portfolio = context.read<PortfolioService>();
      _emailController    = TextEditingController(text: portfolio.contact['email'] ?? '');
      _phoneController    = TextEditingController(text: portfolio.contact['phone'] ?? '');
      _linkedinController = TextEditingController(text: portfolio.contact['linkedin'] ?? '');
      _githubController   = TextEditingController(text: portfolio.contact['github'] ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(25))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF), width: 2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.read<PortfolioService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTACT INFORMATION',
            style: GoogleFonts.orbitron(color: const Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          _field(_emailController, 'EMAIL'),
          _field(_phoneController, 'PHONE NUMBER'),
          _field(_linkedinController, 'LINKEDIN URL'),
          _field(_githubController, 'GITHUB URL'),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await portfolio.updateContact('email',    _emailController.text);
                await portfolio.updateContact('phone',    _phoneController.text);
                await portfolio.updateContact('linkedin', _linkedinController.text);
                await portfolio.updateContact('github',   _githubController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact info updated successfully!'),
                      backgroundColor: Color(0xFF00E5FF),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('SAVE CHANGES', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesListWidget extends StatefulWidget {
  const _MessagesListWidget();

  @override
  State<_MessagesListWidget> createState() => _MessagesListWidgetState();
}

class _MessagesListWidgetState extends State<_MessagesListWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await context.read<PortfolioService>().loadMessages();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final messages = portfolio.messages;
        
        return Stack(
          children: [
            messages.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mark_email_unread_outlined, color: Colors.white12, size: 80),
                        const SizedBox(height: 16),
                        Text('Aucun message reçu', style: GoogleFonts.orbitron(color: Colors.white24, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final timeAgo = _formatDate(msg.createdAt);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: msg.isRead ? Colors.white.withAlpha(8) : const Color(0xFF00E5FF).withAlpha(15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: msg.isRead ? const Color(0xFF00E5FF).withAlpha(40) : const Color(0xFF00E5FF).withAlpha(100),
                            width: msg.isRead ? 1 : 1.5,
                          ),
                          boxShadow: [
                            if (!msg.isRead)
                              BoxShadow(color: const Color(0xFF00E5FF).withAlpha(20), blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: (msg.isRead ? const Color(0xFF00E5FF) : const Color(0xFFBD00FF)).withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        msg.isRead ? Icons.person_outline : Icons.mark_email_unread_outlined,
                                        color: msg.isRead ? const Color(0xFF00E5FF) : const Color(0xFFBD00FF),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.name,
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            final uri = Uri.parse('mailto:${msg.email}');
                                            if (await canLaunchUrl(uri)) launchUrl(uri);
                                          },
                                          child: Text(
                                            msg.email,
                                            style: const TextStyle(
                                              color: Color(0xFF00E5FF),
                                              fontSize: 12,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(timeAgo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                    const SizedBox(width: 8),
                                    if (!msg.isRead)
                                      IconButton(
                                        icon: const Icon(Icons.done_all, color: Color(0xFF00E5FF), size: 20),
                                        tooltip: 'Marquer comme lu',
                                        onPressed: () => portfolio.markMessageAsRead(msg.id),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                                      tooltip: 'Supprimer',
                                      onPressed: () => portfolio.deleteMessage(msg.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(60),
                                borderRadius: BorderRadius.circular(10),
                                border: !msg.isRead ? Border.all(color: const Color(0xFF00E5FF).withAlpha(30)) : null,
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: msg.isRead ? Colors.white70 : Colors.white,
                                  fontSize: 14,
                                  height: 1.6,
                                  fontWeight: msg.isRead ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.05, end: 0);
                    },
                  ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: _isLoading ? null : _loadMessages,
                backgroundColor: const Color(0xFF00E5FF),
                tooltip: 'Rafraîchir',
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.refresh, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays} jours';
  }
}

/// A dialog that properly awaits an async save callback
/// and shows loading indicator + error feedback.
class _AsyncSaveDialog extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final Future<void> Function() onSave;
  final BuildContext parentContext;

  const _AsyncSaveDialog({
    required this.title,
    required this.content,
    required this.onSave,
    required this.parentContext,
  });

  @override
  State<_AsyncSaveDialog> createState() => _AsyncSaveDialogState();
}

class _AsyncSaveDialogState extends State<_AsyncSaveDialog> {
  bool _isSaving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: const Color(0xFF0A0E21),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.content,
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFFF4444), fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() {
                      _isSaving = true;
                      _error = null;
                    });
                    try {
                      await widget.onSave();
                      if (mounted) Navigator.pop(context);
                      if (widget.parentContext.mounted) {
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Saved successfully!'),
                            backgroundColor: Color(0xFF00E5FF),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isSaving = false;
                          _error = 'Error: ${e.toString()}';
                        });
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

