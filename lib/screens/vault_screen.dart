import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Vault Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withAlpha(51)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(25),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'VAULT SECURED',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AES-256 Encryption Active',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppTheme.primary.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section Header
            Text(
              'STORED CREDENTIALS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            // Vault Items
            ..._vaultItems.map((item) => _buildVaultItem(item)),
            const SizedBox(height: 24),
            // Encryption Keys Section
            Text(
              'ENCRYPTION KEYS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            ..._keyItems.map((item) => _buildKeyItem(item)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultItem(_VaultItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(128),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  item.type,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isActive
                  ? AppTheme.primary.withAlpha(25)
                  : AppTheme.danger.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.isActive
                    ? AppTheme.primary.withAlpha(77)
                    : AppTheme.danger.withAlpha(77),
              ),
            ),
            child: Text(
              item.isActive ? 'ACTIVE' : 'EXPIRED',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: item.isActive ? AppTheme.primary : AppTheme.danger,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyItem(_KeyItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.terminalBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key_outlined, color: AppTheme.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  item.fingerprint,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AppTheme.primary.withAlpha(102),
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.algorithm,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  List<_VaultItem> get _vaultItems => [
    _VaultItem('API Gateway Key', 'BEARER_TOKEN', Icons.key_outlined, true),
    _VaultItem(
        'DB Master Password', 'SECRET_STRING', Icons.lock_outlined, true),
    _VaultItem('OAuth2 Client Secret', 'CLIENT_CREDENTIAL',
        Icons.verified_user_outlined, true),
    _VaultItem(
        'Legacy API Token', 'DEPRECATED', Icons.warning_amber_outlined, false),
  ];

  List<_KeyItem> get _keyItems => [
    _KeyItem('RSA_PRODUCTION_KEY', 'SHA256:a1b2c...x9z0', 'RSA-4096'),
    _KeyItem('ECDSA_SIGNING_KEY', 'SHA256:k3m4n...w7y8', 'ECDSA-P384'),
    _KeyItem('AES_VAULT_MASTER', 'SHA256:f5g6h...u3v4', 'AES-256-GCM'),
  ];
}

class _VaultItem {
  final String name;
  final String type;
  final IconData icon;
  final bool isActive;
  _VaultItem(this.name, this.type, this.icon, this.isActive);
}

class _KeyItem {
  final String name;
  final String fingerprint;
  final String algorithm;
  _KeyItem(this.name, this.fingerprint, this.algorithm);
}
