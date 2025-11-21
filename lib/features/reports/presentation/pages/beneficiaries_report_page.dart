import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_chart_section.dart';
import '../../domain/models/report_data.dart';

/// 📋 Beneficiaries Report Page
class BeneficiariesReportPage extends ConsumerStatefulWidget {
  const BeneficiariesReportPage({super.key});

  @override
  ConsumerState<BeneficiariesReportPage> createState() =>
      _BeneficiariesReportPageState();
}

class _BeneficiariesReportPageState
    extends ConsumerState<BeneficiariesReportPage> {
  ReportFilters _filters = ReportFilters.initial();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المستفيدين'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          ReportExportButton(
            onExportPdf: _exportPdf,
            onExportExcel: _exportExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تصفية التقرير',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildFiltersRow(),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('تطبيق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        _buildSummaryCards(),
                        const SizedBox(height: 24),

                        // Charts Section
                        const ReportChartSection(),
                        const SizedBox(height: 24),

                        // Data Table
                        _buildDataTable(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Date Range
        FilterChip(
          label: Text('من: ${_filters.startDate ?? "غير محدد"}'),
          onSelected: (_) => _selectStartDate(),
          avatar: const Icon(Icons.calendar_today, size: 16),
        ),
        FilterChip(
          label: Text('إلى: ${_filters.endDate ?? "غير محدد"}'),
          onSelected: (_) => _selectEndDate(),
          avatar: const Icon(Icons.calendar_today, size: 16),
        ),

        // Governorate
        DropdownButton<String>(
          value: _filters.governorate,
          hint: const Text('المحافظة'),
          items: [
            'الكل',
            'دمشق',
            'حلب',
            'حمص',
            'اللاذقية',
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(governorate: value);
            });
          },
        ),

        // Status
        DropdownButton<String>(
          value: _filters.status,
          hint: const Text('الحالة'),
          items: [
            'الكل',
            'نشط',
            'معلق',
            'محذوف',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(status: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'إجمالي المستفيدين',
            value: '1,234',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'نشط',
            value: '1,100',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'معلق',
            value: '134',
            icon: Icons.pause_circle,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'البيانات التفصيلية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('الاسم')),
                  DataColumn(label: Text('الرقم الوطني')),
                  DataColumn(label: Text('المحافظة')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('تاريخ التسجيل')),
                ],
                rows: _buildTableRows(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    // Mock data - replace with actual filtered data
    return List.generate(
      10,
      (index) => DataRow(
        cells: [
          DataCell(Text('محمد أحمد ${index + 1}')),
          DataCell(Text('123456789${index}')),
          const DataCell(Text('دمشق')),
          DataCell(_buildStatusChip('نشط')),
          const DataCell(Text('2024-01-15')),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'نشط':
        color = Colors.green;
        break;
      case 'معلق':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _filters = _filters.copyWith(
          startDate: '${date.year}-${date.month}-${date.day}',
        );
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _filters = _filters.copyWith(
          endDate: '${date.year}-${date.month}-${date.day}',
        );
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تطبيق التصفية')));
      }
    });
  }

  Future<void> _exportPdf() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري تصدير PDF...')));
    // TODO: Implement PDF export using pdf package
  }

  Future<void> _exportExcel() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري تصدير Excel...')));
    // TODO: Implement Excel export using excel package
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
