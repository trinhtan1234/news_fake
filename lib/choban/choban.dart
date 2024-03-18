import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class ChoBan extends StatefulWidget {
  const ChoBan({super.key});

  @override
  State<ChoBan> createState() => _ChoBanState();
}

class _ChoBanState extends State<ChoBan> {
  late final PostgreSQLConnection connection;
  List<Map<String, dynamic>> data = [];

  Future<void> updateAccountStatus(bool isLocked, int userId) async {
    final connection = PostgreSQLConnection('192.168.1.3', 5432, 'tantv',
        username: 'postgres', password: 'abcd1234');

    try {
      await connection.open();
      await connection.query(
          'UPDATE news SET trangthai = @trangthai WHERE id = @id',
          substitutionValues: {'trangthai': isLocked, 'id': userId});
    } catch (e) {
      // print('Lỗi cập nhật trạng thái tài khoản: $e');
    } finally {
      await connection.close();
    }
  }

  late DateTime dateNow;
  late String formattedDate;

  @override
  void initState() {
    dateNow = DateTime.now();
    connection = PostgreSQLConnection(
      '192.168.1.3',
      5432,
      'tantv',
      username: 'postgres',
      password: 'abcd1234',
    );
    super.initState();
    formattedDate = "${dateNow.day}-${dateNow.month}-${dateNow.year}";
    fetchDataFromPostgres();

  }

  Future<void> openConnection() async {
    await connection.open();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    PostgreSQLResult results = await connection.query(
        'SELECT * FROM tinbai WHERE trangthai = false ORDER BY ngaythang DESC;'
        // 'SELECT * FROM public.tinbai WHERE trangthai = false ORDER BY thoigian ASC',
        );
    List<Map<String, dynamic>> resultList = [];

    for (var row in results) {
      resultList.add(Map<String, dynamic>.from(row.toColumnMap()));
    }

    return resultList;
  }

  Future<void> fetchDataFromPostgres() async {
    try {
      await openConnection();
      final data = await fetchData();
      setState(() {
        this.data = data;
      });
    } catch (error) {
      // print('Lỗi lấy dữ liệu từ PostgreSQL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.search_outlined),
        actions: [
          ClipOval(
            child: Image.network(
              'https://khoinguonsangtao.vn/wp-content/uploads/2022/08/hinh-nen-gai-xinh.jpg',
              height: 30,
              width: 30,
              fit: BoxFit.cover,
            ),
          ),
        ],
        title: const Center(
          child: Text(
            'Google News',
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tin vắn dành cho bạn',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Text(formattedDate),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 231, 231),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1)),
                child: IconButton(
                  onPressed: () {},
                  icon: const Row(
                    children: [
                      Text('23'),
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                      ),
                      Icon(Icons.cloud_outlined),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
