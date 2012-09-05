# A location in the maze
class Node
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
  DIRECTIONS = [[-1, 0], [1, 0], [0, 1], [0, -1]]

  # Maze as string
  constructor: (@maze) ->
    @rows = @maze.split('\n')
    @end = @location('F')

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

  # Return the traversal route through the maze
  route: (node, route=[]) ->
    # Return the route from the node to the ultimate ancestor
    route.unshift(node.location)
    if node.parent
      @route(node.parent, route)
    else
      route

  # Return the location of the given char in the maze.
  location: (char) ->
     for row, rownum in @rows
       for col, colnum in row
         if col == char
           return [rownum, colnum]
     return null

   # Return a character in the maze at the given location
   content: (location) ->
     @rows[location[0]][location[1]]


# Make available to other files 
@astar = {MazeSolver}
