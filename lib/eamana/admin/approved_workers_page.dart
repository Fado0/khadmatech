/// ------------------------------
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاطمة اليامي:
/// - إضافة الخلفية الموحدة لموظف الأمانة (EmanaBackground).
/// - تعديل التصميم ليتماشى مع هوية النظام.
/// - تفعيل الترجمة باستخدام easy_localization وتحويل اتجاه النص تلقائيًا.
/// - إضافة فلتر نوع الخدمة لعرض العمال المعتمدين حسب النوع.
///
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات العمال المعتمدين وتصفية البيانات حسب نوع الخدمة.
/// ------------------------------
library;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widget/emana_background.dart';

class ApprovedWorkersPage extends StatefulWidget {
  const ApprovedWorkersPage({super.key});

  @override
  _ApprovedWorkersPageState createState() => _ApprovedWorkersPageState();
}

class _ApprovedWorkersPageState extends State<ApprovedWorkersPage> {
  String? _selectedType;
  List<String> _workerTypes = [];
  final int _selectedIndex = 1;
  Future<void> _loadWorkerTypes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Workers')
        .get();

    final workerTypes = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] != null) {
        workerTypes.add(data['type']);
      }
    }

    setState(() {
      _workerTypes = workerTypes.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadWorkerTypes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        const EmanaBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : const Color(0xFF003049),
            ),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                tr('admin_nav.approved_workers'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF003049),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: tr('admin_workers.select_type'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value: _selectedType,
                  isExpanded: true,
                  items: _workerTypes.isNotEmpty
                      ? _workerTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList()
                      : [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(tr('admin_workers.no_types')),
                          ),
                        ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Workers')
                      .where('approved', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (_selectedType == null) {
                      return Center(
                        child: Text(tr('admin_workers.select_type_first')),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(tr('admin_workers.error')));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['type'] == _selectedType;
                    }).toList();

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(tr('admin_workers.no_workers')),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Directionality(
                            textDirection: Directionality.of(context),
                            child: ListTile(
                              title: Text(
                                data['name'] ?? tr('admin_workers.no_name'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tr('admin_workers.service')}: ${data['type'] ?? '—'}',
                                  ),
                                  Text(
                                    '${tr('admin_workers.charge')}: ${data['charge_per_hour'] ?? '—'} ${tr('admin_workers.per_hour')}',
                                  ),
                                  Text(
                                    '${tr('admin_workers.iqama')}: ${data['iqama'] ?? '—'}',
                                  ),
                                  Text(
                                    '${tr('admin_workers.phone')}: ${data['phone'] ?? '—'}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
