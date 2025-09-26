// ignore_for_file: deprecated_member_use, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_students.dart';
import 'providers.dart';
import '../auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mock_api.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Class ${student.class_}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit Student',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ID: ${student.studentId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (student.address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        student.address,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // end of ParentsManagementSection state
}

// Global helper to show parent details dialog from anywhere in this file
void _showParentDetailsGlobal(BuildContext context, AdminParent parent) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(parent.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Email:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(parent.email.isEmpty ? 'Not provided' : parent.email)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(parent.phone.isEmpty ? 'Not provided' : parent.phone)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Children:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SizedBox(width: 400, child: ParentChildrenChips(parentId: parent.id)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    ),
  );
}

class ParentChildrenChips extends ConsumerWidget {
  final String parentId;
  const ParentChildrenChips({super.key, required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);
    final stream = firestore
        .collection('students')
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 20, child: LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Failed to load children');
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text('No linked students', style: Theme.of(context).textTheme.bodySmall);
        }
        final names = docs
            .map((d) => (d.data()['name'] ?? '') as String)
            .where((n) => n.isNotEmpty)
            .toList();
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: names.map((n) => Chip(label: Text(n))).toList(),
        );
      },
    );
  }
}

class StudentsManagementSection extends ConsumerStatefulWidget {
  const StudentsManagementSection({super.key});

  @override
  ConsumerState<StudentsManagementSection> createState() => _StudentsManagementSectionState();
}

