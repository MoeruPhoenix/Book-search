import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColorDark: Color.fromRGBO(230, 74, 25, 1),
        primaryColorLight: Color.fromRGBO(255, 204, 188, 1),
        primaryColor: Color.fromRGBO(255, 87, 34, 1),
        accentColor: Color.fromRGBO(255, 193, 7, 1),
      ),
      home: MyHomePage(title: 'Book Search'),
    );
  }
}

class BookListItem extends StatefulWidget {
  const BookListItem({
    this.thumbnail,
    this.title,
    this.releaseDate,
    this.author,
  });

  final Widget thumbnail;
  final String title;
  final String releaseDate;
  final String author;

  @override
  _BookListItemState createState() => _BookListItemState();
}

class _BookListItemState extends State<BookListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: widget.thumbnail,
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String uP = "";
  String search = "Dad";
  String userSearch = "";
  String aURL = "https://www.googleapis.com/books/v1/volumes?q=";
  final myController = TextEditingController();
  TextEditingController controller = new TextEditingController();
  Object get jsonData => null;
  filtersearch(String text) {
    setState(() {
      if (text != "") {
        this.search = text;
      }
    });
  }

  //Validation
  validate(data, opdata) {
    if (data == null) {
      return opdata;
    }
    return data;
  }

  //fetch data from api
  Future<List<Book>> _getUsers() async {
    //use this site to generate json data
    //http://www.json-generator.com
    print(this.search + search);
    var url = "https://www.googleapis.com/books/v1/volumes?q=" + this.search;
    var data = await http.get(url);

    //convert response to json Object
    var jsonData = json.decode(data.body);

    //Store data in User list from JsonData
    List<Book> books = [];
    for (var item in jsonData["items"]) {
      Book book = new Book(
          item["volumeInfo"]["title"],
          item["volumeInfo"]["subtitle"],
          item["volumeInfo"]["imageLinks"]["thumbnail"],
          item["volumeInfo"]["authors"][0],
          item["volumeInfo"]["publishedDate"]);

      //add data to user object
      books.add(book);
    }
    //return user list
    return books;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title
        ),

        //Search Button
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showDialog(
                    context: context,
                    // ignore: non_constant_identifier_names
                    builder: (BuildContext,) {
                      return SingleChildScrollView(
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          title: Text("Search for a Book"),
                          content: TextField(
                            controller: controller,
                            decoration: new InputDecoration(
                                hintText: 'Enter book title here',
                                border: InputBorder.none
                            ),
                            onChanged: (String userInput) {
                              uP = userInput;
                              print(userInput);
                            },
                          ),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    setState(() {

                                      if (uP != "") {
                                        this.search = uP;
                                      } else {
                                        this.search = "Dad";
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  },
                              child:Text("Search")),
                            ]
                        ),
                      );
                    });
              }),
        ],
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: FutureBuilder(
                    future: _getUsers(),
                    // ignore: missing_return
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemExtent: 190.0,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return new Card(
                              child: new Container(
                                padding: EdgeInsets.all(8.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new CircleAvatar(
                                          child: Image.network(
                                              snapshot.data[index].thumbnail),
                                          maxRadius: 50,
                                        ),

                                      new Padding(
                                            padding: EdgeInsets.only(right: 8.0)),
                                      new Text(
                                        //child: new Text(
                                          snapshot.data[index].title +
                                              "\n" +
                                              snapshot.data[index].author +
                                              "\n" +
                                              snapshot.data[index].publishedDate,
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                    ],
                                  ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.data == null &&
                          snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                              width: 160,
                              height: 150,
                              child: Column(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      'Loading Book List...',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                              )),
                        );
                      } else if (snapshot.data == null &&
                          snapshot.connectionState == ConnectionState.none) {
                        return Center(
                          child: Container(
                              width: 160,
                              height: 150,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                        'No Results found',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      } else if (snapshot.data == null) {
                        return Center(
                          child: Container(
                              width: 160,
                              height: 150,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      'No Results found',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      }
                    },
                  ),

                ),
              ),
            ],
          ),
        ),

    );
  }
}

// on tap to show user details
class BookDetails extends StatelessWidget {
  final Book book;
  BookDetails(this.book);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Search"),
      ),
      body: Container(
        child: Card(
          child: Column(
            children: [
              Text("Title: " + book.title),
              Text("Subtitle: " + book.subtitle),
              Text("Thumbnail: " + book.thumbnail),
              Text("Author: " + book.author),
              Text("Published Date: " + book.publishedDate),
            ],
          ),
        ),
      ),
    );
  }
}

//Book Class
class Book {
  final String title;
  final String subtitle;
  final String thumbnail;
  final String author;
  final String publishedDate;

//Constructor to intitilize
  Book(this.title, this.subtitle, this.thumbnail, this.author,
      this.publishedDate);

  static void add(Book book) {}
}
