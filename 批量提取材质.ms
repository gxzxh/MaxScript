(
	Global Rollout_File_Process
	Local FileList=#(), FileListSelect=#(), FileSelCount = 0
	try(destroyDialog Rollout_File_Process )catch()
	local 主路径 = ""
	-----------------------------------------------------------------------------------
	--函数定义
	-----------------------------------------------------------------------------------
	--调整单个贴图资源的路径(含文件名)
	Function ModifyResourcePath src des = (
		local _fileList = #(src)
		ATSOps.clearSelection()
		ATSOps.selectFiles &_fileList
		ATSOps.retargetSelection des
	)
	--更新资产路径
	Function updateAssetPath = (
		TRY (
			ATSOps.Visible=on
			Local FileList=#()
			ATSOps.GetFiles &FileList
			ATSOps.SelectFiles &FileList
			ATSOps.ResolveSelectionToAbsolute()
		) CATCH()
		ATSOps.Visible = off
	)
	-- 获取场景所有材质清单
	Function getSceneMatList=(
		local _SceneMatList = #()
		for item in sceneMaterials do(
			if  classof item == Multimaterial then(
				for mat in item.materialList where mat != undefined do
					appendIfUnique _SceneMatList mat
			)else
				append _SceneMatList item	
		)
		return _SceneMatList
	)
	--获取有效文件名
	Function getValidFileName _ValidFileName = (
		local  _index = 1
		local  _fileType = getFilenameType _ValidFileName
		local _fileName = getFilenamePath _ValidFileName +"\\" + getFilenameFile _ValidFileName
		while doesFileExist _ValidFileName do(
			_ValidFileName = _fileName + "_" + _index as string + _fileType
			_index += 1
		)
		return _ValidFileName
	)
	---------------------------------------------------------------
	Function collectMapofMat mat mat_Path = (
		--获取材质文件名，防止覆盖重复文件
		local _matFileName = getValidFileName (pathConfig.appendPath mat_Path ((classof mat) as string + "_" + mat.name + ".mat"))
		local 贴图路径 = pathConfig.appendPath mat_Path (getFilenameFile _matFileName + "\\")
		--创建保存贴图的文件夹
		makeDir 贴图路径 All:True
		for _theMap in usedMaps mat do(
			local 新文件名 = getValidFileName (贴图路径 +  FilenameFromPath _theMap)
			copyFile _theMap 新文件名
			ModifyResourcePath _theMap 新文件名
		)
		--保存材质文件
		saveTempMaterialLibrary (materialLibrary mat) _matFileName
	)
	---------------------------------------------------------------
	Function getMatAsSaveFile = (
		-- 获取材质清单
		local 材质清单 = getSceneMatList()	
		for mat in 材质清单 do(		
			collectMapofMat Mat 主路径
		)
	)
	--设置 dotNetControl 控件外观
	Function Fn_SetdotNetControlstyle Roll FontSize=(
		Local DotCtrlBackColor = (dotnetclass "System.Drawing.Color").fromARGB 0 128 128
		Local DotCtrlForeColor = (dotnetclass "System.Drawing.Color").fromARGB 255 255 0
		Local DotCtrlFont=dotnetobject "System.Drawing.Font" "Tahoma" FontSize
		if classof Roll!=RolloutClass do Return OK
		for C in Roll.Controls Where(Classof C ==dotNetControl) do (
			C.backcolor = DotCtrlBackColor
			C.forecolor = DotCtrlForeColor
			C.font =DotCtrlFont
		)
	)--SetdotNetControlstyle
	------------------------------------------------------------------
	Function  getFileAll =(
		Local 文件类型="场景文集(*.max)|*.max"
		Local TempFile=GetOpenFileName Caption:"请选中任意场景文件" Types:文件类型 Historycategory:"Openfile" Initialdir:(getdir #maxroot)
		If TempFile==Undefined then return #()
		Local L_FileList=getfiles(getFilenamePath TempFile + "/*.max")
		Return (Sort L_FileList)
	)--GetFileAll
	-----------------------------------------------------------------------------------
	Function getFileList Root=(
		Local L_FileList=#()
 		if Root != Undefined And isDirectoryWriteable Root Do
 			L_FileList = getfiles (Root+ "/*.max") Recurse:True
 		Return (Sort L_FileList)
	)
	-------------------------------------------------------------------
	--卷展栏定义
	-------------------------------------------------------------------
	Rollout Roll_批量提取场景材质 "批量提取场景材质"(
 		dotNetControl Btn_渲染材质预览图 "System.Windows.Forms.button" text:"批量提取场景材质" Width:240 height:60 Align:#Center
 		on Roll_批量提取场景材质 Open do(
			Fn_SetdotNetControlstyle Roll_批量提取场景材质 16
		)
 		on Btn_渲染材质预览图 Click e do(
			if FileListSelect.count == 0 do (messageBox "未选择场景文集，退出。"; return False)
			messageBox "请选择保存路径！"
			主路径 = getsavepath()
			if 主路径 == undefined do return undefined
			local _errCount = 0
			Local _Prog_Value = Rollout_File_Process.过滤文件进度条.value = 0
			for _maxFile in FileListSelect do(
 				Local _isOpen = loadMaxFile _maxFile quiet:True
 				if Not _isOpen do(print ("场景文件："+ _maxFile + "处理失败"); _errCount += 1; continue)
 				updateAssetPath()	--更新资产路径
 				getMatAsSaveFile()
 				_Prog_Value += 1
 				Rollout_File_Process.过滤文件进度条.value=100.0 * _Prog_Value / FileSelCount
			)
			ResetMaxFile #NoPrompt
			if _errCount > 0 do messageBox ("共有"+ _count as string + "个场景文件处理失败。\n请按 F11 打开侦听器查看。")
		)
	)
	-----------------------------------------------------------------
	rollout Rollout_File_Process "批量提取场景材质" Width:300(
		subRollout theSubRollout width:300 height:150 align:#center
		Progressbar 过滤文件进度条 Color:[0,200,0] Orient:#Horizontal
		Group "场景文件来源"(
			EditText FileRootPath "根目录" Width:280 Text:"NULL" align:#center
			Radiobuttons File_Source "" Labels:#("单级路径","多级路径") Default:1 Columns:2 Align:#left
			Label Label04 "共选择 0 个文件" offset:[70,-21]
		)
		Button Btn_获取文件列表 "【获取场景（材质库）文件】" Width:170 Height:30
		MultiListbox 文件列表框 "" Width:290  height:24 Items:#()  align:#center
		On 文件列表框 Selected arg do(
			label04.text="共选择了 "+文件列表框.selection.NumberSet as string +" 个文件"
		)
		on 文件列表框 doubleClicked arg do(
			文件列表框.selection=#{1..文件列表框.Items.count}
			FileListSelect=#(); Join FileListSelect FileList
			FileSelCount=FileListSelect.Count
			FilePointer=0
			label04.text="共选择 "+文件列表框.selection.NumberSet as string +" 个文件"
		)
		On 文件列表框 Selectionend Do(
			FileListSelect=For i in 文件列表框.selection Collect FileList[I]
			FileSelCount=FileListSelect.Count
			FilePointer=0
		)
		On Btn_获取文件列表 pressed do (
			--FileList，FileListSet，FileSelCount，FilePointer 变量在顶层声明
			FileListSelect = #(); FileSelCount = 0; FilePointer = 0
			文件列表框.Items=#()
			Local 临时目录=""
			If File_Source.State==1 then(
				FileList=GetFileAll()--单一文件夹
				if FileList.Count>0 then
					临时目录 = getFilenamePath FileList[1]
			)Else(
				临时目录 = (getSavePath caption:"请选择根目录")
				FileList = getFileList 临时目录
			)
			文件列表框.Items=for FileName in  FileList Collect (filenameFromPath FileName)
			FileRootPath.Text = if FileList.Count>0 then 临时目录  Else "NULL"
		)--On Btn_获取文件列表
		-------------------------------------------
		on Rollout_File_Process open do	(			
			addSubRollout theSubRollout Roll_批量提取场景材质
		)
	------------------------------------------------
	)
	createdialog Rollout_File_Process
)