class _StudentsManagementSectionState extends ConsumerState<StudentsManagementSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final randomStudents = ref.watch(randomStudentsProvider);
    final studentCount = ref.watch(studentCountProvider);

    return Card(
      color: _expanded ? Theme.of(context).colorScheme.primary.withOpacity(0.04) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _expanded
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ExpansionTile(
        onExpansionChanged: (v) => setState(() => _expanded = v),
        leading: const Icon(Icons.school),
        title: Row(
          children: [
            const Text('Students'),
            const SizedBox(width: 12),
            studentCount.when(
              data: (count) => Chip(
                label: Text('$count Total'),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              loading: () => const Chip(label: Text('Loading...')),
              error: (_, __) => const Chip(label: Text('Error')),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(context, ref),
              icon: const Icon(Icons.person_add, size: 14),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          randomStudents.when(
            data: (students) {
              if (students.isEmpty) {
                return _buildNoStudentsView(context, ref);
              }
              
              return Column(
                children: [
                  // Display random students in a vertical list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: StudentCard(
                          student: student,
                          onTap: () => _showStudentActions(context, ref, student),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAllStudentsDialog(context, ref),
                          icon: const Icon(Icons.view_list),
                          label: const Text('View More Students'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddStudentDialog(context, ref),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Student'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 8),
                  Text('Error loading students: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(randomStudentsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStudentsView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'There is no any student registered',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by registering your first student',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStudentDialog(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('Register Student'),
          ),
        ],
      ),
    );
  }

  
  
  void _showAllStudentsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'All Students',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAddStudentDialog(context, ref);
                    },
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _AllStudentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();
    final classController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Student'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: 'Class *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter class';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final service = ref.read(firestoreStudentsServiceProvider);
                  final student = Student(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    studentId: studentIdController.text.trim(),
                    name: nameController.text.trim(),
                    class_: classController.text.trim(),
                    parentId: '', // You might want to implement parent selection
                    address: addressController.text.trim(),
                    createdAt: DateTime.now(),
                    isActive: true,
                  );

                  await service.addStudent(student);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ref.refresh(randomStudentsProvider);
                    ref.refresh(studentCountProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student registered successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

void _showStudentDetailsDialog(BuildContext context, Student student) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(student.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Student ID:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(student.studentId.isEmpty ? 'Not provided' : student.studentId)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Class:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(student.class_.isEmpty ? 'Not provided' : student.class_)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Address:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(student.address.isEmpty ? 'Not provided' : student.address)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80, child: Text('Joined:', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('${student.createdAt.day}/${student.createdAt.month}/${student.createdAt.year}')),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// Simple top-level detail row builder for use in global dialogs
Widget _globalDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            'Label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value.isEmpty ? 'Not provided' : value),
        ),
      ],
    ),
  );
}

Future<void> _showStudentActions(BuildContext context, WidgetRef ref, Student student) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showStudentDetailsDialog(context, student);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showEditStudentDialog(context, ref, student);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Remove'),
            onTap: () async {
              Navigator.of(ctx).pop();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: const Text('Remove student'),
                  content: Text("Are you sure you want to remove ${student.name}?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Remove')),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  final service = ref.read(firestoreStudentsServiceProvider);
                  await service.deleteStudent(student.id);
                  if (context.mounted) {
                    ref.refresh(randomStudentsProvider);
                    ref.refresh(studentCountProvider);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student removed')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showEditStudentDialog(BuildContext context, WidgetRef ref, Student student) {
  final nameController = TextEditingController(text: student.name);
  final studentIdController = TextEditingController(text: student.studentId);
  final classController = TextEditingController(text: student.class_);
  final addressController = TextEditingController(text: student.address);
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Student'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student Name *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter student name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter student ID' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter class' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            try {
              final service = ref.read(firestoreStudentsServiceProvider);
              final updated = Student(
                id: student.id,
                studentId: studentIdController.text.trim(),
                name: nameController.text.trim(),
                class_: classController.text.trim(),
                parentId: student.parentId,
                address: addressController.text.trim(),
                createdAt: student.createdAt,
                isActive: student.isActive,
              );
              await service.updateStudent(updated);
              if (context.mounted) {
                Navigator.of(context).pop();
                ref.refresh(randomStudentsProvider);
                ref.refresh(studentCountProvider);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _AllStudentsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStudents = ref.watch(allStudentsProvider((limit: 20, startAfter: null)));

    return allStudents.when(
      data: (students) {
        if (students.isEmpty) {
          return const Center(child: Text('No students found'));
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(student.name),
                subtitle: Text('ID: ${student.studentId} • Class ${student.class_}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showStudentActions(context, ref, student),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }

  // moved student details dialog to top-level for reuse

  // use top-level studentDetailRow

  // use top-level studentFormatDate
}

class ParentCard extends StatelessWidget {
  final AdminParent parent;
  final VoidCallback? onTap;

  const ParentCard({
    super.key,
    required this.parent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      parent.name.isNotEmpty ? parent.name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parent.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          parent.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (parent.phone.isNotEmpty)
                          Text(
                            parent.phone,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParentsManagementSection extends ConsumerStatefulWidget {
  const ParentsManagementSection({super.key});

  @override
  ConsumerState<ParentsManagementSection> createState() => _ParentsManagementSectionState();
}

class _ParentsManagementSectionState extends ConsumerState<ParentsManagementSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final firestore = ref.watch(firestoreProvider);
    final parentsStream = firestore
        .collection('parents')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: parentsStream,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final docs = snapshot.data?.docs ?? [];

        return Card(
          color: _expanded ? Theme.of(context).colorScheme.primary.withOpacity(0.04) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _expanded
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: ExpansionTile(
            onExpansionChanged: (v) => setState(() => _expanded = v),
            leading: const Icon(Icons.family_restroom),
            title: Row(
              children: [
                const Text('Parents'),
                const SizedBox(width: 12),
                if (isLoading)
                  const Chip(label: Text('Loading...'))
                else if (hasError)
                  const Chip(label: Text('Error'))
                else
                  Chip(
                    label: Text('${docs.length} Loaded'),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddParentDialog(context, ref),
                  icon: const Icon(Icons.person_add, size: 14),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                const Center(child: Text('Failed to load parents'))
              else if (docs.isEmpty)
                _buildNoParentsView(context, ref)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final parent = AdminParent(
                      id: docs[index].id,
                      name: (d['name'] ?? '') as String,
                      email: (d['email'] ?? '') as String,
                      phone: (d['phone'] ?? '') as String,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParentCard(
                            parent: parent,
                            onTap: () => _showParentActions(context, ref, parent),
                          ),
                          const SizedBox(height: 6),
                          ParentChildrenChips(parentId: parent.id),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoParentsView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No parents registered',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by registering your first parent',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddParentDialog(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('Register Parent'),
          ),
        ],
      ),
    );
  }

  void _showParentDetails(BuildContext context, AdminParent parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', parent.email),
            _buildDetailRow('Phone', parent.phone),
            const SizedBox(height: 8),
            const Text('Children:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              width: 400,
              child: ParentChildrenChips(parentId: parent.id),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  void _showAddParentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedStudentId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Parent'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter parent name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final studentsAsync = ref.watch(randomStudentsProvider);
                    return studentsAsync.when(
                      data: (students) {
                        final items = [
                          const DropdownMenuItem<String>(value: null, child: Text('Select child (optional)')),
                          ...students.map((s) => DropdownMenuItem<String>(
                                value: s.id,
                                child: Text('${s.name} • Class ${s.class_}'),
                              )),
                        ];
                        return DropdownButtonFormField<String?>(
                          value: selectedStudentId,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Child (Student)'),
                          items: items,
                          onChanged: (v) {
                            selectedStudentId = v;
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        height: 48,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text('Failed to load students: $e'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final firestore = ref.read(firestoreProvider);
                final docRef = FirebaseFirestore.instance.collection('parents').doc();
                final data = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  if (selectedStudentId != null) 'childId': selectedStudentId,
                  'defaultPassword': '123456',
                  'createdAt': FieldValue.serverTimestamp(),
                };
                await docRef.set(data);
                if (selectedStudentId != null) {
                  await firestore.collection('students').doc(selectedStudentId).update({'parentId': docRef.id});
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parent registered')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

Future<void> _showParentActions(BuildContext context, WidgetRef ref, AdminParent parent) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showParentDetailsGlobal(context, parent);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showEditParentDialog(context, ref, parent);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Remove'),
            onTap: () async {
              Navigator.of(ctx).pop();
              final ok = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: const Text('Remove parent'),
                  content: Text("Are you sure you want to remove ${parent.name}?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Remove')),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  final firestore = ref.read(firestoreProvider);
                  await firestore.collection('parents').doc(parent.id).delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parent removed')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showEditParentDialog(BuildContext context, WidgetRef ref, AdminParent parent) {
  final nameController = TextEditingController(text: parent.name);
  final emailController = TextEditingController(text: parent.email);
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Parent'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Parent Name *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            try {
              final firestore = ref.read(firestoreProvider);
              final map = {
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                if (phoneController.text.trim().isNotEmpty) 'phone': phoneController.text.trim(),
              };
              await firestore.collection('parents').doc(parent.id).update(map);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parent updated')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class DriverCard extends StatelessWidget {
  final AdminDriver driver;
  final VoidCallback? onTap;
  final String? displayId; // prefer showing human driverId

  const DriverCard({
    super.key,
    required this.driver,
    this.onTap,
    this.displayId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          driver.phone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'ID: ${displayId ?? driver.id}',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriversManagementSection extends ConsumerStatefulWidget {
  const DriversManagementSection({super.key});

  @override
  ConsumerState<DriversManagementSection> createState() => _DriversManagementSectionState();
}

class _DriversManagementSectionState extends ConsumerState<DriversManagementSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final firestore = ref.watch(firestoreProvider);
    final driversStream = firestore
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final docs = snapshot.data?.docs ?? [];

        return Card(
          color: _expanded ? Theme.of(context).colorScheme.primary.withOpacity(0.04) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _expanded
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: ExpansionTile(
            onExpansionChanged: (v) => setState(() => _expanded = v),
            leading: const Icon(Icons.drive_eta),
            title: Row(
              children: [
                const Text('Drivers'),
                const SizedBox(width: 12),
                if (isLoading)
                  const Chip(label: Text('Loading...'))
                else if (hasError)
                  const Chip(label: Text('Error'))
                else
                  Chip(
                    label: Text('${docs.length} Loaded'),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddDriverDialog(context, ref),
                  icon: const Icon(Icons.person_add, size: 14),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                const Center(child: Text('Failed to load drivers'))
              else if (docs.isEmpty)
                _buildNoDriversView(context, ref)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final driver = AdminDriver(
                      id: docs[index].id,
                      name: (d['name'] ?? '') as String,
                      phone: (d['phone'] ?? '') as String,
                    );
                    final driverId = (d['driverId'] ?? '') as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DriverCard(
                        driver: driver,
                        displayId: driverId.isNotEmpty ? driverId : null,
                        onTap: () => _showDriverActions(context, ref, driver, driverId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAllDriversDialog(context, ref),
                        icon: const Icon(Icons.view_list),
                        label: const Text('View More Drivers'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddDriverDialog(context, ref),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Driver'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoDriversView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.drive_eta_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No drivers registered',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by registering your first driver',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDriverDialog(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('Register Driver'),
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(BuildContext context, AdminDriver driver, String driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Driver ID', driverId.isNotEmpty ? driverId : driver.id),
            _buildDetailRow('Phone', driver.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDriverActions(BuildContext context, WidgetRef ref, AdminDriver driver, String driverId) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showDriverDetails(context, driver, driverId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showEditDriverDialog(context, ref, driver);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dctx) => AlertDialog(
                    title: const Text('Remove driver'),
                    content: Text("Are you sure you want to remove ${driver.name}?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Remove')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    final firestore = ref.read(firestoreProvider);
                    await firestore.collection('drivers').doc(driver.id).delete();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver removed')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDriverDialog(BuildContext context, WidgetRef ref, AdminDriver driver) {
    final nameController = TextEditingController(text: driver.name);
    final phoneController = TextEditingController(text: driver.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Driver'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Driver Name *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter driver name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter phone number' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final firestore = ref.read(firestoreProvider);
                await firestore.collection('drivers').doc(driver.id).update({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver updated')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final driverIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Driver'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: driverIdController,
                  decoration: const InputDecoration(
                    labelText: 'Driver ID *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  final firestore = ref.read(firestoreProvider);
                  firestore.collection('drivers').add({
                    'driverId': driverIdController.text.trim(),
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  }).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Driver registered successfully!')),
                    );
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

void _showAllDriversDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'All Drivers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reopen add dialog
                    // Find a ref via StatefulBuilder? We have ref in outer scope; pass it using closure
                    _reopenAddDriver(context, ref);
                  },
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Add Driver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(child: _AllDriversList()),
          ],
        ),
      ),
    ),
  );
}

void _reopenAddDriver(BuildContext context, WidgetRef ref) {
  _showAddDriverDialogGlobal(context, ref);
}

class _AllDriversList extends ConsumerWidget {
  const _AllDriversList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);
    final stream = firestore
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No drivers found'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data();
            final driver = AdminDriver(
              id: docs[index].id,
              name: (d['name'] ?? '') as String,
              phone: (d['phone'] ?? '') as String,
            );
            final driverId = (d['driverId'] ?? '') as String;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(driver.name),
                subtitle: Text('ID: ${driverId.isNotEmpty ? driverId : driver.id} • ${driver.phone}'),
                trailing: const Icon(Icons.more_horiz),
                onTap: () => _showDriverActionsGlobal(context, ref, driver, driverId),
              ),
            );
          },
        );
      },
    );
  }
}

// Global driver helpers so they can be invoked from anywhere in this file
void _showAddDriverDialogGlobal(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final driverIdController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Register New Driver'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: driverIdController,
                decoration: const InputDecoration(labelText: 'Driver ID *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter driver ID' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Driver Name *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter driver name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter phone number' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            try {
              final firestore = ref.read(firestoreProvider);
              firestore.collection('drivers').add({
                'driverId': driverIdController.text.trim(),
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              }).then((_) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Driver registered successfully!')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: const Text('Register'),
        ),
      ],
    ),
  );
}

Future<void> _showDriverActionsGlobal(BuildContext context, WidgetRef ref, AdminDriver driver, String driverId) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showDriverDetailsGlobal(context, driver, driverId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showEditDriverDialogGlobal(context, ref, driver);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Remove'),
            onTap: () async {
              Navigator.of(ctx).pop();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: const Text('Remove driver'),
                  content: Text("Are you sure you want to remove ${driver.name}?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Remove')),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  final firestore = ref.read(firestoreProvider);
                  await firestore.collection('drivers').doc(driver.id).delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver removed')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showDriverDetailsGlobal(BuildContext context, AdminDriver driver, String driverId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(driver.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _globalDetailRow('Driver ID', driverId.isNotEmpty ? driverId : driver.id),
          _globalDetailRow('Phone', driver.phone),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    ),
  );
}

void _showEditDriverDialogGlobal(BuildContext context, WidgetRef ref, AdminDriver driver) {
  final nameController = TextEditingController(text: driver.name);
  final phoneController = TextEditingController(text: driver.phone);
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Driver'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Driver Name *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter driver name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter phone number' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            try {
              final firestore = ref.read(firestoreProvider);
              await firestore.collection('drivers').doc(driver.id).update({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              });
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver updated')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
