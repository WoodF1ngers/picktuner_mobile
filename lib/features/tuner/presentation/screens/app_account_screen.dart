import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';

class AppAccountScreen extends StatelessWidget {
  const AppAccountScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature estará disponible próximamente.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkNeutralBackground
        : AppColors.lightNeutralBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cuenta',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario PickTuner',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'usuario@ejemplo.com',
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Cuenta básica',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _AccountSectionHeader(title: 'CUENTA', isDark: isDark),
            const SizedBox(height: 10),
            _AccountCard(
              isDark: isDark,
              children: [
                _AccountTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Editar perfil',
                  subtitle: 'Nombre, foto y datos básicos',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Editar perfil'),
                ),
                _AccountDivider(isDark: isDark),
                _AccountTile(
                  icon: Icons.email_outlined,
                  title: 'Correo electrónico',
                  subtitle: 'usuario@ejemplo.com',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Gestión de correo'),
                ),
                _AccountDivider(isDark: isDark),
                _AccountTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Seguridad y contraseña',
                  subtitle: 'Protege el acceso a tu cuenta',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Seguridad y contraseña'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _AccountSectionHeader(
              title: 'DATOS Y SINCRONIZACIÓN',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _AccountCard(
              isDark: isDark,
              children: [
                _AccountTile(
                  icon: Icons.cloud_outlined,
                  title: 'Sincronizar preferencias',
                  subtitle: 'Ajustes, afinaciones y configuración',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Sincronización'),
                ),
                _AccountDivider(isDark: isDark),
                _AccountTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Mis favoritos',
                  subtitle: 'Acordes y afinaciones guardadas',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Mis favoritos'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _AccountSectionHeader(title: 'SOPORTE', isDark: isDark),
            const SizedBox(height: 10),
            _AccountCard(
              isDark: isDark,
              children: [
                _AccountTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Recordatorios y novedades',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Notificaciones'),
                ),
                _AccountDivider(isDark: isDark),
                _AccountTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda y soporte',
                  subtitle: 'Preguntas frecuentes y contacto',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Ayuda y soporte'),
                ),
                _AccountDivider(isDark: isDark),
                _AccountTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacidad',
                  subtitle: 'Datos y permisos de la aplicación',
                  isDark: isDark,
                  onTap: () => _comingSoon(context, 'Privacidad'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _comingSoon(context, 'Inicio de sesión'),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Iniciar sesión / Crear cuenta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Cuenta y sincronización estarán disponibles próximamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _AccountSectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _AccountCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: primaryColor, size: 21),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: subtitleColor, fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: subtitleColor,
        size: 19,
      ),
    );
  }
}

class _AccountDivider extends StatelessWidget {
  final bool isDark;

  const _AccountDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08),
    );
  }
}
