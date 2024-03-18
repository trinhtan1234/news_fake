import 'dart:async';

import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrangChuState createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  late final PostgreSQLConnection connection;

  List<Map<String, dynamic>> data = [];

  late Timer _timer;

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {});
    // print(_timer);
  }

  @override
  void initState() {
    super.initState();
    connection = PostgreSQLConnection(
      '192.168.1.3',
      5432,
      'tantv',
      username: 'postgres',
      password: 'abcd1234',
    );
    fetchDataFromPostgres();
    _startTimer();
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '  facebook',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.blue,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 60)),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.add)),
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.search)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.forum_outlined)),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const PostTinBai(),
                    //   ),
                    // );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://khoinguonsangtao.vn/wp-content/uploads/2022/08/hinh-nen-gai-xinh.jpg',
                              height: 30,
                              width: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 5)),
                          const Text(
                            'Bạn đang nghĩ gì ?',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color.fromARGB(255, 199, 195, 195),
                  thickness: 3,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> taikhoan = data[index];
                      return Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(),
                          image: DecorationImage(
                              image: NetworkImage(
                                '${taikhoan['anhtieude'] ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Creek_and_old-growth_forest-Larch_Mountain.jpg/220px-Creek_and_old-growth_forest-Larch_Mountain.jpg'}',
                              ),
                              fit: BoxFit.cover),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  '${taikhoan['avatar'] ?? 'https://www.shutterstock.com/image-vector/user-vector-icon-profile-illustration-260nw-1619136049.jpg'}',
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                '${taikhoan['tacgia'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  color: Color.fromARGB(255, 199, 195, 195),
                  thickness: 3,
                ),
                Column(
                  children: data.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> taikhoan = entry.value;
                    final dateTime = taikhoan['ngaythang'] as DateTime;
                    const totalMinutes = 100;
                    const hours = totalMinutes ~/ 60;
                    const minutes = totalMinutes % 60;
                    final formattedTime =
                        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      height: 500,
                      margin: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      '${taikhoan['avatar'] ?? 'https://www.shutterstock.com/image-vector/user-vector-icon-profile-illustration-260nw-1619136049.jpg'}',
                                      height: 30,
                                      width: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 5)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${taikhoan['tacgia'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => CapNhatBaiViet(
                                      //         taikhoan: data[index]),
                                      //   ),
                                      // );
                                    },
                                    icon: const Icon(Icons.more_horiz_outlined),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.close)),
                                ],
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Text(
                            '${taikhoan['tieude'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: taikhoan['anhtieude'] != null
                                  ? Container(
                                      height: 250,
                                      width: 400,
                                      color: Colors.grey,
                                      child: Image.network(
                                        taikhoan['anhtieude'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Row(
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined),
                                    Padding(padding: EdgeInsets.only(left: 2)),
                                    Text('9')
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Row(
                                  children: [
                                    Text('15 bình luận'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color:
                                            Color.fromARGB(255, 104, 102, 102),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 2)),
                                      Text(
                                        'Thích',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 104, 102, 102),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.forum_outlined,
                                        color:
                                            Color.fromARGB(255, 104, 102, 102),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 2)),
                                      Text(
                                        'Bình luận',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 104, 102, 102),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.share_outlined,
                                        color: Color.fromARGB(255, 68, 67, 67),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 2)),
                                      Text(
                                        'Chia sẻ',
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    connection.close();
    _timer.cancel(); // Đóng kết nối khi widget bị hủy
    super.dispose();
  }
}
