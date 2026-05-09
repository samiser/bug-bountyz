class_name Bounty
extends Resource

@export var program_name : String
@export var target_page : Page
@export var payout_min : int
@export var payout_max : int
@export_range(1, 5) var difficulty : int = 1
@export_multiline var scope : String
