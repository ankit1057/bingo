import 'package:flutter/material.dart';
import 'package:screen/screen.dart';

import '../bloc/bloc.dart';
import '../widgets/bingo_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/share_game_button.dart';
import '../widgets/vote.dart';

class PlayGameScreen extends StatefulWidget {
  @override
  _PlayGameScreenState createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen> {
  String _wordToVoteFor;

  void initState() {
    super.initState();
    Screen.keepOn(true);
  }

  void dispose() {
    super.dispose();
    Screen.keepOn(false);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Bloc.of(context).leaveGame();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GradientBackground(),
            AppBar(
              backgroundColor: Colors.transparent,
              actions: <Widget>[ShareGameButton()],
            ),
            SafeArea(
              child: Center(
                child: StreamBuilder<BingoField>(
                  stream: Bloc.of(context).fieldStream,
                  builder: _buildField,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, AsyncSnapshot<BingoField> snapshot) {
    // If there is no field yet, just display a loading spinner.
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    var wordsToVoteFor = Bloc.of(context).wordsToVoteFor;
    var wordToVoteForAvailable = wordsToVoteFor.isNotEmpty;
    if (wordToVoteForAvailable) {
      _wordToVoteFor = wordsToVoteFor.first;
    }

    return Stack(
      children: <Widget>[
        Center(
          child: BingoFieldView(
            field: snapshot.data,
            onTilePressed: (tile) async {
              await Bloc.of(context).proposeMarking(tile.word);
            },
          ),
        ),
        VoteWidget(
          word: _wordToVoteFor ?? '',
          onAccepted: () => Bloc.of(context).voteFor(_wordToVoteFor),
          onRejected: () => Bloc.of(context).voteAgainst(_wordToVoteFor),
          isVisible: wordToVoteForAvailable,
        ),
      ],
    );
  }
}
