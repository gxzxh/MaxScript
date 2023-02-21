(
	Global Rollout_File_Process
	Local FileListSet=#()	--数组保存在列表框中选中的文件
	local FileList = #()
	try(destroyDialog Rollout_File_Process) catch()
	-----------------------------------------------------------------------------------
	--函数定义
	-----------------------------------------------------------------------------------
	--打开文件选择窗口，选中任意场景文件，返回当前所在目录所有场景文件名组成的数组
	Function  GetFileAll =(
		Local __文件类型="场景文件(*.MAX)|*.MAX|ALL|*.*"
		Local __TempFile=GetOpenFileName Caption:"请选中场景文件" Types:__文件类型 Historycategory:"Openfile" Initialdir:(getdir #maxRoot)
		If __TempFile==Undefined then return #()
		Local __FilePath=getFilenamePath __TempFile --获取路径
		Local __FileType=getFilenameType __TempFile
		Local __FileList=Getfiles(__FilePath+ "/*" + __FileType)  --获取文件列表
		Return (Sort __FileList)
	)--GetFileAll
	-----------------------------------------------------------------------------------
	--获取指定目录下所有指定类型的文件，返回文件名组成的数组
	--Root		指定的目录
	--File_Type	指定的文件类型
	Function Fn_GetFileList __Root __File_Type=(
		Local __FileList=#()
 		if __Root !=Undefined And isDirectoryWriteable __Root Do
 			__FileList = Getfiles (__Root+ "/" + __File_Type) Recurse:True
 		Return (Sort __FileList)
	)
	----------------------------------------------------
	--卷展栏定义
	----------------------------------------------------
	rollout Rollout_File_Process "场景文件批处理" Width:300(
		/********************************************************
		********* 可以在这里添加控件 ***************************
		********************************************************/
		button btn_processed "处理" width:100 height:40
		on btn_processed pressed do(
			/********************************************************
			*** 处理的代码写在这里								*****
			*** FileListSet 数组保存列表框中选中的文件			*****
			*** 可通过循环处理选中文件							*****
			*** 或定义 mapped 函数，FileListSet 作为参数		*****
			********************************************************/
		)
		Group "场景文件来源"(
			editText __FileRootPath "根目录" Width:280 Text:"NULL" align:#center
			radioButtons __File_Source "" Labels:#("单级路径","多级路径") Default:1 Columns:2 Align:#left
			label __label01 "共选择 0 个文件" offset:[70,-21]
		)
		---------------------------------------------------------------------------
		button Btn_获取文件列表 "【获取场景（材质库）文件】" Width:170 Height:30
			On Btn_获取文件列表 pressed do (
				FileListSet=#(); Rollout_File_Process.__文件列表框.items=#(); __临时目录 = ""
				If __File_Source.State == 1 then(
					FileList = GetFileAll()--单一文件夹
					if FileList.Count > 0 then
						__临时目录=getFilenamePath FileList[1]
				)Else(
					临时目录 = (getSavePath caption:"请选择根目录")
					FileList = Fn_GetFileList 临时目录 ".max"
				)
				Rollout_File_Process.__文件列表框.Items=for FileName in FileList Collect (filenameFromPath FileName)
				__FileRootPath.Text=if FileList.Count > 0 then __临时目录 Else "NULL"
			)--On Btn_获取文件列表
		---------------------------------------------------------------------------
		multiListBox __文件列表框 "" Width:290  height:16 Items:#()  align:#center
			On __文件列表框 selectionEnd Do(
				FileListSet = For i in __文件列表框.selection Collect FileList[i]
				__label01.text="共选择了 "+__文件列表框.selection.NumberSet as string +" 个文件"
			)
		---------------------------------------------------------------------------
		button btn_allSelect "全选" width:100 height:30 across:3
		button btn_NoneSelect "不选" width:100 height:30
		button btn_reverseSelection "反选" width:100 height:30
			--全选
			on btn_allSelect pressed do (
				Rollout_File_Process.__文件列表框.selection=#{1..FileList.count}
				FileListSet=deepcopy FileList
				__label01.text = "共选择 "+__文件列表框.selection.NumberSet as string +" 个文件"
			)
			--不选
			on btn_NoneSelect pressed do(
				FileListSet=#()
				Rollout_File_Process.__文件列表框.selection=#{}
				__label01.text = "共选择 0 个文件"
			)
			--反选
			on btn_reverseSelection pressed do(
				Rollout_File_Process.__文件列表框.selection=#{1..FileList.count}-Rollout_File_Process.__文件列表框.selection
				FileListSet = For i in __文件列表框.selection Collect FileList[i]
				__label01.text = "共选择 "+__文件列表框.selection.NumberSet as string +" 个文件"
			)
	------------------------------------------------
	)
	createdialog Rollout_File_Process
)