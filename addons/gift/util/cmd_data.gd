extends Reference
class_name CommandData

var func_ref : FuncRef
var permission_level : int
var max_args : int
var min_args : int
var where : int
var alias : bool

func _init(f_ref : FuncRef, perm_lvl : int, mx_args : int, mn_args : int, whr : int,_alias=true):
	func_ref = f_ref
	permission_level = perm_lvl
	max_args = mx_args
	min_args = mn_args
	where = whr
	alias = _alias
