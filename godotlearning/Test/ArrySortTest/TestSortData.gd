extends Resource
class_name TestSortData

@export_enum("normal", "summon", "element") var bullet_type : String = "normal"# "normal", "summon", "element"
@export_enum("physics", "fire", "ice") var element_type : String  = "physics"
@export_range(1, 4) var rarity : int = 1 # 稀有度，数字越大越稀有
