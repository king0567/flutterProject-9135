import 'package:movienightapp/utils/http_helper.dart';
import 'package:movienightapp/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  late String sessionId;
  int pageNumber = 0;
  bool dataStored = false;
  List<Map<String, dynamic>> movieList = [];
  int currentMovieIndex = 0;
  int pageNumberIncrement = 19;

  @override
  void initState() {
    super.initState();
    _getSessionId();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Movie Selection',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: dataStored
              ? movieList.isEmpty
                  ? const Center(child: Text("No movies available"))
                  : Dismissible(
                      background: const Icon(
                        Icons.thumb_up,
                        size: 100.0,
                      ),
                      secondaryBackground: const Icon(
                        Icons.thumb_down,
                        size: 100.0,
                      ),
                      key: ValueKey(movieList[currentMovieIndex]["id"]),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          voteMovie(movieList[currentMovieIndex]["id"], true);
                        }
                        if (direction == DismissDirection.endToStart) {
                          voteMovie(movieList[currentMovieIndex]["id"], false);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          padding: const EdgeInsets.all(50.0),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 208, 232, 255),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 4))
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
                              const SizedBox(
                                height: 10,
                              ),
                              Text(movieList[currentMovieIndex]["title"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "release date: ${movieList[currentMovieIndex]["release_date"]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                "rating: ${movieList[currentMovieIndex]["vote_average"]} / 10",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
              : const Center(
                  child:
                      CircularProgressIndicator()), // Show progress indicator while loading
        ));
  }

  Future<void> _getSessionId() async {
    final preferences = await SharedPreferences.getInstance();

    setState(() {
      sessionId = preferences.getString("sessionId") ?? "";
    });
  }

  Future<void> _fetchMovies() async {
    pageNumber++;

    final response = await HttpHelper.fetchMovies(pageNumber);

    if (response["success"] == true) {
      setState(() {
        movieList.addAll(
          (response["body"]["results"] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
        dataStored = true;
      });
    } else {
      if (mounted) {
        showErrorAlert(
            context, "Error", "Something went wrong. Please try again.");
      }
    }
  }

  Future<void> voteMovie(int movieId, bool vote) async {
    final response = await HttpHelper.voteMovie(sessionId, movieId, vote);
    if (response["success"] == true) {
      if (response["body"]["data"]["match"] == false) {
        if (currentMovieIndex == pageNumberIncrement) {
          await _fetchMovies();
          setState(() {
            currentMovieIndex++;
          });
          pageNumberIncrement = pageNumberIncrement + 20;
        } else {
          setState(() {
            currentMovieIndex++;
          });
        }
      } else {
        Map winningMovie = movieList.firstWhere((movie) =>
            movie["id"].toString() ==
            response["body"]["data"]["movie_id"].toString());
        String title = winningMovie["title"];
        String posterPath = "";
        if (winningMovie["poster_path"] != null &&
            winningMovie["poster_path"] != "") {
          posterPath =
              "https://image.tmdb.org/t/p/w342${winningMovie["poster_path"]}";
        }

        if (mounted) {
          showWinnerAlert(context, title, posterPath);
        }
      }
    } else {
      if (mounted) {
        showErrorAlert(
            context, "Error", "Something went wrong. Please try again.");
      }
    }
  }
}

void showErrorAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()));
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

void showWinnerAlert(BuildContext context, String title, String posterPath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "We Have a Winner!",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            posterPath == ""
                ? Image.asset(
                    "assets/noPoster.png",
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    posterPath,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(
              height: 10,
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 12.0, fontWeight: FontWeight.bold))
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()));
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
