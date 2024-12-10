import 'dart:convert';

import 'package:movienightapp/utils/app_state.dart';
import 'package:movienightapp/utils/http_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  int pageNumber = 0;
  bool dataStored = false;
  List<Map<String, dynamic>> movieList = [];
  int currentMovieIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchMovies(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Movie Selection',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: dataStored
              ? movieList.isEmpty
                  ? Center(child: Text("No movies available"))
                  : Dismissible(
                      key: ValueKey(movieList[currentMovieIndex]["id"]),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Icon(Icons.thumb_up),
                                duration: Duration(seconds: 1)),
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              currentMovieIndex++;
                            });
                          });
                        }
                        if (direction == DismissDirection.endToStart) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Icon(Icons.thumb_down),
                                duration: Duration(seconds: 1)),
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              currentMovieIndex++;
                            });
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(40.0),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 208, 232, 255),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: Offset(0, 4))
                            ]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            movieList[currentMovieIndex]["poster_path"] !=
                                        null &&
                                    movieList[currentMovieIndex]
                                            ["poster_path"] !=
                                        ""
                                ? Image.network(
                                    "https://image.tmdb.org/t/p/w185${movieList[currentMovieIndex]["poster_path"]}",
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/noPoster.png",
                                    fit: BoxFit.cover,
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(movieList[currentMovieIndex]["title"],
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "release date: ${movieList[currentMovieIndex]["release_date"]}",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              "rating: ${movieList[currentMovieIndex]["vote_average"]} / 10",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )
              : Center(
                  child:
                      CircularProgressIndicator()), // Show progress indicator while loading
        ));
  }

  Future<void> _fetchMovies(int pageNumber) async {
    pageNumber++;

    final response = await HttpHelper.fetchMovies(pageNumber);

    if (response["success"] == true) {
      movieList = (response["body"]["results"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      setState(() {
        dataStored = true;
      });
    } else {
      showAlert(context, "Error", "Something went wrong. Please try again.");
    }
  }
}

void showAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
