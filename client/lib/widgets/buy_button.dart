import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';

class BuyButton extends StatelessWidget {
  final String itemName;
  final String category;
  final String? subcategory;
  final bool isDark;

  const BuyButton({
    super.key,
    required this.itemName,
    required this.category,
    this.subcategory,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showMarketplaceOptions(context),
      icon: const Icon(Icons.shopping_bag, size: 18),
      label: const Text('Купить'),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDark ? const Color(0xFF10B981) : const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _showMarketplaceOptions(BuildContext context) async {
    final marketplaceService = MarketplaceService();

    // Показываем loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Получаем ссылки
    final links = await marketplaceService.getLinksForItem(
      itemName: itemName,
      category: category,
      subcategory: subcategory,
    );

    // Закрываем loading
    if (context.mounted) Navigator.pop(context);

    if (links.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ссылки на маркетплейсы не найдены'),
          ),
        );
      }
      return;
    }

    // Показываем опции
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _MarketplaceSheet(
          itemName: itemName,
          links: links,
          isDark: isDark,
          onLinkTap: (link) async {
            if (context.mounted) Navigator.pop(context);
            await _openMarketplace(context, link);
          },
        ),
      );
    }
  }

  Future<void> _openMarketplace(
    BuildContext context,
    MarketplaceLink link,
  ) async {
    final marketplaceService = MarketplaceService();
    await marketplaceService.trackClick(
      userId: 1,
      itemName: itemName,
      marketplace: link.marketplace,
      category: category,
    );

    // Open URL
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть ${link.name}'),
          ),
        );
      }
    }
  }
}

class _MarketplaceSheet extends StatelessWidget {
  final String itemName;
  final List<MarketplaceLink> links;
  final bool isDark;
  final Function(MarketplaceLink) onLinkTap;

  const _MarketplaceSheet({
    required this.itemName,
    required this.links,
    required this.isDark,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.textSecondary.withValues(alpha: 0.3)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Купить: $itemName',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Выберите маркетплейс',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textSecondary : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Links
          ...links
              .map((link) => _buildMarketplaceButton(link)), // Added toList()

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : const Color(0xFF007bff).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Партнерские ссылки помогают развивать приложение',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondary : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceButton(MarketplaceLink link) {
    // Fixed method name
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onLinkTap(link),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.backgroundDark : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: link.marketplace == 'wildberries'
                        ? const LinearGradient(
                            colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      link.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimary : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Комиссия: ${link.commission}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? AppTheme.textSecondary : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
