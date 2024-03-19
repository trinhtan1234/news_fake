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
              Container(
                height: 500,
                color: const Color.fromARGB(255, 231, 239, 243),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.isNotEmpty)
                      if (data.any(
                          (news) => news['phanloai'] == 'Tin bài hàng đầu'))
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
                    Text(data.isNotEmpty
                        ? data.firstWhere((news) =>
                                news['phanloai'] ==
                                'Tin bài hàng đầu')['tieude'] ??
                            ''
                        : ''),
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
              // SizedBox(
              //   height: 400,
              //   child: ListView.separated(
              //     scrollDirection: Axis.vertical,
              //     itemCount: min(
              //         3,
              //         data
              //             .where(
              //                 (news) => news['phanloai'] == 'Tin bài hàng đầu')
              //             .length),
              //     separatorBuilder: (context, index) {
              //       return const SizedBox(height: 0);
              //     },
              //     itemBuilder: (context, index) {
              //       final List<Map<String, dynamic>> filteredNews = data
              //           .where((news) => news['phanloai'] == 'Tin bài hàng đầu')
              //           .toList();
              //       final Map<String, dynamic> news = filteredNews[index];
              //       final dateTime = news['ngaytao'] as DateTime;
              //       const totalMinutes = 100;
              //       const hours = totalMinutes ~/ 60;
              //       const minutes = totalMinutes % 60;
              //       final formattedTime =
              //           '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} ${dateTime.day}-${dateTime.month}-${dateTime.year}';
              //       final bool isFirstItem = index == 0;
              //       return Column(
              //         children: [
              //           Container(
              //             color: Color.fromARGB(255, 241, 230, 230),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Container(
              //                   child:
              //                       isFirstItem && news['imagetieude'] != null
              //                           ? Container(
              //                               height: 200,
              //                               width: 400,
              //                               // color: Colors.grey,
              //                               child: Image.network(
              //                                 news['imagetieude'],
              //                                 fit: BoxFit.cover,
              //                               ),
              //                             )
              //                           : const SizedBox.shrink(),
              //                 ),
              //                 TextButton(
              //                   onPressed: () {},
              //                   child: Text(
              //                     news['nguontrang'] ?? '',
              //                     style: const TextStyle(
              //                         // color: Colors.black,
              //                         ),
              //                   ),
              //                 ),
              //                 Text(news['tieude'] ?? ''),
              //                 const Padding(padding: EdgeInsets.only(top: 10)),
              //                 Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(formattedTime),
              //                     Row(
              //                       children: [
              //                         IconButton(
              //                           onPressed: () {},
              //                           icon: const Icon(
              //                             Icons.collections_bookmark,
              //                             color: Colors.green,
              //                           ),
              //                         ),
              //                         IconButton(
              //                           onPressed: () {},
              //                           icon: const Icon(
              //                             Icons.more_horiz,
              //                             color: Colors.black,
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ],
              //                 ),
              //                 Divider(),
              //               ],
              //             ),
              //           ),
              //         ],
              //       );
              //     },
              //   ),
              // ),
              // Container(
              //   height: 200,
              //   color: Colors.blueAccent,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
