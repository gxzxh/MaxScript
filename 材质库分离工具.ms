(
	Global Rollout_File_Process
	Local FileList=#(), FileListSelect=#(), FileSelCount = 0
	try(destroyDialog Rollout_File_Process )catch()
	-----------------------------------------------------------------------------------
	--函数定义
	-----------------------------------------------------------------------------------
	----设置 dotNetControl 控件外观
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
		Local 文件类型="库文件(*.mat)|*.mat"
		Local TempFile=GetOpenFileName Caption:"请选中任意文件" Types:文件类型 Historycategory:"Openfile" Initialdir:(getdir #maxroot)
		If TempFile==Undefined then return #()
		Local L_FileList=getfiles(getFilenamePath TempFile + "/*.mat")
		Return (Sort L_FileList)
	)--GetFileAll
	-----------------------------------------------------------------------------------
	Function getFileList Root=(
		Local L_FileList=#()
 		if Root != Undefined And isDirectoryWriteable Root Do
 			L_FileList = getfiles (Root+ "/*.mat") Recurse:True
 		Return (Sort L_FileList)
	)
	-------------------------------------------------------------------
	--卷展栏定义
	-------------------------------------------------------------------
	Rollout Roll_渲染材质预览图 "渲染材质预览图"(
 		dotNetControl Btn_渲染材质预览图 "System.Windows.Forms.button" text:"渲染材质预览图" Width:240 height:60 Align:#Center offset:[0,10]
 		on Roll_渲染材质预览图 Open do Fn_SetdotNetControlstyle Roll_渲染材质预览图 16
 		on Btn_渲染材质预览图 Click e do(
			if $Material_Object == undefined then (Messagebox "场景中不存在名称为【Material_Object】的对象"; Return false )
			if FileListSelect.count == 0 do (messageBox "未选择材质库，退出。"; return False)
			local _errCount = 0
			Local _Prog_Value = Rollout_File_Process.过滤文件进度条.value = 0
			for _matFile in FileListSelect do(
				Local _TempMatLib = loadTempMaterialLibrary _matFile
				if _TempMatLib == undefined or _TempMatLib.count==0 do(print ("材质库："+ _matFile + "处理失败"); _errCount += 1; continue)
				local _previewFile = (getfilenamepath _matFile)+(getfilenamefile _matFile)+".jpg"
				$Material_Object.material = _TempMatLib[1]
  				render outputfile:_previewFile
				_Prog_Value += 1
				Rollout_File_Process.过滤文件进度条.value=100.0 * _Prog_Value / FileSelCount
			)
			if _errCount > 0 do messageBox ("共有"+ _count as string + "个库文件处理失败。\n请按 F11 打开侦听器查看。")
		)
	)
	-------------------------------------------------------------------------------------------------------------
	Rollout Roll_分离材质库 "分离材质库"(
 		dotNetControl Btn_分离材质库 "System.Windows.Forms.button" text:"分离材质库" Width:240 height:60 Align:#Center offset:[0,10]
 		on Roll_分离材质库 Open do 	Fn_SetdotNetControlstyle Roll_分离材质库 16
 		on Btn_分离材质库 Click e do(
			if FileListSelect.count == 0 do (messageBox "未选择材质库，退出。"; return False)
			local _errCount = 0
			Local _Prog_Value = Rollout_File_Process.过滤文件进度条.value = 0
			for _matFile in FileListSelect do(
				_Prog_Value += 1
				Local _TempMatLib = loadTempMaterialLibrary _matFile
				if _TempMatLib == undefined do(
					print ("材质库："+ _matFile + "加载失败")
					_errCount += 1
					continue
				)
				local _outPath = getFilenamePath _matFile + getFilenameFile _matFile
				makeDir _outPath
 				for _mat in _TempMatLib do(
 					local _outMatFile = _outPath + "\\" + _mat.name + ".mat"
 					saveTempMaterialLibrary (materialLibrary _mat)  _outMatFile
 				)
				Rollout_File_Process.过滤文件进度条.value=100.0 * _Prog_Value / FileSelCount
			)
			if _errCount > 0 do messageBox ("共有"+ _count as string + "个库文件无法打开。\n请按 F11 打开侦听器查看。")
		)
	)
	Tabs_Rollouts = #(
		#("渲染预览图", Roll_渲染材质预览图),
		#("分离材质库", Roll_分离材质库)
	)
-----------------------------------------------------------------
	rollout Rollout_File_Process "文件处理" Width:300(
		Local LastSubRollout = 1
		dropdownlist dn_tabs "" height:20 width:300 align:#center Selection:LastSubRollout
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
		on dn_tabs Selected itm do(
			Local subroll=Tabs_Rollouts[LastSubRollout][2]
 			removeSubRollout theSubRollout subroll
 			subroll=Tabs_Rollouts[LastSubRollout = dn_tabs.selection][2]
 			addSubRollout theSubRollout subroll
		)--end tabs clicked
		-------------------------------------------
		on Rollout_File_Process open do	(
  			local hodo = #()
  			for aTab in Tabs_Rollouts do append hodo aTab[1]
  			dn_tabs.items = hodo
			addSubRollout theSubRollout Tabs_Rollouts[LastSubRollout][2]
		)
	------------------------------------------------
	)
	createdialog Rollout_File_Process
)