class_name Playlist
extends RefCounted
## Çalma listesi (saf): parça yolları ve geçerli sıra. Sonraki/önceki döngüseldir.

var tracks: PackedStringArray = []
## Geçerli parçanın sırası; liste boşsa -1.
var index: int = -1


## Listeyi değiştirir. keep_path listede varsa o parça geçerli kalır, yoksa ilk parçaya geçilir.
func set_tracks(new_tracks: PackedStringArray, keep_path: String = "") -> void:
	tracks = new_tracks
	if tracks.is_empty():
		index = -1
	elif keep_path != "" and tracks.has(keep_path):
		index = tracks.find(keep_path)
	else:
		index = 0


func is_empty() -> bool:
	return tracks.is_empty()


func size() -> int:
	return tracks.size()


## Geçerli parçanın yolu; liste boşsa "".
func current() -> String:
	return "" if index < 0 else tracks[index]


func next() -> String:
	if not is_empty():
		index = (index + 1) % tracks.size()
	return current()


func previous() -> String:
	if not is_empty():
		index = posmod(index - 1, tracks.size())
	return current()


## "2/5" gibi; liste boşsa "".
func position_text() -> String:
	return "" if is_empty() else "%d/%d" % [index + 1, tracks.size()]
