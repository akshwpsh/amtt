import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Service/FirebaseService.dart';


class KeywordsPage extends StatefulWidget {
  @override
  _KeywordsPageState createState() => _KeywordsPageState();
}

class _KeywordsPageState extends State<KeywordsPage> {
  final TextEditingController _keywordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  void _addKeyword() async {
    if (user != null && _keywordController.text.isNotEmpty) {
      FirebaseService().addKeyword(_keywordController.text);
      _keywordController.clear();
    }
  }

  void _deleteKeyword(String docId) async {
    await FirebaseFirestore.instance.collection('keywords').doc(docId).delete();
  }

  void _editKeyword(String docId, String newKeyword) async {
    await FirebaseFirestore.instance.collection('keywords').doc(docId).update({
      'keyword': newKeyword,
    });
  }

  void _showEditDialog(String docId, String currentKeyword) {
    final TextEditingController _editController = TextEditingController(text: currentKeyword);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('키워드 수정'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(labelText: '새 키워드 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _editKeyword(docId, _editController.text);
                Navigator.of(context).pop();
              },
              child: Text('수정'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 키워드 추가'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                labelText: '키워드 입력',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addKeyword,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('keywords')
                  .where('uid', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final keywords = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: keywords.length,
                  itemBuilder: (context, index) {
                    final keywordData = keywords[index];
                    return ListTile(
                      title: Text(keywordData['keyword']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(keywordData.id, keywordData['keyword']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteKeyword(keywordData.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
