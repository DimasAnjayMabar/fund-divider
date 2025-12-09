import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/username/username_popup.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String formatRupiahWithDot(double value) {
    // Format angka dengan pemisah ribuan (titik) tanpa desimal
    final formatter = NumberFormat("#,###", "id_ID");
    return "Rp ${formatter.format(value.toInt())}";
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  // Fungsi untuk membuka URL GitHub Releases di browser device
  Future<void> _launchGitHubReleases() async {
    const url = 'https://github.com/DimasAnjayMabar/fund-divider/releases';
    final uri = Uri.parse(url);
    
    try {
      // Gunakan launchUrl langsung tanpa canLaunchUrl
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Ini akan membuka di browser eksternal
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      
      if (!result && mounted) {
        // Jika launchUrl mengembalikan false, tampilkan dialog error
        _showLaunchErrorDialog(url);
      }
    } catch (e) {
      if (!mounted) return;
      
      _showLaunchErrorDialog(url);
    }
  }

  void _showLaunchErrorDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cannot Open Link"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Unable to open GitHub releases."),
            const SizedBox(height: 8),
            const Text("You can manually visit:"),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("URL copied to clipboard")),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  url,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Or try to open in:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.inAppWebView, // Coba dengan webview internal
                      );
                    },
                    icon: const Icon(Icons.web, size: 16),
                    label: const Text("In-app Browser"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalNonBrowserApplication, // Coba dengan aplikasi lain
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text("External App"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isLandscape = screenWidth > screenHeight;
          final isSmallScreen = screenWidth < 360;
          final isVerySmall = screenWidth < 300;
          final isLargeScreen = screenWidth > 600;
          final isDesktop = screenWidth > 900;
          
          // Hitung tinggi AppBar secara dinamis
          final appBarHeight = () {
            if (isDesktop) return 280.0;
            if (isLargeScreen) return 280.0;
            if (isLandscape) return 280.0;
            if (isSmallScreen) return 280.0;
            return 280.0;
          }();
          
          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // AppBar yang sangat responsif
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      expandedHeight: appBarHeight,
                      floating: false,
                      pinned: true,
                      snap: false,
                      stretch: true,
                      elevation: 2,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      flexibleSpace: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          final innerWidth = innerConstraints.maxWidth;
                          final isNarrow = innerWidth < 400;
                          final isUltraNarrow = innerWidth < 350;
                          
                          return FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            stretchModes: const [StretchMode.zoomBackground],
                            background: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              child: SafeArea(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 16 : 24,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title Section
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Settings",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: isUltraNarrow ? 22 : 
                                                             isNarrow ? 24 : 
                                                             isLargeScreen ? 28 : 26,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Manage your app preferences",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: isUltraNarrow ? 11 : 
                                                             isNarrow ? 12 : 
                                                             isLargeScreen ? 14 : 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          if (!isUltraNarrow) // Sembunyikan ikon di layar sangat sempit
                                          Container(
                                            padding: EdgeInsets.all(isNarrow ? 8 : 10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff6F41F2).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.settings_outlined,
                                              color: const Color(0xff6F41F2),
                                              size: isNarrow ? 20 : 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Stats Cards - Wallet full width, Savings/Expenses below
                                      StreamBuilder<double>(
                                        stream: WalletService.watchWalletBalance(),
                                        initialData: WalletService.getBalance(),
                                        builder: (context, walletSnapshot) {
                                          return StreamBuilder<int>(
                                            stream: WalletService.watchSavingsCount(),
                                            initialData: WalletService.getSavingsCount(),
                                            builder: (context, savingsSnapshot) {
                                              return StreamBuilder<int>(
                                                stream: WalletService.watchExpenseCount(),
                                                initialData: WalletService.getExpensesCount(),
                                                builder: (context, expensesSnapshot) {
                                                  return Column(
                                                    children: [
                                                      // Wallet Balance - Full width row
                                                      _buildFullWidthWalletCard(
                                                        walletSnapshot.data ?? 0.0,
                                                        isNarrow,
                                                        isLargeScreen,
                                                      ),
                                                      
                                                      const SizedBox(height: 12),
                                                      
                                                      // Savings & Expenses - Row below
                                                      Row(
                                                        children: [
                                                          // Savings Card - Half width
                                                          Expanded(
                                                            child: _buildHalfWidthCountCard(
                                                              "Savings",
                                                              savingsSnapshot.data?.toDouble() ?? 0.0,
                                                              Icons.savings,
                                                              isNarrow,
                                                              isLargeScreen,
                                                            ),
                                                          ),
                                                          
                                                          SizedBox(width: isNarrow ? 8 : 12),
                                                          
                                                          // Expenses Card - Half width
                                                          Expanded(
                                                            child: _buildHalfWidthCountCard(
                                                              "Expenses",
                                                              expensesSnapshot.data?.toDouble() ?? 0.0,
                                                              Icons.receipt_long,
                                                              isNarrow,
                                                              isLargeScreen,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Tambahkan spacing setelah AppBar
                    SliverToBoxAdapter(
                      child: SizedBox(height: isSmallScreen ? 16 : 20),
                    ),
                    
                    // Settings Options List
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : 
                                    isLargeScreen ? 24 : 
                                    isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Account Settings Section
                            _buildSectionTitle(
                              "Account Settings",
                              isSmallScreen,
                              isLargeScreen,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildSettingCard(
                              context,
                              title: "Change Username",
                              description: "Update your display name",
                              icon: Icons.person_outline,
                              color: const Color(0xff6F41F2),
                              iconColor: const Color(0xff6F41F2),
                              onTap: () async {
                                final shouldProceed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => ConfirmationPopup(
                                    title: "Change Username",
                                    errorMessage: "Are you sure you want to change your username?",
                                    onConfirm: () {},
                                  ),
                                );
                                
                                if (shouldProceed == true && mounted) {
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) => const SaveUsername(isEditMode: true),
                                  );
                                }
                              },
                              isSmallScreen: isSmallScreen,
                              isLargeScreen: isLargeScreen,
                              isDesktop: isDesktop,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            // Data Management Section
                            _buildSectionTitle(
                              "Data Management",
                              isSmallScreen,
                              isLargeScreen,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildSettingCard(
                              context,
                              title: "Reset Wallet Balance",
                              description: "Set wallet balance back to 0",
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.blue,
                              iconColor: Colors.blue,
                              onTap: () => showDialog(
                                context: context, 
                                builder: (context) => ConfirmationPopup(
                                  title: "Reset Wallet",
                                  errorMessage: "Are you sure you want to reset the wallet balance to 0?",
                                  onConfirm: () async {
                                    await WalletService.resetBalance();
                                  },
                                ),
                              ),
                              isSmallScreen: isSmallScreen,
                              isLargeScreen: isLargeScreen,
                              isDesktop: isDesktop,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            _buildSettingCard(
                              context,
                              title: "Reset Savings",
                              description: "Delete all savings goals and data",
                              icon: Icons.savings_outlined,
                              color: Colors.green,
                              iconColor: Colors.green,
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => ConfirmationPopup(
                                  title: "Reset Savings", 
                                  errorMessage: "Are you sure you want to delete all savings data?", 
                                  onConfirm: () async {
                                    await WalletService.resetSavings();
                                  }
                                ),
                              ),
                              isSmallScreen: isSmallScreen,
                              isLargeScreen: isLargeScreen,
                              isDesktop: isDesktop,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            _buildSettingCard(
                              context,
                              title: "Reset Expenses",
                              description: "Delete all expense records",
                              icon: Icons.receipt_long_outlined,
                              color: Colors.red,
                              iconColor: Colors.red,
                              onTap: () => showDialog(
                                context: context, 
                                builder: (context) => ConfirmationPopup(
                                  title: "Reset Expenses",
                                  errorMessage: "Are you sure you want to delete all expense records?",
                                  onConfirm: () async {
                                    await WalletService.resetExpenses();
                                  },
                                ),
                              ),
                              isSmallScreen: isSmallScreen,
                              isLargeScreen: isLargeScreen,
                              isDesktop: isDesktop,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 20 : 24),
                            
                            // App Information Section
                            _buildSectionTitle(
                              "App Information",
                              isSmallScreen,
                              isLargeScreen,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Container(
                              padding: EdgeInsets.all(isDesktop ? 20 : 
                                                     isLargeScreen ? 18 : 
                                                     isSmallScreen ? 14 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff6F41F2).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.apps_rounded,
                                          color: const Color(0xff6F41F2),
                                          size: isSmallScreen ? 18 : 22,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 14 : 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Piggi",
                                              style: TextStyle(
                                                color: const Color(0xff6F41F2),
                                                fontSize: isDesktop ? 24 : 
                                                         isLargeScreen ? 22 : 
                                                         isSmallScreen ? 18 : 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Personal Finance Manager",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: isDesktop ? 16 : 
                                                         isLargeScreen ? 14 : 
                                                         isSmallScreen ? 12 : 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: Colors.grey[300],
                                    height: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // App Details Grid
                                  LayoutBuilder(
                                    builder: (context, detailsConstraints) {
                                      final detailsWidth = detailsConstraints.maxWidth;
                                      final useGridLayout = detailsWidth > 300;
                                      
                                      if (useGridLayout) {
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildAppDetailItem(
                                                    "Version",
                                                    "1.0.0",
                                                    isSmallScreen,
                                                    isLargeScreen,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildAppDetailItem(
                                                    "Build Date",
                                                    "Dec 2024",
                                                    isSmallScreen,
                                                    isLargeScreen,
                                                  ),
                                                ),
                                                if (detailsWidth > 400)
                                                Expanded(
                                                  child: _buildAppDetailItem(
                                                    "Platform",
                                                    "Flutter",
                                                    isSmallScreen,
                                                    isLargeScreen,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            // UPDATE APP CARD
                                            Material(
                                              borderRadius: BorderRadius.circular(16),
                                              child: InkWell(
                                                onTap: _launchGitHubReleases,
                                                borderRadius: BorderRadius.circular(16),
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                      Color(0xFF4CAF50).withOpacity(0.9),
                                                      Color(0xFF2E7D32).withOpacity(0.9),
                                                    ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.green.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.system_update_alt_rounded,
                                                          color: Colors.white,
                                                          size: isSmallScreen ? 22 : 26,
                                                        ),
                                                      ),
                                                      SizedBox(width: isSmallScreen ? 14 : 18),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Update the App Here",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: isLargeScreen ? 18 : 
                                                                         isSmallScreen ? 16 : 17,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              "Find our releases to download the latest version",
                                                              style: TextStyle(
                                                                color: Colors.white.withOpacity(0.9),
                                                                fontSize: isLargeScreen ? 14 : 
                                                                         isSmallScreen ? 12 : 13,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        color: Colors.white.withOpacity(0.8),
                                                        size: isSmallScreen ? 18 : 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            _buildAppDetailItem(
                                              "Version",
                                              "1.0.0",
                                              isSmallScreen,
                                              isLargeScreen,
                                              fullWidth: true,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildAppDetailItem(
                                              "Build Date",
                                              "Dec 2024",
                                              isSmallScreen,
                                              isLargeScreen,
                                              fullWidth: true,
                                            ),
                                            const SizedBox(height: 12),
                                            // UPDATE APP CARD untuk layout sempit
                                            Material(
                                              borderRadius: BorderRadius.circular(16),
                                              child: InkWell(
                                                onTap: _launchGitHubReleases,
                                                borderRadius: BorderRadius.circular(16),
                                                child: Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF4CAF50).withOpacity(0.9),
                                                        Color(0xFF2E7D32).withOpacity(0.9),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.green.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.system_update_alt_rounded,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Update the App Here",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: isSmallScreen ? 15 : 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              "Find our releases to download the latest version",
                                                              style: TextStyle(
                                                                color: Colors.white.withOpacity(0.9),
                                                                fontSize: isSmallScreen ? 11 : 12,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        color: Colors.white.withOpacity(0.8),
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Spasi untuk FAB (jika ada)
                            SizedBox(height: isDesktop ? 120 : 
                                         isLargeScreen ? 100 : 
                                         isSmallScreen ? 80 : 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk Wallet Balance card (full width)
  Widget _buildFullWidthWalletCard(
    double value,
    bool isNarrow,
    bool isLargeScreen,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16 : 20,
        vertical: isNarrow ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff6F41F2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xff6F41F2).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isNarrow ? 10 : 12),
            decoration: BoxDecoration(
              color: const Color(0xff6F41F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: const Color(0xff6F41F2),
              size: isNarrow ? 20 : 24,
            ),
          ),
          SizedBox(width: isNarrow ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Wallet Balance",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isLargeScreen ? 16 : 
                             isNarrow ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(value),
                  style: TextStyle(
                    color: const Color(0xff6F41F2),
                    fontSize: isLargeScreen ? 24 : 
                             isNarrow ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Savings/Expenses card (half width)
  Widget _buildHalfWidthCountCard(
    String label,
    double value,
    IconData icon,
    bool isNarrow,
    bool isLargeScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 16,
        vertical: isNarrow ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff6F41F2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff6F41F2).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isNarrow ? 8 : 10),
            decoration: BoxDecoration(
              color: const Color(0xff6F41F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xff6F41F2),
              size: isNarrow ? 16 : 20,
            ),
          ),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isLargeScreen ? 14 : 
                             isNarrow ? 11 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: const Color(0xff6F41F2),
                    fontSize: isLargeScreen ? 20 : 
                             isNarrow ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isSmallScreen, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.only(
        left: isLargeScreen ? 8 : 4,
        bottom: isSmallScreen ? 8 : 12,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: isLargeScreen ? 20 : 
                   isSmallScreen ? 17 : 18,
          fontWeight: FontWeight.w600,
        ),
      )
    );
  }

  Widget _buildAppDetailItem(
    String label,
    String value,
    bool isSmallScreen,
    bool isLargeScreen, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: isLargeScreen ? 14 : 
                       isSmallScreen ? 11 : 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xff6F41F2),
              fontSize: isLargeScreen ? 16 : 
                       isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isLargeScreen,
    required bool isDesktop,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 
                                 isLargeScreen ? 18 : 
                                 isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: EdgeInsets.all(isDesktop ? 14 : 
                                      isLargeScreen ? 12 : 
                                      isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isDesktop ? 24 : 
                        isLargeScreen ? 22 : 
                        isSmallScreen ? 18 : 20,
                ),
              ),
              
              SizedBox(width: isDesktop ? 20 : 
                         isLargeScreen ? 18 : 
                         isSmallScreen ? 14 : 16),
              
              // Setting Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isDesktop ? 20 : 
                                 isLargeScreen ? 18 : 
                                 isSmallScreen ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isDesktop ? 16 : 
                                 isLargeScreen ? 14 : 
                                 isSmallScreen ? 12 : 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: isDesktop ? 28 : 
                      isLargeScreen ? 26 : 
                      isSmallScreen ? 22 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}