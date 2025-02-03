extends Resource
class_name CPUMGR
enum Difficulty {
	Chaos
}
#class PathfindingAlgorithm:
#	var startNode: Space
#	var endNode: Space
#	var importantNodes: Array
#	var paths: Array
#
#	func findPath() -> Array:
#		var queue: Array = []  # Nodes to visit
#		var visited: Array = []  # Visited nodes
#		var parent: Dictionary = {}  # Parent nodes (used to reconstruct the path)
#		var foundEnd: bool = false
#
#		queue.append(startNode)
#		visited.append(startNode)
#
#		while queue.size() > 0:
#			var currentNode: Node = queue.pop_front()
#
#			if currentNode == endNode:
#				foundEnd = true
#				paths.append(reconstructPath(parent))
#				break
#
#			for neighborNode_path in currentNode.next_space:
#				var neighborNode = currentNode.get_node(neighborNode_path)
#				if neighborNode not in visited:
#					queue.append(neighborNode)
#					parent[neighborNode] = currentNode
#					visited.append(neighborNode)
#
#		if not foundEnd:
#			for importantNode in importantNodes:
#				if importantNode in visited:
#					(findAlternativePath(parent.duplicate(),visited.duplicate(), importantNode))
#		else:
#			for importantNode in importantNodes:
#				if importantNode in visited:
#					(findAlternativePath(parent.duplicate(),visited.duplicate(), importantNode,true))
#		return paths
#
#	func reconstructPath(parent: Dictionary) -> Array:
#		var path: Array = []
#		var currentNode: Node = endNode
#
#		while currentNode != startNode:
#			path.insert(0, currentNode)
#			currentNode = parent[currentNode]
#
#		path.insert(0, startNode)
#		return path
#	func reconstructAltPath(parent: Dictionary, importantNode: Space,try_find_end:bool = false ) -> Array:
#		var path: Array = []
#
#		var currentNode: Node = endNode
#		if not try_find_end:
#			currentNode = importantNode
#		if try_find_end:
#			while currentNode != importantNode:
#				path.insert(0, currentNode)
#				currentNode = parent[currentNode]
#			path.insert(0, importantNode)
#			while currentNode != startNode:
#				path.insert(0, currentNode)
#				currentNode = parent[currentNode]
#		else:
#			while currentNode != startNode:
#				path.insert(0, currentNode)
#				currentNode = parent[currentNode]
#		path.insert(0, startNode)
#		return path
#
#	func findAlternativePath(parent: Dictionary, visited:Array, importantNode: Space,try_find_end:bool = false):
#		var queue: Array = []  # Nodes to visit
#		var foundEnd: bool = false
#
#		queue.append(importantNode)
#
#		while queue.size() > 0:
#			var currentNode: Node = queue.pop_front()
#			if try_find_end:
#				if currentNode == endNode:
#					foundEnd = true
#					paths.append(reconstructAltPath(parent,importantNode,try_find_end))
#					break
#			else:
#				if currentNode == importantNode:
#					foundEnd = true
#					paths.append(reconstructPath(parent))
#					if importantNodes.size() > 0:
#						for i_importantNode in importantNodes:
#								paths.append(reconstructAltPath(parent,importantNode,try_find_end))
#					break
#
#			for neighborNode_path in currentNode.next_space:
#				var neighborNode = currentNode.get_node(neighborNode_path)
#				if neighborNode not in visited:
#					queue.append(neighborNode)
#					parent[neighborNode] = currentNode
#					visited.append(neighborNode)
#
@export_storage var player:Player
func cpu_activate(activation_type: int, offending_player: Player = null, event: Event = null):
	
	if offending_player == player:
		if event is Space:
			pass
		elif event is CapsuleBase:
			pass
	elif offending_player != null:
		if event is Space:
			pass
		elif event is CapsuleBase:
			pass
	else:
		if event is Space:
			pass
		elif event is CapsuleBase:
			pass
	pass
var pressing = false
func cpu_press(action):
	if not Input.is_action_pressed(action) and not Input.is_action_just_released(action) and not pressing:
		pressing = true
		Input.action_press(action,1.0)
		Input.action_release(action)
		pressing = false
func cpu_tick(delta):
	if player.player_id == 4:
		return
	player.joystick_pos = player.joystick_pos.move_toward(Vector2.from_angle(randf_range(0,TAU)),0.25*delta).normalized()
	if player.travel.landed:
		player.capsule_mgr.throwPresent_mode = false
	if player.capsule_mgr.throwPresent_mode:
		var chance_success = randi_range(0,30)
		var success = randi_range(0,chance_success)
		if success <= 5:
			
			cpu_press(player.controls.player+player.controls.a)
		if success == 10:
			cpu_press(player.controls.player+player.controls.b)
	else:
		var chance_success = randi_range(0,30)
		var success = randi_range(0,chance_success)
		if success == 1:
			cpu_press(player.controls.player+player.controls.a)
		if success == 10:
			cpu_press(player.controls.player+player.controls.b)
		if success == 9:
			cpu_press(player.controls.player+player.controls.x)
		if success == 8:
			cpu_press(player.controls.player+player.controls.y)
		if success == 8:
			cpu_press(player.controls.player+player.controls.l)
func cpu_input():
	pass
