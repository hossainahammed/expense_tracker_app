import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/top_snackbar.dart';

class ExpenseNote {
  final String id;
  String title;
  String content;
  String category;
  DateTime updatedAt;

  ExpenseNote({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseNote.fromMap(Map<String, dynamic> map) {
    return ExpenseNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'General',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const String _prefsNotesKey = 'spendwise_user_notes';
  static const List<String> _categories = [
    'All',
    'General',
    'Budget',
    'Shopping',
    'Reminder',
  ];

  List<ExpenseNote> _notes = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsNotesKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        setState(() {
          _notes = decoded.map((e) => ExpenseNote.fromMap(e)).toList();
          _isLoading = false;
        });
        return;
      } catch (_) {}
    }
    setState(() {
      _notes = [];
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_notes.map((e) => e.toMap()).toList());
    await prefs.setString(_prefsNotesKey, jsonString);
  }

  List<ExpenseNote> get _filteredNotes {
    return _notes.where((note) {
      final matchesCategory =
          _selectedCategory == 'All' || note.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Budget':
        return const Color(0xFF0284C7); // Ocean Blue
      case 'Shopping':
        return const Color(0xFFF59E0B); // Amber
      case 'Reminder':
        return const Color(0xFF8B5CF6); // Purple
      case 'General':
      default:
        return const Color(0xFF0D9488); // Teal
    }
  }

  void _showNoteDialog({ExpenseNote? existingNote}) {
    final isEditing = existingNote != null;
    final titleController =
        TextEditingController(text: existingNote?.title ?? '');
    final contentController =
        TextEditingController(text: existingNote?.content ?? '');
    String noteCategory = existingNote?.category ?? 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      isEditing ? 'Edit Note' : 'Add Note',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Monthly Grocery Checklist',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Chips
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _categories
                          .where((c) => c != 'All')
                          .map((cat) {
                            final isSelected = noteCategory == cat;
                            final color = _getCategoryColor(cat);
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: color.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? color : null,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    noteCategory = cat;
                                  });
                                }
                              },
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Note Content',
                        hintText: 'Write down details, prices, or thoughts...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();

                          if (title.isEmpty && content.isEmpty) {
                            TopSnackbar.show(
                              context,
                              message: 'Please enter a title or note content',
                              icon: Icons.info_outline_rounded,
                              backgroundColor: Colors.orange.shade800,
                            );
                            return;
                          }

                          Navigator.pop(ctx);

                          setState(() {
                            if (isEditing) {
                              existingNote.title =
                                  title.isEmpty ? 'Untitled Note' : title;
                              existingNote.content = content;
                              existingNote.category = noteCategory;
                              existingNote.updatedAt = DateTime.now();
                            } else {
                              _notes.insert(
                                0,
                                ExpenseNote(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  title:
                                      title.isEmpty ? 'Untitled Note' : title,
                                  content: content,
                                  category: noteCategory,
                                  updatedAt: DateTime.now(),
                                ),
                              );
                            }
                          });
                          _saveNotes();

                          TopSnackbar.show(
                            context,
                            message: isEditing
                                ? 'Note updated successfully'
                                : 'Note added successfully',
                            icon: Icons.check_circle_rounded,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Save Changes' : 'Create Note',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteNote(ExpenseNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.only(top: 80, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Delete Note'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${note.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              _saveNotes();
              TopSnackbar.show(
                context,
                message: 'Note deleted',
                icon: Icons.delete_outline_rounded,
                backgroundColor: Colors.redAccent.shade700,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final filtered = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Notes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0x7F334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0x7F334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  final color =
                      cat == 'All' ? primaryColor : _getCategoryColor(cat);

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? color : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 4),

            // Notes List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.note_alt_outlined,
                                      size: 56,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No matching notes'
                                        : 'No notes in $_selectedCategory yet',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Try searching with different keywords'
                                        : 'Tap "+ New Note" to jot down shopping lists, financial plans, or reminders.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final note = filtered[index];
                            final catColor = _getCategoryColor(note.category);
                            final formattedDate = DateFormat.yMMMd()
                                .add_jm()
                                .format(note.updatedAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0x7F334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    _showNoteDialog(existingNote: note),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: catColor
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              note.category,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: catColor,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert_rounded,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(),
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _showNoteDialog(
                                                    existingNote: note);
                                              } else if (val == 'delete') {
                                                _confirmDeleteNote(note);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_rounded,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 18,
                                                        color:
                                                            Colors.redAccent),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .redAccent),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (note.content.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          note.content,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: isDark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
