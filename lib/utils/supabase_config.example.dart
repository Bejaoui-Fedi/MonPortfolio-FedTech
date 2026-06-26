// ⚠️  NE PAS COMMITTER CE FICHIER AVEC DE VRAIES CLÉS
//
// INSTRUCTIONS :
// 1. Copiez ce fichier : supabase_config.example.dart → supabase_config.dart
// 2. Remplissez avec vos propres credentials Supabase
// 3. supabase_config.dart est ignoré par git (.gitignore) → vos clés restent privées
//
// Où trouver ces valeurs ?
//   → https://app.supabase.com → Votre projet → Settings → API

class SupabaseConfig {
  static const String url = 'https://VOTRE_ID_PROJET.supabase.co';
  static const String anonKey = 'VOTRE_ANON_KEY_ICI';
}
