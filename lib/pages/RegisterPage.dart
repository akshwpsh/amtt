import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

//위젯 임포트
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:geolocator/geolocator.dart';
import 'LoginPage.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/UniversitySearch.dart';


class RegisterPage extends StatefulWidget {
  final bool isGoogleSignUp;
  final User? user;

  RegisterPage({required this.isGoogleSignUp, this.user});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  //현재 페이지 변수
  int _currentPage = 0;
  bool _isRegistDone = false;

  List<University> universities = []; // 가져온 모든 대학 리스트(이름,위도,경도)
  List<String> univNames = []; // 대학 검색창을 위한 리스트
  List<String> filteredUnivNames = [];






  @override
  void initState() {
    super.initState();
    if (widget.isGoogleSignUp && widget.user != null) {
      _emailController.text = widget.user!.email ?? '';
    }
  }

  @override
  void dispose() {
    ///위젯이 화면에서 제거될때 호출
    ///구글로 로그인한 사용자가
    ///추가 사용자정보를 입력하지 않으면
    ///로그아웃
    if (!_isRegistDone && widget.isGoogleSignUp && _auth.currentUser != null) {
      _logout();
    }
    super.dispose();
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃되었습니다. 추가 사용자 정보 입력이 필요합니다.')),
      );
      // 로그인 페이지로 리디렉션
       Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  //다음페이지로 이동
  void _nextPage() {
    if (_currentPage < 4) {
      setState(() {
        _currentPage += 1;
      });
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _register();
    }
  }

  //이전 페이지로 이동
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage -= 1;
      });
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _register() async {
    if (!widget.isGoogleSignUp &&
        _passwordController.text != _confirmPasswordController.text) {
      print('Passwords do not match');
      return;
    }

    try {
      User? user;

      if (widget.isGoogleSignUp) {
        user = widget.user;
        if (user == null) {
          throw Exception('유저정보미확인 오류');
        }
      } else {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        user = userCredential.user;
        await userCredential.user!
            .updateDisplayName(_nickNameController.text.trim());
      }

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'nickName': _nickNameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim().replaceAll('-', ''),
          'studentId': _studentIdController.text.trim(),
          'school': _schoolController.text.trim(),
          'department': _departmentController.text.trim(),
          'registeredAt': FieldValue.serverTimestamp(),
          'auth': 'user',
        });
        print('Registration successful: $user');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가입에 성공하였습니다!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );


        setState(() {
          _isRegistDone = true;
        });
      }
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //키보드 올라올때 사이즈 에러 방지
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('회원가입'),
          leading: _currentPage > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                )
              : null,
        ),
        bottomSheet: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
                  child: Container(
                      height: 0.15.sh,
                      child: Column(
                        children: [
                          Container(
                            alignment: FractionalOffset.bottomRight,
                            child: Text('${_currentPage + 1}/5'),
                          ),
                          Container(
                            child: LinearProgressIndicator(
                              value: (_currentPage + 1) / 5,
                              backgroundColor: Color(0xFFDBDBDB),
                              color: Color(0xFF4EBDBD),
                            ),
                          ),
                          SizedBox(height: 0.03.sh),
                          //다음 버튼

                          BtnYesBG(
                              btnText:
                                  _currentPage < (widget.isGoogleSignUp ? 2 : 4)
                                      ? '다음'
                                      : '등록',
                              onPressed: _nextPage),
                        ],
                      ))),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(0.1.sw),
          child: Column(
            children: [
              //회원가입 폼 - 페이지뷰
              Expanded(
                  flex: 4,
                  child: Container(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        if (!widget.isGoogleSignUp)
                          SignUpStep1(emailController: _emailController),
                        if (!widget.isGoogleSignUp)
                          SignUpStep2(
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController),
                        SignUpStep3(nickNameController: _nickNameController),
                        SignUpStep4(
                            nameController: _nameController,
                            phoneNumberController: _phoneNumberController),
                        SignUpStep5(
                            studentIdController: _studentIdController,
                            schoolController: _schoolController,
                            departmentController: _departmentController,),
                      ],
                    ),
                  )),

              //하단 인디케이터와 버튼 모음
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Column(
                    children: [],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class SignUpStep1 extends StatelessWidget {
  final TextEditingController emailController;

  SignUpStep1({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('가입하려는 이메일 주소를 작성해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '이메일 작성',
            controller: emailController,
            obscureText: false,
          ),
        ],
      ),
    );
  }
}

class SignUpStep2 extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  SignUpStep2(
      {required this.passwordController,
      required this.confirmPasswordController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비밀번호를 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '8자리 이상 입력',
            controller: passwordController,
            obscureText: true,
          ),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '비밀번호 확인',
            controller: confirmPasswordController,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class SignUpStep3 extends StatelessWidget {
  final TextEditingController nickNameController;

  SignUpStep3({required this.nickNameController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('닉네임을 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '닉네임',
            controller: nickNameController,
            obscureText: false,
          ),
        ],
      ),
    );
  }
}

class SignUpStep4 extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;

  SignUpStep4(
      {required this.nameController, required this.phoneNumberController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이름과 전화번호를 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '이름',
            controller: nameController,
            obscureText: false,
          ),
          SizedBox(height: 20),
          RoundedTextField(
            labelText: '전화번호',
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [ //숫자만 받도록 제한
              FilteringTextInputFormatter.digitsOnly
            ],
            obscureText: false,
          ),
        ],
      ),
    );
  }
}

