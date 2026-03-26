import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giới thiệu bản thân',
      home: IntroPage(),
    );
  }
}

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giới thiệu bản thân"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/images/anhdaidien1.jpg"),
              ),
              SizedBox(height: 20),
              Text(
                "Lê Văn Tùng",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Sinh viên lớp DCCNTT13.10.5\nKhoa Công nghệ Thông tin\nTrường Đại học Công nghệ Đông Á",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Tôi là người có tinh thần học hỏi, yêu thích công nghệ và đặc biệt quan tâm đến lĩnh vực lập trình. "
                    "Trong quá trình học tập, tôi luôn cố gắng trau dồi kiến thức chuyên môn cũng như kỹ năng làm việc nhóm để hoàn thành tốt các dự án được giao. "
                    "Mục tiêu của tôi trong tương lai là trở thành một lập trình viên chuyên nghiệp, có khả năng xây dựng các ứng dụng hữu ích và mang lại giá trị cho cộng đồng.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}