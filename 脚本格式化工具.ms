(
	--不能在左括号后面添加注释，如 if True then(--测试
	Global Roll_MxsFormat
	try DestroyDialog Roll_MxsFormat catch()
	Global _KeyWords=#("if","while","for","of", "do", "else","then","collect","function", "fn")
	local _FileList=#(),  _FileListSet=#(),_FileSelCount=0
	local _inStr=""
	local _InFile, _OutFile
	local _InFileName=""
	local _TABS=0
	local _左括号数量=0
	local _LastIsWord=false
	local _单行右括号=false
	local _isCommentLine=false--是否为注释行
	local Fn_getWord, Fn_MxsFormat , GetFileAll, Fn_SetdotNetControlstyle
	-----------------------------------------------------------------
	rollout Roll_MxsFormat "脚本格式化工具 0.1" Width:300(
		dotNetControl btn_MxsFormat "System.Windows.Forms.button" text:"执行脚本格式化" Width:290 height:60 Align:#Center
		Label Label01 "完成 0 个"
		Button Btn_获取文件列表 "【获取脚本文件】" Width:170 Height:40
		Label Label04 "共选择 0 个文件" offset:[70,0]
		MultiListbox 文件列表框 "" Width:290  height:26 Items:#()  align:#center
		on btn_MxsFormat Click e do(
			for Index=1 to  _FileListSet.Count do(
				Fn_MxsFormat  _FileListSet[Index]
				Label01.text="完成 "+Index as String +" 个"
			)
			gc light:false
		)
		on Roll_MxsFormat open do(
			Fn_SetdotNetControlstyle Roll_MxsFormat 16
		)
		On 文件列表框 Selected arg do(
			label04.text="共选择了 "+文件列表框.selection.NumberSet as string +" 个文件"
		)
		on 文件列表框 doubleClicked arg do(
			文件列表框.selection=#{1..文件列表框.Items.count}
			_FileListSet=#(); Join _FileListSet _FileList
			_FileSelCount=_FileListSet.Count
			label04.text="共选择 "+文件列表框.selection.NumberSet as string +" 个文件"
		)
		On 文件列表框 Selectionend Do(
			_FileListSet=For i in 文件列表框.selection Collect _FileList[I]
			_FileSelCount=_FileListSet.Count
		)
		On Btn_获取文件列表 pressed do (
			Local 临时目录=""
			_FileListSet=#(); _FileSelCount=0
			_FileList=GetFileAll()--单一文件夹
			if _FileList.Count>0 then
			临时目录=getFilenamePath _FileList[1]
			文件列表框.Items=for FileName in  _FileList Collect (filenameFromPath FileName)
		)--On Btn_获取文件列表
	)
	-----------------------------------------------------------------------------------
	--函数定义
	-----------------------------------------------------------------------------------
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
	Function  GetFileAll =(
		Local 文件类型="脚本文件(*.ms;*mcr)|*.ms; *.mcr"
		Local TempFile=GetOpenFileName Caption:"请选中脚本文件" Types:文件类型 Historycategory:"Openfile" Initialdir:(getdir #maxroot)
		If TempFile==Undefined then return #()
		Local L_FilePath=getFilenamePath TempFile --获取路径
		Local L_FileType=getFilenameType TempFile
		Local L_FileList=Getfiles(L_FilePath+ "/*"+L_FileType)  --获取文件列表
		Return (Sort L_FileList)
	)--GetFileAll
	---------------------------------------
	Function Fn_MxsFormat FileName=(
		--备份文件
		Local BakFileName=(getFilenamePath FileName)+(getFilenameFile FileName)+"_bak"+	(getFilenameType FileName)
		Local TempFileName=(getFilenamePath FileName)+(getFilenameFile FileName)+"_temp"+	(getFilenameType FileName)
		if not (Copyfile FileName BakFileName) do(
			Messagebox (FileName +"  备份失败！")
			return False
		)
		_OutFile=openFile TempFileName mode:"w"
		if _OutFile==Undefined do(
			Messagebox ("无法创建临时文件："+FileName)
			return False
		)
		_InFile=openFile BakFileName mode:"r"
		--开始过程 1
		while (not eof _InFile) do(
			--获取非空行
			while (not eof _InFile)	do(
				_inStr=trimLeft(trimRight ( readLine _InFile ))
				if _inStr.count>0 do exit
			)
			Local Len=_inStr.count
			if _isCommentLine then(
				format ("\n"+_inStr) to:_OutFile
			)else if len==1 then(
				Local c = _inStr[1]
				case c of(
					"(": (format (c+"\n") to:_OutFile)
					")": (format ("\n"+c) to:_OutFile)
					Default:(format ("\n"+c) to:_OutFile)
				)
			)else if (Fn_getWord _inStr pos:#L)=="else" then(
				if not _单行右括号 then format "\n"to:_OutFile
				format _inStr to:_OutFile
			)else(
				format ("\n"+_inStr) to:_OutFile
			)
			_单行右括号= if  c==")" and len==1 then true else False
			_isCommentLine=if (substring _inStr 1 2)=="--" then true else False
		)
		format ("\n------------------------") to:_OutFile
		close  _InFile
		close  _OutFile
		--过程 1 结束
		------------------------------
		_InFile=openFile TempFileName mode:"r"
		_OutFile=openFile FileName mode:"w"
		if _OutFile==Undefined do(
			Messagebox ("文件 "+FileName +"  不可写！")
			Close _InFile
			return False		
		)
		_inStr=""
		_isCommentLine=false
		--开始过程 2
		do(
			if not _isCommentLine then(
				Local S=toLower (substring _inStr 1 5)
				IF _inStr[1]==")" then (_左括号数量-=1)
			)
			for i=1 to _左括号数量+_TABS do Format "\t" to:_OutFile
			Format (_inStr+"\n") to:_OutFile
			_isCommentLine=if (substring _inStr 1 2)=="--" then true else False
			if not _isCommentLine then(
				if _inStr[_inStr.count]=="(" do _左括号数量+=1
			)
			_LastIsWord=Finditem _KeyWords (Fn_getWord _inStr pos:#R) > 0
			if _LastIsWord then _TABS+=1 else _TABS=0
			while(not eof _InFile)do(_inStr=readLine _InFile; if _inStr.count>0 do exit)
		)while (not eof _InFile)
		close  _InFile
		close  _OutFile
		Deletefile TempFileName
		Return True
	)--函数Fn_MxsFormat
	---------------------------------------
	Function Fn_getWord Str pos:#R = if str.count>0 then(
		Local word="", c=""
		if pos==#R then(
			for  index=str.count to 1 by -1 do(
				c=toLower str[index]
				if c>="a" and c<="z" then word = c+ word else exit
			)
		)else(
			for index=1 to str.count do(
				c=toLower str[index]
				if c>="a" and c<="z" then word +=c else exit
			)
		)
		return word
	)
	createdialog Roll_MxsFormat
)