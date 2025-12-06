import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fund_divider/model/export_excel.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/error/error.dart';
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
  StreamSubscription<int>? _expenseCountSubscription;
  StreamSubscription<Map<String, double>>? _summarySubscription;
  int _totalExpensesCount = 0;
  
  // Pagination variables
  int _currentPage = 1;
  bool _hasMoreItems = true;
  bool _isLoading = false;
  final int _itemsPerPage = 20;
  final List<Expenses> _expenses = [];
  final ScrollController _scrollController = ScrollController();
  
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

    // Inisialisasi count pertama kali
    _totalExpensesCount = WalletService.getExpensesCount();
    
    // Setup stream untuk count dan summary (ringan)
    _setupStreams();
    
    // Load initial expenses
    _loadMoreItems();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _expenseCountSubscription?.cancel();
    _summarySubscription?.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        _hasMoreItems &&
        !_isLoading) {
      _loadMoreItems();
    }
  }

  void _setupStreams() {
    // Stream untuk total count (O(1))
    _expenseCountSubscription = WalletService.watchExpenseCount()
      .listen((count) {
        if (mounted) {
          setState(() {
            _totalExpensesCount = count;
          });
        }
      });
    
    // Stream untuk summary (ringan, sudah dicache)
    _summarySubscription = WalletService.watchExpenseSummary()
      .listen((summary) {
        if (mounted) {
          setState(() {
            // Update UI jika diperlukan
          });
        }
      });
  }
  
  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use paginated API
      final newItems = WalletService.getExpensesPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
        sortByNewest: true,
      );
      
      if (newItems.isEmpty) {
        setState(() {
          _hasMoreItems = false;
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _expenses.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
      
      // If we got less items than requested, there are no more items
      if (newItems.length < _itemsPerPage) {
        setState(() {
          _hasMoreItems = false;
        });
      }
    } catch (e) {
      print('Error loading expenses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _refreshExpenses() {
    setState(() {
      _currentPage = 1;
      _expenses.clear();
      _hasMoreItems = true;
      _isLoading = false;
      // Update count juga
      _totalExpensesCount = WalletService.getExpensesCount();
    });
    _loadMoreItems();
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
  // Future<void> _openCamera() async {
  //   try {
  //     final XFile? image = await _picker.pickImage(
  //       source: ImageSource.camera,
  //       imageQuality: 85,
  //       preferredCameraDevice: CameraDevice.rear,
  //     );
      
  //     if (image != null) {
  //       // TODO: Implement receipt scanning logic here
  //       print('Image captured: ${image.path}');
        
  //       // For now, show a snackbar
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Receipt captured: ${image.path.split('/').last}'),
  //           backgroundColor: const Color(0xff6F41F2),
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
        
  //       // Close the expanded FAB
  //       _toggleFab();
  //     }
  //   } catch (e) {
  //     print('Error opening camera: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Failed to open camera'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _openCamera() async {
    // Tampilkan modal error
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorPopup(
          errorMessage: "Sorry, we still build this feature, please stay tune",
        );
      },
    );
    
    // Close the expanded FAB
    _toggleFab();
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
      // Refresh the list when a new expense is added
      _refreshExpenses();
    });
  }

  void _exportToExcel() async {
    // Get ALL expenses for export (not paginated)
    final allExpenses = WalletService.getExpense();
    
    if (allExpenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No expenses to export'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationPopup(
          title: 'Export Expenses',
          errorMessage: 'Are you sure you want to export ${allExpenses.length} expense items to Excel?',
          onConfirm: () async {
            try {
              final result = await ExcelExport.exportExpensesToExcel(allExpenses);
              
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Expenses exported successfully'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to export expenses'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              print('Error exporting to Excel: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          primaryColor: const Color(0xff6F41F2),
        );
      },
    ).then((_) {
      // Close the expanded FAB after showing dialog
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
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Rounded AppBar dengan statistik
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      expandedHeight: isLandscape ? 240 : 220,
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
                                            const SizedBox(height: 2),
                                            Text(
                                              "Information - Your expenses list is auto reset within 90 days, make sure to export them",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: isSmallScreen ? 11 : 13,
                                              ),
                                              maxLines: 2,
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
                                  StreamBuilder<Map<String, double>>(
                                    stream: WalletService.watchExpenseSummary(),
                                    initialData: WalletService.getExpenseSummary(),
                                    builder: (context, snapshot) {
                                      final summary = snapshot.data ?? {
                                        'daily': 0.0,
                                        'weekly': 0.0,
                                        'monthly': 0.0,
                                      };
                                      
                                      return Row(
                                        children: [
                                          // Today Card
                                          Expanded(
                                            child: _buildStatisticsCard(
                                              context,
                                              title: "Today",
                                              amount: formatRupiah(summary['daily'] ?? 0),
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
                                              amount: formatRupiah(summary['weekly'] ?? 0),
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
                                              amount: formatRupiah(summary['monthly'] ?? 0),
                                              icon: Icons.calendar_month,
                                              color: const Color(0xff6F41F2),
                                              isVerySmall: isSmallScreen,
                                            ),
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
                              "All Expenses",
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
                              child: Text(
                                "$_totalExpensesCount items",  // <-- PAKAI VARIABLE LOKAL
                                style: TextStyle(
                                  color: const Color(0xff6F41F2),
                                  fontSize: isSmallScreen ? 10 : 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Expenses List with pagination
                    if (_expenses.isEmpty && !_isLoading)
                      SliverFillRemaining(
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
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Show loading indicator at the end
                            if (index == _expenses.length) {
                              return _buildLoadingIndicator();
                            }
                            
                            final expense = _expenses[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                isSmallScreen ? 12 : 16,
                                index == 0 ? 4 : 8,
                                isSmallScreen ? 12 : 16,
                                index == _expenses.length - 1 && !_hasMoreItems ? 100 : 0,
                              ),
                              child: _buildExpenseCard(
                                context,
                                expense,
                                isSmallScreen: isSmallScreen,
                                isLandscape: isLandscape,
                              ),
                            );
                          },
                          childCount: _expenses.length + (_hasMoreItems ? 1 : 0),
                        ),
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

                    // Export to excel
                    AnimatedBuilder(
                      animation: _fabAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -180 * (1 - _fabAnimation.value)),
                          child: Opacity(
                            opacity: _fabAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFabOption(
                          icon: Icons.download_rounded,
                          label: "Export to Excel",
                          color: const Color(0xff6F41F2),
                          onTap: _exportToExcel,
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Color(0xff6F41F2),
              )
            : _hasMoreItems
                ? const SizedBox() // Will trigger when scrolled
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "No more expenses",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
    return Dismissible(
      key: Key(expense.id.toString()),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete expense
          final bool? result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationPopup(
                title: "Delete Expense",
                errorMessage: "Are you sure you want to delete '${expense.description}' for ${formatRupiah(expense.amount)}?",
                onConfirm: () async {
                  await WalletService.deleteExpense(expense);
                  _refreshExpenses();
                },
                primaryColor: Colors.red,
              );
            },
          );
          return result ?? false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit expense
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditExpenses(expenseId: expense.id);
            },
          ).then((_) {
            _refreshExpenses();
          });
          return false; // Tidak dismiss card
        }
        return false;
      },
      
      // Background untuk swipe KANAN (Edit) - warna biru
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
    
      // Background untuk swipe ke KIRI (Delete) - warna merah
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Delete",
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
                Icons.delete,
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
            // _showEditExpenseDialog(expense);
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
      ),
    );
  }
}