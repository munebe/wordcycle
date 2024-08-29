import 'package:flutter/material.dart';
import '../models/word.dart';
import '../helpers/db_helper.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _formKey = GlobalKey<FormState>();
  late DbHelper _dbHelper;

  String _title = '';
  String _type = 'noun';
  String _mean = '';
  String? _example1;
  String? _example2;

  final List<bool> _selectedType = [
    false,
    false,
    true,
    false
  ]; // Default olarak 'noun' seçili

  @override
  void initState() {
    super.initState();
    _initializeDbHelper();
  }

  Future<void> _initializeDbHelper() async {
    _dbHelper = await DbHelper.create();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newWord = Word(
        title: _title,
        type: _type,
        mean: _mean,
        example1: _example1,
        example2: _example2,
      );

      try {
        await _dbHelper.insertWord(newWord.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni kelime eklendi!')),
        );
        Navigator.of(context).pop(true); // Formdan geri dönerken true döndür
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt sırasında bir hata oluştu: $e')),
        );
      }
    }
  }

  void _updateType(int index) {
    setState(() {
      // Tüm butonları false yap, sadece seçilen buton true olacak
      for (int i = 0; i < _selectedType.length; i++) {
        _selectedType[i] = i == index;
      }
      // Seçilen butona göre _type değerini güncelle
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kelime Ekle'),
        backgroundColor: const Color(0xFF1D93F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildToggleButtonsField(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Title',
                onSaved: (value) {
                  _title = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Meaning',
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
                onSaved: (value) {
                  _example1 = value;
                },
                maxLines: 3, // Example alanı için yüksekliği artırıyoruz
                minLines: 2, // Minimum satır sayısı
              ),
              _buildTextField(
                label: 'Example 2',
                onSaved: (value) {
                  _example2 = value;
                },
                maxLines: 3, // Example alanı için yüksekliği artırıyoruz
                minLines: 2, // Minimum satır sayısı
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int? maxLines,
    int? minLines,
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
        ),
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(fontSize: 18),
        maxLines: maxLines, // Maksimum satır sayısı
        minLines: minLines, // Minimum satır sayısı
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
            isSelected: _selectedType,
            onPressed: (int index) {
              _updateType(index);
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
}
