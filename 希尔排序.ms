--shell 排序的本质是以不同的间隔执行插入排序，直到间隔为1
--当间隔为1时，shell相当于插入排序
--视频地址 https://www.bilibili.com/video/av27747753/?p=67
function shell_sort arr = (
	间隔 = bit.shift arr.count -1 --把整数向有移动移位，相当于整除 2
    while 间隔 > 0 do(
		for i in 间隔 to arr.count do(        
            temp = arr[i] 
            j = i
			while j > 间隔 and arr[j - 间隔] > temp do(--典型的插入排序
                arr[j] = arr[j - 间隔] 
                j -= 间隔 
			)
            arr[j] = temp
		)
		间隔 = bit.shift 间隔 -1
	)
    return arr
)
arr=for i =1 to 10 collect random 50 100
shell_sort(arr)
--clearListener()
print(arr) #noMap
