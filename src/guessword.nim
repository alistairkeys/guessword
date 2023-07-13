import boxy, opengl, staticglfw
import guesswordgame
import std/strutils

var
  game = initGame()

proc handleKeyPress(window: Window, key, scancode, action,
    modifiers: cint) {.cdecl.} =
  if action == PRESS:
    if game.state != inProgress:
      echo "Starting new game"
      game = initGame()
    elif key in {KEY_A .. KEY_Z, KEY_BACKSPACE, KEY_DELETE, KEY_ENTER, KEY_ESCAPE}:
      echo "Pressed a key: ", key
      case key
        of KEY_ESCAPE: window.setWindowShouldClose(1.cint)
        of KEY_A..KEY_Z: game.addLetter(chr(key))
        of KEY_BACKSPACE, KEY_DELETE: game.deleteLetter
        of KEY_ENTER: game.guess
        else: discard

proc doGame() =
  let windowSize = ivec2(800, 400)

  if init() == 0:
    quit("Failed to Initialize GLFW.")

  windowHint(RESIZABLE, false.cint)
  windowHint(CONTEXT_VERSION_MAJOR, 4)
  windowHint(CONTEXT_VERSION_MINOR, 1)

  let window = createWindow(windowSize.x, windowSize.y, "Guess the Word", nil, nil)
  makeContextCurrent(window)

  loadExtensions()

  discard window.setKeyCallback(handleKeyPress)

  var
    bxy = newBoxy()
    frame: int

  const
    margin = 10

  proc generateLetters(bxy: Boxy) =
    var
      typeface = readTypeface("data/IBMPlexMono-Bold.ttf")
      font = newFont(typeface)
    font.size = 28
    font.paint = "#000000"
    for ch in {'A'..'Z', 'a'..'z', '0'..'9', '!', ',', '='}:
      let arrangement = typeset(@[newSpan($ch, font)], bounds = vec2(32, 32))
      let textImage = newImage(32, 32)
      textImage.fillText(arrangement)
      bxy.addImage("text" & $ch, textImage)

  bxy.addImage("bg", readImage("data/bg.png"))
  bxy.generateLetters()

  proc drawBoxes(text: WordGuess, origin: Vec2, pad: bool = true) =
    var pos = origin
    let textToDraw =
      if pad: alignLeft(text.word, game.wordToGuess.len)
      else: text.word
    const colours: array[LetterGuess, Color] = [
      Color(r: 1, g: 0, b: 0, a: 1),                 # wrong
      Color(r: 1, g: 1, b: 0.5, a: 1),               # notincorrectplace
      Color(r: 0, g: 1, b: 0, a: 1),                 # correct
      Color(r: 0.8, g: 0.8, b: 0.8, a: 1),           # neutral
    ]
    for idx, ch in textToDraw:
      bxy.drawRect(rect = rect(pos, vec2(32, 32)),
                   color = colours[text.correctness[idx]])
      if ch != ' ':
        bxy.drawImage("text" & $ch, rect = rect(vec2(pos.x + 6, pos.y - 2),
            vec2(32, 32)))
      pos.x += 32 + margin

  proc drawNormalText(text: string, origin: Vec2) =
    var pos = origin
    for ch in text:
      if ch != ' ':
        bxy.drawImage("text" & $ch, rect = rect(pos, vec2(32, 32)))
      pos.x += 16

  proc display() =
    bxy.beginFrame(windowSize)
    bxy.drawImage("bg", rect = rect(vec2(0, 0), windowSize.vec2))

    let startX = 32'f32
    var textPos = vec2(startX, 32'f32)

    for el in game.yourGuesses:
      textPos.x = startX
      drawBoxes(el, textPos)
      textPos.y += 32 + margin

    const helpTextLeft = 250

    var y = 24'f32
    case game.state
      of inProgress:
        drawBoxes(game.currentGuess, textPos)
        drawNormalText("Type your word using the keyboard", vec2(helpTextLeft, y))
        y += 32
        drawNormalText("Press Enter to guess", vec2(helpTextLeft, y))
        y += 64
        drawBoxes(WordGuess(word: " ", correctness: @[totallyWrong]), vec2(
            helpTextLeft + 32, y), false)
        drawNormalText(" = Totally wrong", vec2(helpTextLeft + 64, y))
        y += 40
        drawBoxes(WordGuess(word: " ", correctness: @[notInCorrectPlace]), vec2(
            helpTextLeft + 32, y), false)
        drawNormalText(" = Right letter, wrong place", vec2(helpTextLeft + 64, y))
        y += 40
        drawBoxes(WordGuess(word: " ", correctness: @[correct]), vec2(
            helpTextLeft + 32, y), false)
        drawNormalText(" = Correct", vec2(helpTextLeft + 64, y))
      of won:
        drawNormalText("Congratulations! You win", vec2(helpTextLeft, y))
        y += 64
        drawNormalText("Press any key to play again", vec2(helpTextLeft, y))
      of lost:
        drawNormalText("Sorry, you took too many guesses", vec2(helpTextLeft, y))
        y += 32
        drawNormalText("The word was " & game.wordToGuess, vec2(helpTextLeft, y))
        y += 64
        drawNormalText("Press any key to play again", vec2(helpTextLeft, y))

    bxy.endFrame()
    window.swapBuffers()
    inc frame

  while windowShouldClose(window) != 1:
    display()
    waitEvents()

when isMainModule:
  doGame()
