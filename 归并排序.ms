--arr_list = for i in 1 to 10 collect (random 10 100)
arr_list = #(39, 26, 66, 92, 41, 48, 63, 77, 15, 71)
--插入排序函数
function merge_array arr low mid high = (
	--arr[low~mid]，arr[mid+1~high] 是数组 arr 中的两个局部有序数组
	--把这个两个数组复制到临时数组，然后合并到原来的数组中
	tempArr1=#(); tempArr1[mid - low + 1] = undefined	--数组大小已知，直接生成指定大小的数组
 	tempArr2=#(); tempArr2[high - mid] = undefined		--数组大小已知，直接生成指定大小的数组
	--直接生成数组大小，就不需要使用append添加元素了，有利于提高运行速度
 	index = 0
	--将数组 arr[low~mid] 复制到 tempArr1 中
 	for i in low to mid do
 		tempArr1[index += 1] = arr[i]
 	index = 0
	--将数组 arr[low~mid] 复制到 tempArr1 中
 	for i in mid+1 to high do
 		tempArr2[index += 1] = arr[i]
	i = j = 1		--i, j 分别是两个临时数组的下标
	index = low		--原数组的下标
	--合并数组
	while i <= tempArr1.count and j <= tempArr2.count do(
		--两个数组比较，哪个小，就把哪个复制到原来的数组中
		--比较用 <= 保持排序稳定性，用 < 也能完成比较，但不是稳定排序
		--若使用 >= 比较，则是升序排序
		if tempArr1[i] <= tempArr2[j] then(
			arr[index] = tempArr1[i]
			i += 1			
		)else(
			arr[index] = tempArr2[j]
			j += 1			
		)
		index += 1
	)
	--复制剩余的元素
	while i <= tempArr1.count do(
		arr[index] = tempArr1[i]
		i += 1
		index += 1
	)
	--复制剩余的元素
	while j <= tempArr2.count do(
		arr[index] = tempArr2[j]
		j += 1
		index += 1
	)
	return arr
)
--归并排序主程序（递归函数）
function merge_sort arr low high=(
	if low == high do
		return arr
	mid = low + (high - low) / 2		--计算中间下标
	merge_sort arr low mid				--对数组 arr[low~mid] 执行归并排序
	merge_sort arr (mid + 1) high		--对数组 arr[mid+1~high] 执行归并排序
	merge_array arr low  mid high		--合并数组
	return arr
)
--调用 merge_sort 需要三个参数 数组、数组的起始下标、数组的结束下标
merge_sort arr_list 1 arr_list.count
print arr_list #noMap