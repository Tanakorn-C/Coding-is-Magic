extends Node2D

signal next_attack
signal turn_changed(turn_number:int)   # ถูกยิงเมื่อขึ้นเทิร์นใหม่
signal queue_updated(order:Array)      # ส่งลิสต์คิวเรียงจากเร็วไปช้าปัจจุบันให้ UI อัปเดต
