
import 'package:cii/models/tier_limits.dart';
import 'package:cii/services/premium_service.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class PremiumUpgradePage extends StatefulWidget {
  const PremiumUpgradePage({super.key});

  @override
  State<PremiumUpgradePage> createState() => _PremiumUpgradePageState();
}

class _PremiumUpgradePageState extends State<PremiumUpgradePage> {
  bool _isLoading = false;

  Widget _buildFeatureRow(String feature, String freeValue, String proValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(freeValue, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(proValue, textAlign: TextAlign.center, style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTierStatus() {
    final isPremium = PremiumService.instance.isPremium;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? AppColors.primaryGreen.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.star : Icons.star_border,
            color: isPremium ? AppColors.primaryGreen : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPremium ? 'Pro User' : 'Free User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPremium ? AppColors.primaryGreen : Colors.grey,
                ),
              ),
              Text(
                isPremium ? 'You have access to all features' : 'Upgrade to unlock all features',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _buyPremium() async {
    setState(() => _isLoading = true);
    try {
      await PremiumService.instance.buyPremium();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    try {
      await PremiumService.instance.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PremiumService.instance.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentTierStatus(),
            const SizedBox(height: 32),
            
            const Text(
              'Feature Comparison',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Free', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Pro', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildFeatureRow('Projects', '${TierLimits.free.maxProjects}', 'Unlimited'),
                        _buildFeatureRow('${AppStrings.snags()} per project', '${TierLimits.free.maxSnagsPerProject}', '${TierLimits.pro.maxSnagsPerProject}'),
                        _buildFeatureRow('PDF Export', TierLimits.free.allowPdfExport ? '✓' : '✗', '✓'),
                        _buildFeatureRow('PDF Themes', TierLimits.free.allowPdfThemeChange ? '✓' : '✗', '✓'),
                        _buildFeatureRow('PDF Quality Control', TierLimits.free.allowPdfQualityChange ? '✓' : '✗', '✓'),
                        _buildFeatureRow('PDF Customizer', TierLimits.free.allowPdfCustomizer ? '✓' : '✗', '✓'),
                        _buildFeatureRow('CSV Export', TierLimits.free.allowCsvExport ? '✓' : '✗', '✓'),
                        _buildFeatureRow('Create Categories', TierLimits.free.allowCreateCategory ? '✓' : '✗', '✓'),
                        _buildFeatureRow('Tags', '${TierLimits.free.maxTags}', 'Unlimited'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (!isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _buyPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upgrade to Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : _restorePurchases,
                  child: const Text('Restore Purchases'),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You already have Pro! Enjoy all the premium features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
