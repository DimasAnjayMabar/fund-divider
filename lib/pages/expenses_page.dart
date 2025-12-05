import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/expenses/add_expense_dialog.dart';
import 'package:fund_divider/popups/expenses/edit_expenses.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with SingleTickerProviderStateMixin {
  bool _isFabOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _backdropAnimation;
  final ImagePicker _picker = ImagePicker();
  
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
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  // Function to open camera
  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        // TODO: Implement receipt scanning logic here
        print('Image captured: ${image.path}');
        
        // For now, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt captured: ${image.path.split('/').last}'),
            backgroundColor: const Color(0xff6F41F2),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Close the expanded FAB
        _toggleFab();
      }
    } catch (e) {
      print('Error opening camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to open camera'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to show add expense dialog
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMainExpenseDialog();
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
          
          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Rounded AppBar dengan statistik
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    expandedHeight: isLandscape ? 220 : 190,
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
                                // Title Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Expenses",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: isSmallScreen ? 20 : 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Track your spending",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: isSmallScreen ? 11 : 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff6F41F2).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.pie_chart_outline,
                                        color: const Color(0xff6F41F2),
                                        size: isSmallScreen ? 18 : 22,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const Spacer(),
                                
                                // Statistics Cards - Responsive Grid
                                Row(
                                  children: [
                                    // Today Card
                                    Expanded(
                                      child: _buildStatisticsCard(
                                        context,
                                        title: "Today",
                                        amount: formatRupiah(WalletService.getTotalExpenseForPeriod(
                                          const Duration(days: 1),
                                        )),
                                        icon: Icons.today,
                                        color: const Color(0xff6F41F2),
                                        isVerySmall: isSmallScreen,
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    // Weekly Card
                                    Expanded(
                                      child: _buildStatisticsCard(
                                        context,
                                        title: "Week",
                                        amount: formatRupiah(WalletService.getTotalExpenseForPeriod(
                                          const Duration(days: 7),
                                        )),
                                        icon: Icons.weekend,
                                        color: const Color(0xff6F41F2),
                                        isVerySmall: isSmallScreen,
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    // Monthly Card
                                    Expanded(
                                      child: _buildStatisticsCard(
                                        context,
                                        title: "Month",
                                        amount: formatRupiah(WalletService.getTotalExpenseForPeriod(
                                          const Duration(days: 30),
                                        )),
                                        icon: Icons.calendar_month,
                                        color: const Color(0xff6F41F2),
                                        isVerySmall: isSmallScreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                    
                    // Expenses List Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isSmallScreen ? 12 : 16,
                          20,
                          isSmallScreen ? 12 : 16,
                          8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Expenses",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff6F41F2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box<Expenses>('expensesBox').listenable(),
                                builder: (context, Box<Expenses> box, _) {
                                  return Text(
                                    "${box.length} items",
                                    style: TextStyle(
                                      color: const Color(0xff6F41F2),
                                      fontSize: isSmallScreen ? 10 : 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Expenses List
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Expenses>('expensesBox').listenable(),
                      builder: (context, Box<Expenses> box, _) {
                        if (box.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff6F41F2).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.receipt_long_outlined,
                                        color: const Color(0xff6F41F2),
                                        size: isLandscape ? 36 : 44,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No expenses yet",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: isLandscape ? 16 : 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLandscape ? 20 : 40,
                                      ),
                                      child: Text(
                                        "Add your first expense to get started",
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

                        final expenses = box.values.toList().reversed.toList();
                        
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final expense = expenses[index];
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isSmallScreen ? 12 : 16,
                                  index == 0 ? 4 : 8,
                                  isSmallScreen ? 12 : 16,
                                  index == expenses.length - 1 ? 100 : 0,
                                ),
                                child: _buildExpenseCard(
                                  context,
                                  expense,
                                  isSmallScreen: isSmallScreen,
                                  isLandscape: isLandscape,
                                ),
                              );
                            },
                            childCount: expenses.length,
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
                    // Scan Receipt Button dengan animasi slide
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
                          icon: Icons.camera_alt_rounded,
                          label: "Scan Receipt",
                          color: const Color(0xff6F41F2),
                          onTap: _openCamera,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ),
                    
                    // Add Expense Button dengan animasi slide
                    AnimatedBuilder(
                      animation: _fabAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -120 * (1 - _fabAnimation.value)),
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
                          label: "Add Expense",
                          color: const Color(0xff6F41F2),
                          onTap: _showAddExpenseDialog,
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

  // Widget untuk Statistics Card yang responsif
  Widget _buildStatisticsCard(BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isVerySmall,
  }) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isVerySmall ? 4 : 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isVerySmall ? 12 : 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title.contains("Week") ? "7d" : 
                  title.contains("Month") ? "30d" : "1d",
                  style: TextStyle(
                    color: color,
                    fontSize: isVerySmall ? 7 : 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: isVerySmall ? 11 : 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: isVerySmall ? 8 : 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Widget _buildExpenseCard(BuildContext context, Expenses expense, {
    required bool isLandscape,
    required bool isSmallScreen,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditExpenses(expenseId: expense.id);
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.red,
                  size: isSmallScreen ? 14 : 16,
                ),
              ),
              
              SizedBox(width: isSmallScreen ? 10 : 12),
              
              // Expense Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expense.description,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM - HH:mm').format(expense.date_added),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isSmallScreen ? 9 : 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Amount
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatRupiah(expense.amount),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Expense",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isSmallScreen ? 8 : 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}