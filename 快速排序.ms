arr_list=#(13, 86, 94, 76, 32, 42, 23, 20, 37, 51, 94, 62, 90, 65, 80, 39, 89, 65, 85, 80)
--基本的插入排序
function insert_sort arr low high=(
 	for i =low + 1 to high do(
 		key = arr[j = i]
 		while j > low and arr[j - 1] > key do(
 			arr[j] = arr[j - 1]
			j -= 1		
 		)
 		arr[j] = key		
 	)	
)
--取待排序序列中low、mid、high三个位置，选中间数据作为枢轴
--		arr[mid] <= arr[low] <= arr[high]
--		low 位置上保存这三个位置的中间值
--		分割时可以直接使用 low 位置的元素作为枢轴
function select_pivot_of_three arr low high = (
	mid = low + (high - low) / 2
	if arr[mid] > arr[high]	do	swap arr[mid] arr[high]
	if arr[low] > arr[high] do	swap arr[low] arr[high]
	if arr[mid] > arr[low]	do	swap arr[mid] arr[low]
	return arr[low]	
)
function partition arr low high = (
	key = select_pivot_of_three arr low high
    while low < high do(
        while (low < high and arr[high] >= key) do high -= 1            
        arr[low] = arr[high]
        while high > low and arr[low] < key do low += 1
        arr[high] = arr[low]
	)
	arr[low] = key
    return low
)
--标准的快速排序函数
function quick_sort arr low high = (
	--数组分区较小时，采用插入排序
    if (high - low <= 10) then(
        insert_sort arr low high
        return arr
	)else(
		pivotPos = partition arr low high
		quick_sort arr low (pivotPos-1)
		quick_sort arr (pivotPos+1) high
		return arr
	)
)
/*
----改进的快速排序函数，采用一次尾部递归，降低递归深度
function quick_sort arr low high = (
	--数组分区较小时，采用插入排序
    if (high - low <= 10) then(
        insert_sort arr low high
        return arr
	)else(
		while low < high do(
			pivotPos = partition arr low high
			quick_sort arr low (pivotPos - 1)
			low = pivotPos + 1
		)
		return arr
	)
)
*/
quick_sort arr_list 1 arr_list.count
print arr_list #noMap