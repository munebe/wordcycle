import 'package:flutter/material.dart';
import 'package:wordcycle/pages/add_word_page.dart';
import '../helpers/tts_helper.dart';
import '../models/word.dart';
import '../helpers/db_helper.dart';
import 'view_word_page.dart'; // ViewWordPage'i içe aktarıyoruz

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<Word> _searchableWords = [];
  List<Word> _filteredWords = [];
  final TtsHelper _ttsHelper = TtsHelper(); // TtsHelper'ı başlatıyoruz
  late DbHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _initializeDbHelper();
  }

  Future<void> _initializeDbHelper() async {
    _dbHelper = await DbHelper.create();
    await _fetchWords();
  }

  Future<void> _fetchWords() async {
    try {
      final List<Map<String, dynamic>> wordMaps = await _dbHelper.getWords();
      final List<Word> words =
          wordMaps.map((map) => Word.fromMap(map)).toList();

      setState(() {
        _searchableWords = words;
        _sortAndFilterWords(); // Listeyi sıralama ve filtreleme işlemi
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken bir hata oluştu: $e')),
      );
    }
  }

  void _sortAndFilterWords() {
    _filteredWords = List.from(_searchableWords);

    _filteredWords.sort((a, b) {
      if (a.isLearned == b.isLearned) {
        return a.title.compareTo(b.title);
      }
      return a.isLearned ? 1 : -1;
    });
  }

  void _filterWords(String query) {
    final List<Word> results = _searchableWords
        .where((word) => word.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredWords = results;
      _sortAndFilterWords(); // Listeyi sıralama ve filtreleme işlemi
    });
  }

  void _toggleLearned(int id) async {
    setState(() {
      final word = _filteredWords.firstWhere((word) => word.id == id);
      word.isLearned = !word.isLearned;
    });

    try {
      final word = _filteredWords.firstWhere((word) => word.id == id);
      await _dbHelper.updateWord(id, word.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kelime ID $id öğrenilme durumu güncellendi.')),
      );

      _sortAndFilterWords(); // Sıralamayı güncelle ve listeyi yeniden render et
      setState(() {}); // State'i yenileyerek ListView'i yeniden render et
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme sırasında bir hata oluştu: $e')),
      );
    }
  }

  void _onCardTap(Word word) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewWordPage(word: word)),
    );

    if (result == true) {
      await _fetchWords(); // Kelime silinmiş veya güncellenmişse listeyi yenile
    }
  }

  void _onAddButtonPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWordPage()),
    );

    if (result == true) {
      await _fetchWords(); // Listeyi yenile
    }
  }

  void _onPronounceButtonPressed(String word) {
    _ttsHelper.speak(word); // Kelimenin telaffuzunu oynatıyoruz
  }

  String _shortenText(String text, int maxLength) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: const Color(0xFF1D93F3),
        automaticallyImplyLeading: true, // Geri butonunu kaldırır
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(
                  searchableWords: _searchableWords,
                  onSelected: (String selectedWord) {
                    _filterWords(selectedWord);
                  },
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _filteredWords.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredWords.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: InkWell(
                    onTap: () => _onCardTap(_filteredWords[index]),
                    child: ListTile(
                      leading: Checkbox(
                        value: _filteredWords[index].isLearned,
                        activeColor:
                            const Color(0xFF1D93F3), // Checkbox true rengi
                        onChanged: (bool? value) {
                          _toggleLearned(_filteredWords[index].id!);
                        },
                      ),
                      title: Text(
                        _filteredWords[index].title,
                        maxLines: 2,
                        overflow: TextOverflow
                            .ellipsis, // Limit to two lines and add ellipsis
                      ),
                      subtitle: Text(
                        _shortenText(
                            _filteredWords[index].mean, 20), // Metni kısaltma
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up), // Ses ikonu
                        onPressed: () => _onPronounceButtonPressed(
                            _filteredWords[index].title),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        backgroundColor: const Color(0xFF1D93F3),
        child: const Icon(
          Icons.add,
          size: 32, // İkon boyutu büyütüldü
          color: Colors.white, // İkon rengi beyaz yapıldı
        ),
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  final List<Word> searchableWords;
  final Function(String) onSelected;

  MySearchDelegate({required this.searchableWords, required this.onSelected});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = ''; // Clear the search query
            onSelected(''); // Reset the filter
          },
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => null; // Geri butonu yok

  @override
  Widget buildResults(BuildContext context) {
    final List<Word> results = searchableWords
        .where((word) => word.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results
          .map((result) => ListTile(
                title: Text(
                  result.title,
                  maxLines: 2,
                  overflow: TextOverflow
                      .ellipsis, // Limit to two lines and add ellipsis
                ),
                onTap: () {
                  onSelected(result.title);
                  close(context,
                      null); // Close the search and return the result immediately
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Word> suggestions = searchableWords
        .where(
            (word) => word.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions
          .map((suggestion) => ListTile(
                title: Text(
                  suggestion.title,
                  maxLines: 2,
                  overflow: TextOverflow
                      .ellipsis, // Limit to two lines and add ellipsis
                ),
                onTap: () {
                  query = suggestion.title;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }
}
