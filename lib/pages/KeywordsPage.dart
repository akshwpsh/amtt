import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class KeywordsPage extends StatefulWidget {
  @override
  _KeywordsPageState createState() => _KeywordsPageState();
}

class _KeywordsPageState extends State<KeywordsPage> {
  final TextEditingController _keywordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  void _addKeyword() async {

    // 키워드 입력창이 비어있지 않은 경우
    if(_keywordController.text.isNotEmpty) {

      // 로그인되어 있다면
      if (user != null) {
        await FirebaseFirestore.instance.collection('keywords').add({
          'uid': user!.uid,
          'keyword': _keywordController.text,
        });
        _keywordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('키워드가 추가되었습니다!')),
        );
      }

    }
    //키워드 입력창이 비어있을경우
    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('키워드를 입력해주세요.')),
      );

    }


  }

  // 키워드 삭제 메서드
  void _deleteKeyword(String docId) async {
    await FirebaseFirestore.instance.collection('keywords').doc(docId).delete();
  }

  // 키워드 수정 메서드
  void _editKeyword(String docId, String newKeyword) async {
    await FirebaseFirestore.instance.collection('keywords').doc(docId).update({
      'keyword': newKeyword,
    });
  }

  // 키워드 수정 다이얼로그 창 메서드
  void _showEditDialog(String docId, String currentKeyword) {
    final TextEditingController _editController = TextEditingController(text: currentKeyword);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 0.3.sh,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    "키워드 수정",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _editController,
                      decoration: InputDecoration(
                        hintText: "텍스트를 입력하세요",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: BtnNoBG(
                            btnText: '취소',
                            onPressed: () { Navigator.of(context).pop(); },
                          ),
                        ),

                        SizedBox(width: 10,),

                        Expanded(
                          child: BtnYesBG(
                            btnText: '확인',
                            onPressed: () {
                              _editKeyword(docId, _editController.text);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),



                ],
              ),
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0.04.sw),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
            backgroundColor: Colors.white,
            title: Text('알림 키워드 관리'),
          ),
          body: Column(
            children: [

              SizedBox(height : 20,),

              Row(

                children: [

                  // 키워드 입력 창 (텍스트필드)
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 0.06.sh,
                      child: RoundedTextField(
                        labelText: '키워드 입력',
                        controller: _keywordController,
                        obscureText: false,

                      ),
                    ),
                  ),

                  SizedBox(width: 15,),

                  // 키워드 추가버튼
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 0.06.sh,
                      child: BtnYesBG(
                        btnText: '추가',
                        onPressed: () { _addKeyword(); },
                      ),
                    ),
                  ),



                ],

              ),

              SizedBox(height : 20,),

              Row(
                children: [
                  Expanded(
                    child : Text('키워드 목록'),
                  ),
                ],
              ),

              SizedBox(height : 15,),

              //키워드 리스트 공간
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


                    //키워드 리스트
                    return ListView.builder(
                      itemCount: keywords.length,
                      itemBuilder: (context, index) {
                        final keywordData = keywords[index];


                        return CustomListTile (
                          title: keywordData['keyword'],
                          onEdit: () => _showEditDialog(keywordData.id, keywordData['keyword']),
                          onDelete: () => _deleteKeyword(keywordData.id),
                        );


                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 커스텀 키워드 리스트 아이템 위젯
class CustomListTile extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: EdgeInsets.symmetric(vertical: 4), // 아이템 간 위아래 마진
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12), // 둥근 모서리 값
      ),
      child: Padding(
        //내부 패딩 값
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              
              // 키워드 제목 텍스트
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            //키워드 수정 버튼
            IconButton(
              icon: Icon(Icons.edit, size: 22),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            
            //키워드 삭제 버튼
            SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.delete, size: 22),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}






