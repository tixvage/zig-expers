class GameEngine {
  static update(elapsedTime) {
    System.print(elapsedTime)
  }
}

foreign class File {
  construct create(path) {}

  foreign write(text)
  foreign close()
}

class Math {
  foreign static add(a, b)
}

//System.print(Math.add(20,30))
//System.print("bruh")