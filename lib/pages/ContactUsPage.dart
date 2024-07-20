import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    String supportEmail = "sophra1234@gmail.com";
    final Email email = Email(
      body: '보낸 사람: ${_nameController.text}\n이메일: ${_emailController.text}\n\n메시지:\n${_messageController.text}',
      subject: '문의하기',
      recipients: ['sophra1234@gmail.com'], // 수신자 이메일을 여기에 입력
      isHTML: false, // 일반 텍스트로 전송
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문의가 전송되었습니다.')),
      );
    } catch (error) {
      print(error);
      _showErrorDialog(supportEmail);
    }
  }
  void _showErrorDialog(String supportEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('문의 전송 실패'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('문의 전송에 실패했습니다. 다음 이메일 주소로 문의해주세요.'),
              SizedBox(height: 10),
              Text('이메일: $supportEmail'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 이메일 주소를 클립보드에 복사
                Clipboard.setData(ClipboardData(text: supportEmail));
                Navigator.of(context).pop();
              },
              child: Text('이메일 복사'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('문의하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: '메시지'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('전송'),
            ),
          ],
        ),
      ),
    );
  }
}
