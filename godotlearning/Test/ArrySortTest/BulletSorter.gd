extends Node
class_name BulletSorter

const TYPE_ORDER = {
	"normal": 0,
	"summon": 1,
	"element": 2
}

# 元素优先级
const ELEMENT_ORDER = {
	"physics": 0,
	"fire": 1,
	"ice": 2
}



# ========== 分类排序入口 ========== #
# mode 决定排序方式
# 可选: "type", "rarity", "element", "combined"
static func sort_bullets(bullets: Array[TestSortData], mode: String) -> void:
	match mode:
		"type":
			bullets.sort_custom(func(a, b):
				return TYPE_ORDER.get(a.bullet_type, 999) < TYPE_ORDER.get(b.bullet_type, 999)
			)
		
		"rarity":
			bullets.sort_custom(func(a, b):
				return a.rarity > b.rarity # 稀有度高的排前面
			)
		
		"element":
			bullets.sort_custom(func(a, b):
				return ELEMENT_ORDER.get(a.element_type, 999) < ELEMENT_ORDER.get(b.element_type, 999)
			)
		
		"combined":
			bullets.sort_custom(func(a, b):
				# 1️⃣ 按类型
				var atype = TYPE_ORDER.get(a.bullet_type, 999)
				var btype = TYPE_ORDER.get(b.bullet_type, 999)
				if atype != btype:
					return atype < btype
				
				# 2️⃣ 如果是元素子弹，再按元素
				if a.bullet_type == "element" and b.bullet_type == "element":
					var aele = ELEMENT_ORDER.get(a.element_type, 999)
					var bele = ELEMENT_ORDER.get(b.element_type, 999)
					if aele != bele:
						return aele < bele
				
				# 3️⃣ 最后按稀有度（降序）
				return a.rarity > b.rarity
			)
		
		_:
			push_warning("Unknown sort mode: %s" % mode)

#整理子弹 #依据类型排序
static func sort_bullets02(bullets: Array[BulletData], mode: String) -> void:
	match mode:
		"type": #依据类型排序
			pass
