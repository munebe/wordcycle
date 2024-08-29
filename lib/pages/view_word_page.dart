import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için intl paketini kullanıyoruz
import '../models/word.dart';
import '../helpers/db_helper.dart';
import '../helpers/tts_helper.dart';

class ViewWordPage extends StatefulWidget {
  final Word word;

  const ViewWordPage({super.key, required this.word});

  @override
  State<ViewWordPage> createState() => _ViewWordPageState();
}

class _ViewWordPageState extends State<ViewWordPage> {
  final _formKey = GlobalKey<FormState>();
  late DbHelper _dbHelper;
  final TtsHelper _ttsHelper = TtsHelper();

  late String _title;
  late String _type;
  late String _mean;
  String? _example1;
  String? _example2;

  @override
  void initState() {
    super.initState();
    _initializeDbHelper();

    _title = widget.word.title;
    _type = widget.word.type;
    _mean = widget.word.mean;
    _example1 = widget.word.example1;
    _example2 = widget.word.example2;
  }

  Future<void> _initializeDbHelper() async {
    _dbHelper = await DbHelper.create();
  }

  void _updateWord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedWord = Word(
        id: widget.word.id,
        title: _title,
        type: _type,
        mean: _mean,
        example1: _example1,
        example2: _example2,
        isLearned: widget.word.isLearned,
        correctCount: widget.word.correctCount,
        createdAt: widget.word.createdAt, // createdAt değeri güncellenmiyor
      );

      try {
        await _dbHelper.updateWord(updatedWord.id!, updatedWord.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kelime güncellendi!')),
        );
        Navigator.of(context).pop(true); // Geri dön ve güncelleme sonucu döndür
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme sırasında bir hata oluştu: $e')),
        );
      }
    }
  }

  void _deleteWord() async {
    try {
      await _dbHelper.deleteWord(widget.word.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelime silindi!')),
      );
      Navigator.of(context).pop(true); // Geri dön ve silme sonucu döndür
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme sırasında bir hata oluştu: $e')),
      );
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Bilinmiyor';
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Detaylar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[100],
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  label: 'Eklenme Tarihi:',
                  value: _formatDate(widget.word.createdAt),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  label: 'Öğrenildi mi:',
                  value: widget.word.isLearned ? 'Evet' : 'Hayır',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  label: 'Doğru Sayısı:',
                  value: widget.word.correctCount.toString(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kapat',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelimeyi Görüntüle'),
        backgroundColor: const Color(0xFF1D93F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDetailsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildToggleButtonsField(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Title',
                initialValue: _title,
                onSaved: (value) {
                  _title = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur.';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    _ttsHelper.speak(_title);
                  },
                ),
              ),
              _buildTextField(
                label: 'Meaning',
                initialValue: _mean,
                onSaved: (value) {
                  _mean = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Example 1',
                initialValue: _example1,
                onSaved: (value) {
                  _example1 = value;
                },
                maxLines: 3,
                minLines: 2,
              ),
              _buildTextField(
                label: 'Example 2',
                initialValue: _example2,
                onSaved: (value) {
                  _example2 = value;
                },
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _deleteWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Sil'),
                  ),
                  ElevatedButton(
                    onPressed: _updateWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Güncelle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int? maxLines,
    int? minLines,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(fontSize: 18),
        maxLines: maxLines,
        minLines: minLines,
        initialValue: initialValue,
      ),
    );
  }

  Widget _buildToggleButtonsField() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Type',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          ToggleButtons(
            isSelected: [
              _type == 'adjective',
              _type == 'adverb',
              _type == 'noun',
              _type == 'verb',
            ],
            onPressed: (int index) {
              setState(() {
                _updateType(index);
              });
            },
            borderRadius: BorderRadius.circular(8.0),
            selectedColor: Colors.white,
            fillColor: const Color(0xFF1D93F3),
            color: Colors.black,
            selectedBorderColor: const Color(0xFF1D93F3),
            borderColor: Colors.grey,
            constraints: BoxConstraints.expand(
              width: MediaQuery.of(context).size.width *
                  0.22, // Her buton için genişlik
              height: 50, // Buton yüksekliği
            ),
            children: const [
              Text('Adjective'),
              Text('Adverb'),
              Text('Noun'),
              Text('Verb'),
            ],
          ),
        ],
      ),
    );
  }

  void _updateType(int index) {
    switch (index) {
      case 0:
        _type = 'adjective';
        break;
      case 1:
        _type = 'adverb';
        break;
      case 2:
        _type = 'noun';
        break;
      case 3:
        _type = 'verb';
        break;
    }
  }
}
