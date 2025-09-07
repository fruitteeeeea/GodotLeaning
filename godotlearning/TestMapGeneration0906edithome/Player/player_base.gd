extends CharacterBody2D
class_name Player

signal PlayerControlChange(state : bool)

var buffer_control := false
var can_control := true #TODO 玩家状态修改的时候发出信号 