class SignUpStep5 extends StatefulWidget {
  final TextEditingController studentIdController;
  final TextEditingController schoolController;
  final TextEditingController departmentController;


  SignUpStep5({
    required this.studentIdController,
    required this.schoolController,
    required this.departmentController,
  });


  @override
  _SignUpStep5State createState() => _SignUpStep5State();
}

class _SignUpStep5State extends State<SignUpStep5> {

  List<University> universities = []; // 가져온 모든 대학 리스트(이름,위도,경도)
  List<String> univNames = []; // 대학 검색창을 위한 리스트
  List<String> filteredUnivNames = [];

  void _onSearchChanged() {
    String searchTerm = widget.schoolController.text.toLowerCase();
    setState(() {
      filteredUnivNames = univNames
          .where((univ) => univ.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  void initState() {
    fetchUniversities();
    widget.schoolController.addListener(_onSearchChanged);
    super.initState();
  }

  // 대학 리스트 가져오는 메서드
  Future<void> fetchUniversities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('university').get();
      List<University> fetchedUniversities = querySnapshot.docs.map((doc) {
        return University.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        universities = fetchedUniversities;
        univNames = universities.map((university) => university.name).toList();
      });
    } catch (e) {
      print('Error fetching universities: $e');
    }
  }

  // 현재 위치 가져오느 메서드
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스가 활성화되어 있지 않으면 오류를 반환
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 활성화 되어 있지 않음');
    }

    // 위치 권한을 확인합니다.
    permission = await Geolocator.checkPermission();

    // 권한이 거부된 경우 권한 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // 권한 요청이 거부 시 에러
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          '위치 권한이 영구적으로 거부되어 요청을 할 수 없습니다.');
    }

    // 장치 위치 가져오기(권한 허용상태)
    return await Geolocator.getCurrentPosition();
  }

  // 현재 위치를 기준으로 대학교를 기준거리에 따라 필터링 하는 메서드
  List<String> _filterUniversitiesByDistance(Position currentPosition) {
    List<String> nearbyUniversities = [];

    for (var university in universities) {

      // 현재 위치와 대학 위치 사이의 거리를 미터 단위로 계산
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        university.latitude,
        university.longitude,
      );
      // 거리가 20km 이내인 경우 대학 이름을 리스트에 추가.
      if (distanceInMeters <= 20000) { // TODO : 하드코딩된 값이라 추후 외부에서 수정할 수 있게
        nearbyUniversities.add(university.name);
      }
    }
    // 필터링된 대학 리스트를 반환
    return nearbyUniversities;
  }

  @override
  void dispose() {
    widget.schoolController.removeListener(_onSearchChanged);
    widget.schoolController.dispose();
    super.dispose();
  }

  // 하단 주변 대학 설정 바 올라오게 하는 메서드
  Future<void> _showBottomSheet() async {
    Position currentPosition = await _getCurrentLocation();
    List<String> nearbyUniversities = _filterUniversitiesByDistance(currentPosition);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(
          universities: nearbyUniversities,
          onUniversitySelected: (String university) {
            setState(() {
              widget.schoolController.text = university;
              filteredUnivNames.clear();
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white, // Scaffold의 배경색을 흰색으로 설정
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Container( // Container를 추가하여 전체 배경색 제어
                color: Colors.white, // 내부 배경색을 흰색으로 설정
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 20.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('학번, 학교, 학과를 입력해주세요', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      RoundedTextField(
                        labelText: '학번',
                        controller: widget.studentIdController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      RoundedTextField(
                        labelText: '학과',
                        controller: widget.departmentController,
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      UniversitySearch(
                        controller: widget.schoolController,
                        filteredUnivNames: filteredUnivNames,
                        onUniversitySelected: (String university) {
                          setState(() {
                            widget.schoolController.text = university;
                            filteredUnivNames.clear();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _showBottomSheet,
                          child: Text('주변 대학 찾기', style: TextStyle(color: Colors.black, fontSize: 16),),
                        ),
                      ),
                      SizedBox(height: 200), // 추가 여백
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class University {
  final String name;
  final double latitude;
  final double longitude;

  University({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

// 하단에서 올라오는 주변 대학 리스트 다이얼로그창
class BottomSheetContent extends StatelessWidget {
  final List<String> universities;
  final Function(String) onUniversitySelected;

  BottomSheetContent({required this.universities, required this.onUniversitySelected,});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단바 공간
          Text(
            '내 주변 대학 목록',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '원하는 대학교를 리스트에서 찾은 후 선택버튼을 클릭하세요',
            style: TextStyle(fontSize: 16, color: Color(0xff767676)),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: universities.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 65,
                    margin: EdgeInsets.symmetric(vertical: 6), // 아이템 간 위아래 마진
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리 값
                    ),
                    child: Padding(
                      // 내부 패딩 값
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            // 키워드 제목 텍스트
                            child: Text(
                              universities[index],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          // 대학교 선택 버튼
                          Container(
                            width: 90,
                            child: BtnYesBG(btnText: '선택',
                              onPressed: () { onUniversitySelected(universities[index]); },),
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
