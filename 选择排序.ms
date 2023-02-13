--用undo off关闭撤销功能
x_start=-200;x_step = 20; N = 16
try (
	delete 数组
	delete 指针
)catch()
指针=box length:5 width:5 height:5 pos:[-200,0,-50]
--生成 N 个 Box，保存在数组中
数组 = for i=0 to N-1 collect undo off(
	box_obj=box length:5 width:5 height:(random 10 100) wirecolor:(color (random 0 255) (random 0 255) (random 0 255))
	box_obj.pos.x=(x_start+i* x_step)
	box_obj
)

--以下为选择排序算法
--参数 arr 为数组，包含若干个 Box 对象
--按对象的高度在X轴上按升序排列对象
function select_sort arr = undo off(
	if arr.count < 2 do return arr							--长度为 1 或 0，直接返回
	for index = 1 to arr.count - 1 do(
		(指针.pos.x = arr[index].pos.x;	Redrawviews())		--演示用
		min_data_pos = index								--min_data_pos 用来保存最小项的下标
 		-- data 在 数组【 index + 1 ... n】找到一个比 data 小的元素
 		for i = index + 1 to arr.count do(
 			arr[i].pos.z = arr[min_data_pos].pos.z = -20	--演示用
 			sleep 0.3; Redrawviews()	 					--演示用
 			if arr[i].height < arr[min_data_pos].height do(
				arr[i].pos.z = arr[min_data_pos].pos.z = 0	--演示用
 				min_data_pos = i
				指针.pos.x = arr[min_data_pos].pos.x	 	--演示用
 			)
			arr[i].pos.z = arr[min_data_pos].pos.z = 0	 	--演示用
 			sleep 0.3; Redrawviews()					 	--演示用
 		)
		if index != min_data_pos then(
			swap arr[index].pos.x  arr[min_data_pos].pos.x 	--交换 x 坐标
			swap arr[index] arr[min_data_pos]				--交换元素位置
			sleep 0.5; Redrawviews() 						--演示用
		)
		arr[index].pos.z = -50; Redrawviews() 				--演示用
	)
	arr[arr.count].pos.z = -50; sleep 0.5; Redrawviews()  	--演示用
    return arr
)
select_sort 数组