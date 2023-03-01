function heapify arr index end = (
	-- 调整为大顶堆
	left = index + index
	right = left + 1
	while left <= end do(  --当前节点为非叶子结点
		max_index = index
		if arr[left] > arr[max_index] do
			max_index = left
		if right <= end and arr[right] > arr[max_index] do
			max_index = right
		--如果不用交换，则说明已经交换结束
		if index == max_index do exit  --return OK
			swap arr[index] arr[max_index]
		-- 继续调整子树
		index = max_index
		left = index + index
		right = left + 1
	)
)
function max_heap_sort arr = (
	end = arr.count
	-- end / 2 是最后一个非叶节点，叶节点不用调整
	-- 生成大顶堆，从最下层的非叶节点开始
	for i = end/2 to 1 by -1 do
		heapify arr i end
	--排序
	for i = end to 2 by -1 do(
		swap arr[1] arr[i]
		heapify arr 1 (i - 1)
	)
	return arr
)
arr_list = #(3, 2, 5, 2, 4, 2, 5, 10, 1, 0, -2)
max_heap_sort arr_list
msgbox arr_list