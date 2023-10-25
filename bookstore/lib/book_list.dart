import 'package:bookstore/sql_bd.dart';
import 'package:flutter/material.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  SqlDb sqlDb = SqlDb();
  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readData("SELECT * from books");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readData(),
        builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              physics: const NeverScrollableScrollPhysics(),
              //shrinkWrap: true,
              itemBuilder: (context, i) {
                return Card(
                  child: ListTile(
                    leading: Image(
                      image: NetworkImage("${snapshot.data![i]["coverurl"]}"),
                    ),
                    title: Text("${snapshot.data![i]["title"]}"),
                    subtitle: Text("${snapshot.data![i]["author"]}"),
                    trailing: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Delete Book',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                      'Are you sure you want to delete this book ?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () async {
                                        int response = await sqlDb.deleteData(
                                            "DELETE FROM books WHERE id = ${snapshot.data![i]['id']}");

                                        if (response > 0) {
                                          snapshot.data!.removeWhere(
                                              (element) =>
                                                  element['id'] ==
                                                  snapshot.data![i]['id']);
                                        }
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Yes",
                                          style: TextStyle(
                                            color: Colors.red,
                                          )),
                                    )
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.delete)),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
