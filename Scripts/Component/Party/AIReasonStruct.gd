class_name CPUReason
extends Resource
#enum Key {
#	STAR_CHANGE = 1.0,
#	STAR_ITEM = 1.0,
#	COIN_CHANGE = 0.8,
#	COIN_ITEM = 0.8,
#	ROLL_CHANGE = 0.6,
#	ROLL_ITEM = 0.6,
#	LEAD_PRESERVATION = 0.5,
#	LEAD_PRESERVATION_ITEM = 0.5,
#	PLACEMENT_SHAKEUP = 0.4,
#	PLACEMENT_SHAKEUP_ITEM = 0.4,
#	GIMMICK = 0.3,
#	GIMMICK_ITEM = 0.3,
#	TELEPORT = 0.2,
#	TELEPORT_ITEM = 0.2,
#	WILL_REJECT = 0.1,
#}
#
###chance that the event will revert or change state
#@export var things_that_can_happen :Array[ValueChance] = []
#	# Calculate the importance of the space		# Assign weights to different parameters
#var w_weights = {
#			"star_change": 1.0,
#			"star_item": 1.0,
#			"coin_change": 0.8,
#			"coin_item": 0.8,
#			"roll_change": 0.6,
#			"roll_item": 0.6,
#			"lead_preservation": 0.5,
#			"lead_preservation_item": 0.5,
#			"placement_shakeup": 0.4,
#			"placement_shakeup_item": 0.4,
#			"gimmick": 0.3,
#			"gimmick_item": 0.3,
#			"teleport": 0.2,
#			"teleport_item": 0.2,
#			"will_reject": 0.1
#		}
#
#func calculate_importance(weights:Dictionary) -> float:
#		var importance = 0.0
#
#
#		# Calculate the importance based on the weights
#		for key in map.keys():
#			var param = map[key]
#			importance += calculate_parameter_importance(param, weights)
#
#		return importance
#
#	# Calculate the importance of a specific parameter
#func calculate_parameter_importance(parameter: Array[ValueChance], weights: Dictionary) -> float:
#		var parameter_importance = 0.0
#		for value_chance in parameter:
#			# Consider the chance of the event happening
#			parameter_importance += value_chance.chance * weight
#
#			# Consider the value change if applicable
#			if value_chance.value != 0:
#				parameter_importance += abs(value_chance.value) * weight
#
#		# Multiply the parameter importance by its weight
#		parameter_importance *= weight
#
#		return parameter_importance
