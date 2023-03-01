arr_list = #(3, 2, 5, 2, 4, 2, 5)
--计数排序适用于整数数组，最大值与最小值差距小，重复项目多
--原数组被保留，返回新的数组
function count_sort arr = (
	min_data = amin arr	--求最大值
	max_data = amax arr	--求最小值

	--生成计数数组
	len = max_data - min_data + 1
	counts = for i = 1 to len collect 0

	--计算每一个元素在数组 arr 中出现的次数
	--counts[0] 保存 min_data 的次数
	--某元素对于的 counts 索引为 num - min_data + 1
	for num in arr do
		counts[num - min_data + 1] += 1

	--数组 counts，其每个元素 = 其左边的和
	--counts 元素的含义，它的元素值是 arr 元素在排序后数组中的位置
	for j = 2 to len do
		counts[j] += counts[j - 1]

	--生成目标空数组
	res = #(); res[arr.count] = 0

	for i = arr.count to 1 by -1 do(
		-- index = 当前值 - 最小值 + 1，其结果是当前值在 counts 的对应项下标
		-- 通过 counts[index] 取出的值，是当前值在排序后数组的位置
		index = arr[i] - min_data + 1
		res[counts[index]] = arr[i]
		-- 位置递减
		counts[index] -= 1
	)
	return res
)
ans = count_sort arr_list
msgbox ans