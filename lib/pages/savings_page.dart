import 'package:flutter/material.dart';
import 'package:fund_divider/model/export_excel.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/savings/add_savings.dart';
import 'package:fund_divider/popups/savings/deposit_saving.dart';
import 'package:fund_divider/popups/savings/edit_savings.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> with SingleTickerProviderStateMixin {
  bool _isFabOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _backdropAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _backdropAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  // Function to show add savings dialog
  void _showAddSavingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddSavings();
      },
    ).then((_) {
      _toggleFab();
    });
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
          final isVerySmall = screenWidth < 320;
          
          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Rounded AppBar yang responsif
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      expandedHeight: isLandscape ? 120 : 120,
                      floating: false,
                      pinned: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
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
                              padding: EdgeInsets.fromLTRB(
                                isSmallScreen ? 16 : 20,
                                12,
                                isSmallScreen ? 16 : 20,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title Row dengan statistik ringkas
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Savings",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: isSmallScreen ? 20 : 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            ValueListenableBuilder(
                                              valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                                              builder: (context, Box<Savings> box, _) {
                                                double totalSavings = 0;
                                                for (var saving in box.values) {
                                                  totalSavings += saving.amount;
                                                }
                                                
                                                return Row(
                                                  children: [
                                                    Icon(
                                                      Icons.account_balance_wallet,
                                                      color: const Color(0xff6F41F2),
                                                      size: isSmallScreen ? 12 : 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        formatRupiah(totalSavings),
                                                        style: TextStyle(
                                                          color: const Color(0xff6F41F2),
                                                          fontSize: isSmallScreen ? 13 : 15,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Goals Counter
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 8 : 10,
                                          vertical: isSmallScreen ? 4 : 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff6F41F2).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                                          builder: (context, Box<Savings> box, _) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.flag_outlined,
                                                  color: const Color(0xff6F41F2),
                                                  size: isSmallScreen ? 12 : 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${box.length}",
                                                  style: TextStyle(
                                                    color: const Color(0xff6F41F2),
                                                    fontSize: isSmallScreen ? 13 : 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  
                                  // Subtitle dengan informasi tambahan
                                  ValueListenableBuilder(
                                    valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                                    builder: (context, Box<Savings> box, _) {
                                      if (box.isEmpty) {
                                        return Text(
                                          "Start your savings journey",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: isSmallScreen ? 11 : 12,
                                          ),
                                        );
                                      }
                                      
                                      int goalsWithTarget = box.values.where((s) => s.target > 0).length;
                                      int completedGoals = box.values.where((s) => s.target > 0 && s.amount >= s.target).length;
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (goalsWithTarget > 0)
                                            Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    "$completedGoals/$goalsWithTarget goals completed",
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: isSmallScreen ? 10 : 11,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tambahkan spacing setelah AppBar
                    SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    
                    // Savings List
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                      builder: (context, Box<Savings> box, _) {
                        if (box.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(isVerySmall ? 16 : 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isVerySmall ? 16 : 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff6F41F2).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.savings_outlined,
                                        color: const Color(0xff6F41F2),
                                        size: isLandscape ? 36 : 44,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No savings goals yet",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: isLandscape ? 16 : 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLandscape ? 20 : 40,
                                      ),
                                      child: Text(
                                        "Create your first savings goal to start growing your money",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: isLandscape ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final savings = box.values.toList();
                        
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final saving = savings[index];
                              double remainingTarget = saving.target - saving.amount;
                              bool isMainSaving = saving.target == 0;
                              double progress = saving.target > 0 
                                  ? (saving.amount / saving.target).clamp(0.0, 1.0)
                                  : 0.0;
                              
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isSmallScreen ? 12 : 16,
                                  index == 0 ? 4 : 8,
                                  isSmallScreen ? 12 : 16,
                                  index == savings.length - 1 ? 100 : 0,
                                ),
                                child: _buildSavingCard(
                                  context,
                                  saving,
                                  progress: progress,
                                  isMainSaving: isMainSaving,
                                  remainingTarget: remainingTarget,
                                  isSmallScreen: isSmallScreen,
                                  isLandscape: isLandscape,
                                ),
                              );
                            },
                            childCount: savings.length,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Backdrop dengan animasi
              AnimatedBuilder(
                animation: _backdropAnimation,
                builder: (context, child) {
                  return Visibility(
                    visible: _isFabOpen,
                    child: Opacity(
                      opacity: _backdropAnimation.value,
                      child: GestureDetector(
                        onTap: _toggleFab,
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Expandable FAB dengan animasi
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Add New Goal Button dengan animasi slide
                    AnimatedBuilder(
                      animation: _fabAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -60 * (1 - _fabAnimation.value)),
                          child: Opacity(
                            opacity: _fabAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFabOption(
                          icon: Icons.add_chart_rounded,
                          label: "Add Goal",
                          color: const Color(0xff6F41F2),
                          onTap: _showAddSavingsDialog,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ),
                    
                    // Main FAB dengan animasi rotasi
                    GestureDetector(
                      onTap: _toggleFab,
                      child: AnimatedBuilder(
                        animation: _fabAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _fabAnimation.value * (0.125 * 3.14159),
                            child: Container(
                              width: isSmallScreen ? 56 : 60,
                              height: isSmallScreen ? 56 : 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff6F41F2),
                                    Color(0xff5A32D6),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff6F41F2).withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isFabOpen ? Icons.close : Icons.add,
                                color: Colors.white,
                                size: isSmallScreen ? 26 : 28,
                              ),
                            ),
                          );
                        },
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

  Widget _buildSavingCard(
    BuildContext context,
    Savings saving, {
    required double progress,
    required bool isMainSaving,
    required double remainingTarget,
    required bool isSmallScreen,
    required bool isLandscape,
  }) {
    return Dismissible(
      key: Key(saving.id.toString()),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Show deposit dialog
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return DepositSaving(savingId: saving.id);
            },
          );
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Show edit dialog
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditSavings(savingsId: saving.id);
            },
          );
          return false;
        }
        return false;
      },
      
      // Background untuk swipe KANAN (Edit) - warna amber
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade400,
              Colors.amber.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Edit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      
      // Background untuk swipe ke KIRI (Deposit) - warna hijau
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Deposit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return EditSavings(savingsId: saving.id);
              },
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color: isMainSaving
                            ? const Color(0xff6F41F2).withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMainSaving
                            ? Icons.account_balance_wallet
                            : Icons.savings_outlined,
                        color: isMainSaving
                            ? const Color(0xff6F41F2)
                            : Colors.green,
                        size: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    
                    SizedBox(width: isSmallScreen ? 12 : 14),
                    
                    // Savings Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            saving.description,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isMainSaving 
                                ? "Main Savings Account"
                                : "Target: ${formatRupiah(saving.target)}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Current Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah(saving.amount),
                          style: TextStyle(
                            color: isMainSaving
                                ? const Color(0xff6F41F2)
                                : Colors.green,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isMainSaving
                                ? const Color(0xff6F41F2).withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMainSaving ? "Main" : "Savings",
                            style: TextStyle(
                              color: isMainSaving
                                  ? const Color(0xff6F41F2)
                                  : Colors.green,
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Progress Bar untuk savings dengan target
                if (!isMainSaving && saving.target > 0) ...[
                  const SizedBox(height: 12),
                  
                  // Progress Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Progress Bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Remaining Amount
                  Text(
                    remainingTarget > 0 
                        ? "${formatRupiah(remainingTarget)} left to reach target"
                        : "🎉 Target achieved!",
                    style: TextStyle(
                      color: remainingTarget > 0 ? Colors.black54 : Colors.green,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: remainingTarget > 0 ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}