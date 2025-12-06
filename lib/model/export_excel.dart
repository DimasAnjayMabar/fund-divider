import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // hanya untuk web

class ExcelExport {
  static Future<bool> exportExpensesToExcel(List<Expenses> expenses) async {
    try {
      if (expenses.isEmpty) {
        throw Exception('No expenses to export');
      }
      
      // Create Excel workbook
      final excel = Excel.createExcel();
      
      // Hapus sheet default yang kosong (Sheet1)
      // Cek apakah sheet 'Sheet1' ada dan kosong, lalu hapus
      final defaultSheet = excel['Sheet1'];
      if (defaultSheet != null) {
        // Hapus sheet default yang kosong
        excel.delete('Sheet1');
      }
      
      // Create sheet dengan nama 'Expenses'
      final sheet = excel['Expenses'];
      
      // Jika tidak ada sheet 'Expenses', buat baru
      if (sheet == null) {
        throw Exception('Failed to create Expenses sheet');
      }
      
      // Add headers
      final headers = ['ID', 'Description', 'Amount', 'Date Added'];
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            fontColorHex: "#FFFFFF",
            backgroundColorHex: "#6F41F2",
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );
      }
      
      // Format currency
      final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
      
      // Add data rows
      for (int i = 0; i < expenses.length; i++) {
        final expense = expenses[i];
        
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value = expense.id.toString();
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value = expense.description;
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value = currencyFormat.format(expense.amount);
        sheet.cell(CellIndex.indexByString('D${i + 2}')).value = dateFormat.format(expense.date_added);
        
        // Style for amount column
        sheet.cell(CellIndex.indexByString('C${i + 2}'))
          ..cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Right,
          );
      }
      
      // Auto resize columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColAutoFit(i);
      }
      
      // Set sheet sebagai aktif (agar langsung menampilkan sheet Expenses)
      excel.setDefaultSheet('Expenses');
      
      // Save Excel file
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final fileName = 'expenses_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        
        if (kIsWeb) {
          // Untuk Web platform
          return _saveForWeb(fileBytes, fileName);
        } else {
          // Untuk Mobile & Desktop platforms
          return await _saveForMobileDesktop(fileBytes, fileName);
        }
      }
      
      return false;
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }

  // Alternatif 2: Gunakan cara yang lebih aman untuk menghindari sheet kosong
  static Future<bool> exportExpensesToExcelV2(List<Expenses> expenses) async {
    try {
      if (expenses.isEmpty) {
        throw Exception('No expenses to export');
      }
      
      // Create Excel workbook tanpa sheet default
      final excel = Excel.createExcel();
      
      // Langsung buat sheet dengan nama 'Expenses'
      final sheet = excel['Expenses'];
      
      // Jika sheet 'Expenses' tidak ada, buat manual
      if (sheet == null) {
        // Alternatif: Hapus semua sheet yang ada, lalu buat baru
        final sheetNames = excel.getDefaultSheet() != null ? [excel.getDefaultSheet()!] : [];
        for (final name in sheetNames) {
          excel.delete(name);
        }
        
        // Buat sheet baru
        excel.rename(excel.getDefaultSheet() ?? 'Sheet1', 'Expenses');
        final newSheet = excel['Expenses'];
        
        if (newSheet == null) {
          throw Exception('Failed to create Expenses sheet');
        }
        
        return await _fillSheetAndSave(excel, newSheet, expenses);
      }
      
      return await _fillSheetAndSave(excel, sheet, expenses);
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }

  static Future<bool> _fillSheetAndSave(Excel excel, Sheet sheet, List<Expenses> expenses) async {
    // Add headers
    final headers = ['ID', 'Description', 'Amount', 'Date Added'];
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'))
        ..value = headers[i]
        ..cellStyle = CellStyle(
          bold: true,
          fontColorHex: "#FFFFFF",
          backgroundColorHex: "#6F41F2",
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
    }
    
    // Format currency
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
    
    // Add data rows
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      
      sheet.cell(CellIndex.indexByString('A${i + 2}')).value = expense.id.toString();
      sheet.cell(CellIndex.indexByString('B${i + 2}')).value = expense.description;
      sheet.cell(CellIndex.indexByString('C${i + 2}')).value = currencyFormat.format(expense.amount);
      sheet.cell(CellIndex.indexByString('D${i + 2}')).value = dateFormat.format(expense.date_added);
      
      // Style for amount column
      sheet.cell(CellIndex.indexByString('C${i + 2}'))
        ..cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
        );
    }
    
    // Auto resize columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColAutoFit(i);
    }
    
    // Set sheet sebagai aktif
    excel.setDefaultSheet('Expenses');
    
    // Save Excel file
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final fileName = 'expenses_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
      if (kIsWeb) {
        return _saveForWeb(fileBytes, fileName);
      } else {
        return await _saveForMobileDesktop(fileBytes, fileName);
      }
    }
    
    return false;
  }

  // Alternatif 3: Gunakan pendekatan yang lebih clean
  static Future<bool> exportExpensesToExcelClean(List<Expenses> expenses) async {
    try {
      if (expenses.isEmpty) {
        throw Exception('No expenses to export');
      }
      
      // Buat workbook baru
      var excel = Excel.createExcel();
      
      // Dapatkan sheet default dan rename
      final defaultSheetName = excel.getDefaultSheet();
      if (defaultSheetName != null) {
        // Rename sheet default menjadi 'Expenses'
        excel.rename(defaultSheetName, 'Expenses');
      } else {
        // Jika tidak ada sheet default, buat baru
        excel = Excel.createExcel();
        excel.rename('Sheet1', 'Expenses');
      }
      
      // Dapatkan sheet Expenses
      final sheet = excel['Expenses'];
      if (sheet == null) {
        throw Exception('Failed to create Expenses sheet');
      }
      
      // Add headers
      final headers = ['ID', 'Description', 'Amount', 'Date Added'];
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            fontColorHex: "#FFFFFF",
            backgroundColorHex: "#6F41F2",
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );
      }
      
      // Format currency
      final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
      
      // Add data rows
      for (int i = 0; i < expenses.length; i++) {
        final expense = expenses[i];
        
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value = expense.id.toString();
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value = expense.description;
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value = currencyFormat.format(expense.amount);
        sheet.cell(CellIndex.indexByString('D${i + 2}')).value = dateFormat.format(expense.date_added);
        
        // Style for amount column
        sheet.cell(CellIndex.indexByString('C${i + 2}'))
          ..cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Right,
          );
      }
      
      // Auto resize columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColAutoFit(i);
      }
      
      // Hapus sheet lain selain 'Expenses' jika ada
      final allSheets = excel.tables.keys.toList();
      for (final sheetName in allSheets) {
        if (sheetName != 'Expenses') {
          excel.delete(sheetName);
        }
      }
      
      // Save Excel file
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final fileName = 'expenses_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        
        if (kIsWeb) {
          return _saveForWeb(fileBytes, fileName);
        } else {
          return await _saveForMobileDesktop(fileBytes, fileName);
        }
      }
      
      return false;
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }

  static Future<bool> _saveForMobileDesktop(List<int> bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
      return true;
    } catch (e) {
      print('Save for mobile/desktop error: $e');
      rethrow;
    }
  }

  static bool _saveForWeb(List<int> bytes, String fileName) {
    try {
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      print('Save for web error: $e');
      rethrow;
    }
  }
}