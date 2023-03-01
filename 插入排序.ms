arr_list = for i in 1 to 10 collect (random 10 100)
--²åÈëÅÅĞòº¯Êı
function insert_sort arr=(
	for index in 1 to arr.count do(
		key = arr[index]
		current_index = index
		while current_index > 1 and key < arr[current_index - 1] do(
			arr[current_index] = arr[current_index - 1]
			current_index -= 1
		)
		arr[current_index] = key			
	)
	return arr
)
insert_sort arr_list
clearListener()
print arr_list #noMap