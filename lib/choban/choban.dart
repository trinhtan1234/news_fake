import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

class ChoBan extends StatefulWidget {
  const ChoBan({super.key});

  @override
  State<ChoBan> createState() => _ChoBanState();
}

class _ChoBanState extends State<ChoBan> {
  late final PostgreSQLConnection connection;
  List<Map<String, dynamic>> data = [];

  Future<void> updateAccountStatus(bool isLocked, int newId) async {
    final connection = PostgreSQLConnection('192.168.0.54', 5432, 'tantv',
        username: 'postgres', password: 'abcd1234');

    try {
      await connection.open();
      await connection.query(
          'UPDATE news SET trangthai = @trangthai WHERE id = @id',
          substitutionValues: {'trangthai': isLocked, 'id': newId});
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
    connection = PostgreSQLConnection(
      '192.168.0.54',
      5432,
      'tantv',
      username: 'postgres',
      password: 'abcd1234',
    );
    super.initState();
    initializeDateFormatting('vi_VN', null);
    dateNow = DateTime.now();
    formattedDate = DateFormat('EEEE, dd-MM-yyyy', 'vi').format(dateNow);
    fetchDataFromPostgres();
  }

  Future<void> openConnection() async {
    await connection.open();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    PostgreSQLResult results = await connection.query(
        'SELECT * FROM news_fake WHERE trangthai = false ORDER BY ngaytao DESC;'
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tin vắn dành cho bạn',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(formattedDate),
                      ],
                    ),
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
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'Tin bài hàng đầu',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              SizedBox(
                height: 530,
                // color: const Color.fromARGB(255, 231, 239, 243),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.isNotEmpty)
                      if (data.any(
                          (news) => news['phanloai'] == 'Tin bài hàng đầu'))
                        const Padding(padding: EdgeInsets.only(top: 10)),
                    SizedBox(
                      height: 200,
                      width: 400,
                      child: Image.network(
                        data.firstWhere((news) =>
                            news['phanloai'] ==
                            'Tin bài hàng đầu')['imagetieude'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      data.isNotEmpty
                          ? data.firstWhere((news) =>
                                  news['phanloai'] ==
                                  'Tin bài hàng đầu')['nguontrang'] ??
                              ''
                          : '',
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      data.isNotEmpty
                          ? data.firstWhere((news) =>
                                  news['phanloai'] ==
                                  'Tin bài hàng đầu')['tieude'] ??
                              ''
                          : '',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.isNotEmpty
                              ? DateFormat('EEEE, dd-MM-yyyy', 'vi').format(
                                  data.firstWhere((news) =>
                                          news['phanloai'] ==
                                          'Tin bài hàng đầu')['ngaytao'] ??
                                      DateTime.now())
                              : '',
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.collections_bookmark,
                                size: 20,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.length > 1 &&
                                        data[1]['phanloai'] ==
                                            'Tin bài hàng đầu'
                                    ? data[1]['nguontrang'] ?? ''
                                    : '',
                              ),
                              Text(
                                data.length > 1 &&
                                        data[1]['phanloai'] ==
                                            'Tin bài hàng đầu'
                                    ? data[1]['tieude'] ?? ''
                                    : '',
                              ),
                              Text(
                                data.isNotEmpty
                                    ? DateFormat('EEEE, dd-MM-yyyy', 'vi')
                                        .format(data.firstWhere((news) =>
                                                    news['phanloai'] ==
                                                    'Tin bài hàng đầu')[
                                                'ngaytao'] ??
                                            DateTime.now())
                                    : '',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Image.network(
                              data.length > 1 &&
                                      data[1]['phanloai'] == 'Tin bài hàng đầu'
                                  ? data[1]['imagetieude'] ?? ''
                                  : '',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.collections_bookmark,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.length > 1 &&
                                        data[1]['phanloai'] ==
                                            'Tin bài hàng đầu'
                                    ? data[1]['nguontrang'] ?? ''
                                    : '',
                              ),
                              Text(
                                data.length > 1 &&
                                        data[1]['phanloai'] ==
                                            'Tin bài hàng đầu'
                                    ? data[1]['tieude'] ?? ''
                                    : '',
                              ),
                              Text(
                                data.isNotEmpty
                                    ? DateFormat('EEEE, dd-MM-yyyy', 'vi')
                                        .format(data.firstWhere((news) =>
                                                    news['phanloai'] ==
                                                    'Tin bài hàng đầu')[
                                                'ngaytao'] ??
                                            DateTime.now())
                                    : '',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Image.network(
                              data.length > 1 &&
                                      data[1]['phanloai'] == 'Tin bài hàng đầu'
                                  ? data[1]['imagetieude'] ?? ''
                                  : '',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.collections_bookmark,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
              Container(
                height: 400,
                color: const Color.fromARGB(255, 212, 238, 225),
              ),
              Container(
                height: 400,
                color: const Color.fromARGB(255, 214, 216, 197),
              )
            ],
          ),
        ),
      ),
    );
  }
}
