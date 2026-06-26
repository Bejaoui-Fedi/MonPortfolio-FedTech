class Skill {
  final String name;
  final String? logoUrl;

  Skill({
    required this.name,
    this.logoUrl,
  });

  /// Helper to get the automatic logo mapping based on skill name.
  /// Uses devicons CDN which is fully CORS-compatible for Flutter Web.
  static String? getAutomaticLogo(String skillName) {
    final cleanName = skillName.trim().toLowerCase();

    // Devicons CDN base — 100% CORS-compatible on Flutter Web
    const d = 'https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons';

    // Mapping of common skill names to devicons paths
    final Map<String, String> mappings = {
      'flutter':      '$d/flutter/flutter-original.svg',
      'flutterflow':  '$d/flutter/flutter-original.svg',
      'dart':         '$d/dart/dart-original.svg',
      'java':         '$d/java/java-original.svg',
      'javafx':       '$d/java/java-original.svg',
      'fxml':         '$d/java/java-original.svg',
      'python':       '$d/python/python-original.svg',
      'c++':          '$d/cplusplus/cplusplus-original.svg',
      'cplusplus':    '$d/cplusplus/cplusplus-original.svg',
      'c':            '$d/c/c-original.svg',
      'c#':           '$d/csharp/csharp-original.svg',
      'csharp':       '$d/csharp/csharp-original.svg',
      'javascript':   '$d/javascript/javascript-original.svg',
      'js':           '$d/javascript/javascript-original.svg',
      'typescript':   '$d/typescript/typescript-original.svg',
      'ts':           '$d/typescript/typescript-original.svg',
      'html':         '$d/html5/html5-original.svg',
      'html5':        '$d/html5/html5-original.svg',
      'css':          '$d/css3/css3-original.svg',
      'css3':         '$d/css3/css3-original.svg',
      'php':          '$d/php/php-original.svg',
      'twig':         '$d/php/php-original.svg',
      'mysql':        '$d/mysql/mysql-original.svg',
      'postgresql':   '$d/postgresql/postgresql-original.svg',
      'postgres':     '$d/postgresql/postgresql-original.svg',
      'sqlite':       '$d/sqlite/sqlite-original.svg',
      'mongodb':      '$d/mongodb/mongodb-original.svg',
      'react':        '$d/react/react-original.svg',
      'reactjs':      '$d/react/react-original.svg',
      'angular':      '$d/angular/angular-original.svg',
      'vue':          '$d/vuejs/vuejs-original.svg',
      'vuejs':        '$d/vuejs/vuejs-original.svg',
      'node':         '$d/nodejs/nodejs-original.svg',
      'nodejs':       '$d/nodejs/nodejs-original.svg',
      'express':      '$d/express/express-original.svg',
      'django':       '$d/django/django-plain.svg',
      'flask':        '$d/flask/flask-original.svg',
      'spring':       '$d/spring/spring-original.svg',
      'springboot':   '$d/spring/spring-original.svg',
      'laravel':      '$d/laravel/laravel-original.svg',
      'git':          '$d/git/git-original.svg',
      'docker':       '$d/docker/docker-original.svg',
      'kubernetes':   '$d/kubernetes/kubernetes-original.svg',
      'aws':          '$d/amazonwebservices/amazonwebservices-original-wordmark.svg',
      'firebase':     '$d/firebase/firebase-original.svg',
      'supabase':     '$d/supabase/supabase-original.svg',
      'arduino':      '$d/arduino/arduino-original.svg',
      'raspberry pi': '$d/raspberrypi/raspberrypi-original.svg',
      'linux':        '$d/linux/linux-original.svg',
      'android':      '$d/android/android-original.svg',
      'ios':          '$d/apple/apple-original.svg',
      'apple':        '$d/apple/apple-original.svg',
      'kotlin':       '$d/kotlin/kotlin-original.svg',
      'swift':        '$d/swift/swift-original.svg',
      'go':           '$d/go/go-original-wordmark.svg',
      'golang':       '$d/go/go-original-wordmark.svg',
      'rust':         '$d/rust/rust-original.svg',
      'symfony':      '$d/symfony/symfony-original.svg',
      'bash':         '$d/bash/bash-original.svg',
    };

    // Substring/Contains matching
    for (var key in mappings.keys) {
      if (cleanName.contains(key)) {
        return mappings[key];
      }
    }
    return null;
  }

  /// Automatically resolves a high-quality PNG logo URL for the skill.
  /// First checks the user-defined `logoUrl`, then falls back to automatic mapping.
  String? get resolvedLogoUrl {
    if (logoUrl != null && logoUrl!.trim().isNotEmpty) {
      return logoUrl;
    }
    return getAutomaticLogo(name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo_url': logoUrl,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      logoUrl: map['logo_url'],
    );
  }
}
