(
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
	--将当前视口快照保存为 jpg 文件
	Function saveViewToPreview PreviewFileName = (
		--view_size = getViewSize()
		_dib = gw.getViewportDib()
		_dib.filename = PreviewFileName
		save _dib
		close _dib
	)
	--返回当前选定对象的材质
	Function getMatOfObj = (
		if selection[1]==undefined or selection[1].material==undefined then(
			messageBox "您未选定对象，或选定对象没有材质，退出。"
			return undefined
		)
		return selection[1].material
	)
	--获取材质文件保存路径
	Function getMatSavePath = (
		local _INI_FileName =getFilenamePath (getSourceFileName())+"GetMatAsSaveFile.ini"
		local _mat_Path = getINISetting _INI_FileName  "PATH"  "MatPath"
		if _mat_Path == "" then(
			messageBox "路径为空，请手动指定路径！"
			_mat_Path = getSavePath caption:"请手动指定材质保存的路径！"
			if _mat_Path == undefined then(
				messageBox "指定路径为空，放弃保存材质。"
				return undefined
			)
			setINISetting _INI_FileName  "PATH"  "MatPath" _mat_Path
			messageBox ("若要修改材质路径，请删除配置文件：" + _INI_FileName)
		)
		return _mat_Path
	)
	--返回有效的文件名称，防止重名
	Function getValidFileName fileName fileType = (
		local _index = 1
		local _ValidFileName = fileName + fileType
		while doesFileExist _ValidFileName do(
			_ValidFileName = fileName + "_" + _index as string + fileType
			_index += 1
		)
		return _ValidFileName
	)
	--调整单个贴图资源的路径(含文件名)
	Function ModifyResourcePath src des = (
		local _fileList = #(src)
		ATSOps.clearSelection()
		ATSOps.selectFiles &_fileList
		ATSOps.retargetSelection des
	)
	--收集贴图，保存材质、预览图
	Function collectMapofMat mat mat_Path = (
		--用于恢复贴图路径
		local _arrForRecovery = #()
		--获取材质文件名，防止覆盖重复文件
		local _matFileName = getValidFileName (pathConfig.appendPath mat_Path mat.name) ".mat"
		local _theMapPath = pathConfig.appendPath mat_Path "Textures"
		--创建保存贴图的文件夹
		makeDir _theMapPath
		for _theMap in usedMaps mat do(
			local _newPath = getValidFileName (_theMapPath + "\\" + getFilenameFile _theMap ) (getFilenameType _theMap)
			copyFile _theMap _newPath
			append _arrForRecovery #(_newPath, _theMap)
			ModifyResourcePath _theMap _newPath
		)
		--保存预览图
		saveViewToPreview (getFilenamePath _matFileName + getFilenameFile _matFileName + ".jpg")
		--保存材质文件
		saveTempMaterialLibrary (materialLibrary mat) _matFileName
		--恢复贴图路径
		for _item in _arrForRecovery do(
			ModifyResourcePath _item[1] _item[2]
		)
	)
	--主函数
	Function getMatAsSaveFile = (
		-- 获取材质
		local _theMat = getMatOfObj()
		if _theMat == undefined do return undefined
		-- 获取材质保存路径
		local _mat_Path = getMatSavePath()
		if _mat_Path == undefined do return undefined
		--更新资产路径
		updateAssetPath()
		collectMapofMat _theMat _mat_Path
		pushPrompt ("材质提取完毕！路径为：" + _mat_Path)
	)
	getMatAsSaveFile()
)