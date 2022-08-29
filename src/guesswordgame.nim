import std/[parsecfg, strutils, setutils, sugar]

type
  GameState* = enum
    inProgress, won, lost

  LetterGuess* = enum
    totallyWrong, notInCorrectPlace, correct, neutral

  WordGuess* = object
    word*: string
    correctness*: seq[LetterGuess]

  Game* = object
    wordToGuess*: string
    yourGuesses: seq[string]
    currentGuess: string
    maximumGuessesPerGame: int
    state*: GameState

proc getNthWord(nthWordIdx: int): tuple[word: string, nextIdx: int] =
  var idx = 1
  var firstLine = ""

  for line in "data/words.txt".lines:
    if firstLine == "": firstLine = line
    var thisLine = line
    if idx == nthWordIdx:
      return (thisLine.toUpperAscii, idx + 1)
    inc idx

  let blah = if firstLine.len == 0: "CRASH" else: firstLine.toUpperAscii
  return (blah, 2)

proc initGame*(): Game =
  const
    configFile = "data/config.ini"
    gameSection = "game"
    maximumGuessesKey = "maxguesses"
    nextWordKey = "nextword"

  var cfg = loadConfig(configFile)
  let nextWordIdx = parseInt(cfg.getSectionValue(gameSection, nextwordKey, "1"))
  let maxGuesses = parseInt(cfg.getSectionValue(gameSection, maximumGuessesKey, "6"))
  let nextWord = getNthWord(nextWordIdx)
  echo "NEXT WORD: ", nextWord

  cfg.setSectionKey(gameSection, nextWordKey, $nextWord.nextIdx)
  cfg.writeConfig(configFile)

  Game(
    wordToGuess: nextWord.word,
    yourGuesses: @[],
    currentGuess: "",
    maximumGuessesPerGame: maxGuesses,
    state: inProgress
  )

proc yourGuesses*(game: Game): seq[WordGuess] =
  var letters = game.wordToGuess.toSet
  for guess in game.yourGuesses:
    result.add WordGuess(word: guess, correctness: @[])
    for idx, ch in guess:
      let value =
        if ch notin letters: totallyWrong
        elif ch == game.wordToGuess[idx]: correct
        else: notInCorrectPlace
      result[^1].correctness.add value

proc currentGuess*(game: Game): WordGuess =
  var correctness = collect:
    for _ in 0 ..< game.wordToGuess.len:
      neutral
  WordGuess(word: game.currentGuess, correctness: correctness)

proc guess*(game: var Game) =

  if game.state != inProgress:
    return

  let yourGuess = game.currentGuess.toUpperAscii
  if yourGuess.len == game.wordToGuess.len:
    echo "Adding guess: ", yourGuess
    game.yourGuesses.add yourGuess
    if yourGuess == game.wordToGuess:
      echo "Congratulations - you guessed the word!"
      game.state = won
    elif game.yourGuesses.len == game.maximumGuessesPerGame:
      echo "Sorry, you took too many guesses!"
      game.state = lost
    else:
      game.currentGuess = ""

proc addLetter*(game: var Game, letter: char) {.inline.} =
  if game.currentGuess.len < game.wordToGuess.len:
    game.currentGuess &= letter

proc deleteLetter*(game: var Game) {.inline.} =
  if game.currentGuess.len > 0:
    game.currentGuess.setLen(game.currentGuess.len - 1)
