--用undo off关闭撤销功能
x_start=-200;x_step = 20; N = 16
try (
	delete 数组
	delete 指针
)catch()
指针=box length:5 width:5 height:5
--生成 N 个 Box，保存在数组中
数组 = for i=0 to N-1 collect undo off(
	box_obj=box length:5 width:5 height:(random 10 100) wirecolor:(color (random 0 255) (random 0 255) (random 0 255))
	box_obj.pos.x=(x_start+i* x_step)
	box_obj
)
--以下为冒泡排序算法
--参数 arr 为数组，包含若干个 Box 对象
--按对象的高度在X轴上按升序排列对象
Function Bubble_sort arr = undo off(
	for i = 1 to arr.count - 1 do( --外层循环次数比对象数少 1
 		for j = 1 to arr.count - i do(
			指针.pos =[x_start+(arr.count - i) * x_step,0, -10]--与排序无关的语句
 			--比较当前 Box 和下一个相邻 Box 的高度
 			if arr[j].height > arr[j+1].height then(--比较高度
				sleep 0.5							--延时，与排序无关
				Redrawviews()						--刷新视口，与排序无关
				swap arr[j].pos.x  arr[j+1].pos.x	--交换 x 坐标
				swap arr[j]  arr[j+1]				--交换两个box在数组中的位置								
			)
 		)
 	)
)
Bubble_sort 数组