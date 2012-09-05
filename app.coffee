paper = Raphael("maze", "768", "75%")

CLIENT_WIDTH = paper.canvas.clientWidth
MAZE_WIDTH = 19
SCALE = CLIENT_WIDTH / MAZE_WIDTH

DEFAULT_MAZE = '''*******************
                  *        *        *
                  *        *  **    *
                  *        *  *F    *
                  *    *** *  *******
                  *    * @ *        *
                  *    ********     *
                  *    *     *      *
                  *  * *  *  *      *
                  *  ***  *  ****   *
                  *       *     *   *
                  *       *         *
                  *******************'''


# Circle drawn in maze
class Circle
  # Mapping of type char to html colour
  COLOURS =
    '*': '#900'
    '@': '#ff0'
    'F': '#00f'
    'S': '#ffa500'
    '#': '#990'

  # Circle radius in pixels
  RADIUS = CLIENT_WIDTH / MAZE_WIDTH / 2 - 2

  constructor: (row, col, type) ->
    [x, y] = @coords row, col
    @circle = paper.circle(x, y, RADIUS).attr
      "fill": COLOURS[type]
      "stroke": "#aaa"
      "stroke-width": "2"

  # Move the circle with animation
  move: (row, col) ->
    @circle.toFront()
    @circle.animate {r: RADIUS * 2, opacity: .25}, 100, "<>", => @circle.animate {r: RADIUS, opacity: 1}, 250, "<>"
    [x, y] = @coords row, col
    @circle.attr("cx", x).attr("cy", y)

  # Convert maze row, col to canvas x, y.
  coords: (row, col) ->
    [col * SCALE + SCALE / 2, row * SCALE + SCALE / 2]


# Representation of maze
class Maze
  constructor: (@maze) ->
    @route = solveMaze maze
    @trails = []
    [row, col] = @route[0]
    @bot = new Circle row, col, "@"
    @initMaze()
    @initRoute()

  initMaze: ->
    rows = @maze.split('\n')
    for row, rownum in rows
      for col, colnum in row
        if col not in [' ', '@']
          new Circle rownum, colnum, col

  initRoute: =>
    for node in @trails
      node.circle.remove()
    @trails.length = 0
    @routeIndex = 0

    [row, col] = @route[0]
    @bot.move row, col
    @trails.push new Circle row, col, "S"

  changeStart: (event) =>
    [row, col] = @toMazeCoords event.x, event.y
    maze = @maze.replace("@", " ")
    rows = maze.split('\n')
    rows[row] = rows[row][...col] + '@' + rows[row][col + 1..]
    maze = rows.join '\n'
    @route = solveMaze maze
    @initRoute()

  updateIndex: (step) ->
    @routeIndex += step
    if @routeIndex < 0
      @routeIndex = 0
      return false
        
    if @routeIndex > @route.length - 1
      @routeIndex = @route.length - 1
      return false

    return true

  previous: =>
    if not @updateIndex(-1)
      return

    [row, col] = @route[@routeIndex]
    @trails.pop().circle.remove()
    @bot.move row, col

  next: =>
    if not @updateIndex(1)
      return

    [row, col] = @route[@routeIndex]
    @trails.push(new Circle row, col, "#")
    @bot.move row, col

  # Convert maze row, col to canvas x, y.
  toMazeCoords: (x, y) ->
    x -= paper.canvas.offsetLeft
    y -= paper.canvas.offsetTop
    [Math.round((y - SCALE / 2) / SCALE), Math.round((x - SCALE / 2) / SCALE)]


solveMaze = (maze) ->
  solver = new @astar.MazeSolver maze
  return solver.solve()


$ ->
  m = new Maze DEFAULT_MAZE
  $("#next").on "click", m.next
  $("#previous").on "click", m.previous
  $("#restart").on "click", m.initRoute
  paper.canvas.onclick = m.changeStart
