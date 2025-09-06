#*
#* in_range.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTCondition
## InRange condition checks if the agent is within a range of target,
## defined by [member distance_min] and [member distance_max]. [br]
## Returns [code]SUCCESS[/code] if the agent is within the given range;
## otherwise, returns [code]FAILURE[/code].

## Blackboard variable that holds the target (expecting Node2D).
@export var target_var: StringName = &"target"

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "IsTargetValid " + LimboUtility.decorate_var(target_var)


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if not is_instance_valid(blackboard.get_var(target_var, null)):
		return FAILURE

	return SUCCESS
