# A-Star maze solver.
#
# The A-Star algorithm uses the following concepts to find the best path from
# start to finish:
#
#  1. The cost function commonly referred to as g(). In the case of this maze
#     solver, for any given point in a path, the number of steps taken to get
#     to that point.
#
#  2. The heuristic function commonly referred to as h(). In the case of this
#     maze solver, the best number of steps "as the crow flies" from a given
#     point to the end point.

# A location in the maze
class Node
  # location - the x, y coords of this node
  # parent   - the x, y coords of the previous node in the path
  # g        - the number of steps in the path from the start to this node
  # end      - the location of the node we're trying to get to
  constructor: (@location, @parent, @g, end) ->
    @h = Math.abs(end[0] - location[0]) + Math.abs(end[1] - location[1])
    @f = @g + @h

# A collection of nodes which can be manipulated and searched.
class NodeSet
  constructor: ->
    @nodes = []

  add: (node) ->
    @nodes.push node

  removeFirst: ->
    @nodes.shift()

  remove: (node) ->
    index = @nodes.indexOf node
    if index != -1
      @nodes.splice index, 1

  # Find a single node in this set of nodes with the given location
  find: (location) ->
    for node in @nodes
      if node.location[0] == location[0] and node.location[1] == location[1]
        return node
    return null

  # Sort by nodes' f values
  sort: ->
    @nodes.sort (node1, node2) -> node1.f - node2.f

# Solves the maze
class MazeSolver
  # The set of valid directions the path can take.
  # In this maze, up, down, left and right are valid.
  DIRECTIONS = [[-1, 0], [1, 0], [0, 1], [0, -1]]

  # Maze as string using the following characters:
  #
  # @ - start point.
  # F - finish point.
  # * - a point which cannot be traversed e.g. part of a wall.
  # 
  # For example:
  #
  # '''*******************
  #    *        *        *
  #    *        *  **    *
  #    *        *  *F    *
  #    *    *** *  *******
  #    *    * @ *        *
  #    *    ********     *
  #    *    *     *      *
  #    *  * *  *  *      *
  #    *  ***  *  ****   *
  #    *       *     *   *
  #    *       *         *
  #    *******************'''
  constructor: (@maze) ->
    @rows = @maze.split('\n')
    @end = @location('F')

  # Solve the maze and return the route of the best path from start to finish.
  solve: ->
    start = @location('@')
    closedSet = new NodeSet
    openSet = new NodeSet

    current = new Node start, null, 0, @end

    while current.location[0] != @end[0] or current.location[1] != @end[1]
      for [row, col] in DIRECTIONS
        child = new Node [current.location[0] + row, current.location[1] + col], current, current.g + 1, @end
        if @content(child.location) == '*'
          continue

        if child not in closedSet
          existingNode = openSet.find child.location
          if existingNode
            if existingNode.g > child.g
              openSet.remove existingNode
              openSet.add child
          else
            openSet.add child

      openSet.sort()
      current = openSet.removeFirst()
      closedSet.add current

    @route current

  # Return the traversal route through the maze for a given point in the path.
  route: (node, route=[]) ->
    # Return the route from the node to the ultimate ancestor
    route.unshift(node.location)
    if node.parent
      @route(node.parent, route)
    else
      route

  # Return the location of the given character in the maze string.
  location: (char) ->
     for row, rownum in @rows
       for col, colnum in row
         if col == char
           return [rownum, colnum]
     return null

   # Return the character in the maze string at the given location
   content: (location) ->
     @rows[location[0]][location[1]]


# Make available to other files 
@astar = {MazeSolver}
