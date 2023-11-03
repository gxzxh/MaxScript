--将选择集保存为文件，文件名由前缀和日期组成
function saveSelToFile 路径 prefix sel = (
	local 日期数组 = getLocalTime()
	local 场景文件名 = pathConfig.appendPath 路径  (prefix + 日期数组[1] as string + "_" + 日期数组[2] as string + "_" + 日期数组[4] as string + "_" + 日期数组[5] as string + "_" + 日期数组[6] as string + "_" + 日期数组[7] as string + ".max")
	saveNodes sel 场景文件名 quiet:true
	pushPrompt ("所选节点已保存为文件：" + 场景文件名)
	return 场景文件名
)
--调整单个贴图资源的路径(含文件名)
Function ModifyResourcePath src des = (
	local _fileList = #(src)
	ATSOps.clearSelection()
	ATSOps.selectFiles &_fileList
	ATSOps.retargetSelection des
)
--更新资源路径
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
--获取节点文件保存路径
Function getNodeSavePath = (
	local _INI_FileName =getFilenamePath (getSourceFileName())+"getNodeAsSaveFile.ini"
	local _node_Path = getINISetting _INI_FileName  "PATH"  "NodePath"
	if _node_Path == "" then(
		messageBox "路径为空，请手动指定路径！"
		_node_Path = getSavePath caption:"请手动指定节点文件保存的路径！"
		if _node_Path == undefined then(
			messageBox "指定路径为空，放弃保存结点。"
			return undefined
		)
		setINISetting _INI_FileName  "PATH"  "NodePath" _node_Path
		messageBox ("若要修改节点文件保存路径，请删除配置文件：\n" + _INI_FileName)
	)
	return _node_Path
)
-- 获取选定对象使用的贴图文件名称，存入fileList返回
Function getMapOfSelNode Sel &fileList=(
	for obj in sel where obj.material != undefined do(
		for theMap in usedMaps obj.material do
			appendIfUnique filelist theMap
	)
)
--若文件存在磁盘上，则调整文件名并返回
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
-----------------------------------------------------
-----------------------------------------------------
-- 将数组 list 内容输出到磁盘文件
Function printListToFile outFileName &list=(
	local _outFile = openFile  outFileName mode:"wt"
	if _outFile == undefined do(
		messageBox "未能创建压缩包。"
		return undefined
	)
	for item in list do(
		print item to:_outFile
	)
	close _outFile
)
Function pack 场景文件名 文件清单 = (
	local 压缩包路径 = getFilenamePath 场景文件名
	local 压缩包名 = pathConfig.appendPath  压缩包路径  (getFilenameFile 场景文件名 + ".zip")
	local 打包清单文件名 = pathConfig.appendPath 压缩包路径  "abcdefghijklmh.txt"
	printListToFile 打包清单文件名 &文件清单
	packCommand = pathConfig.appendPath (getFilenamePath (getSourceFileName())) "7z.exe"
	packCommand += " a  -tzip  -sdel -mx9  "
	packCommand += 压缩包名
	packCommand += " @"
	packCommand += 打包清单文件名
	HiddenDOSCommand packCommand
)
--主函数
Function getNodeAsSaveFile = (
	local _selNode = getCurrentSelection()
	if 0 == _selNode.count do(
		messageBox "未选择任何对象，退出。"
 		return undefined
 	)
 	--获取结点文件保存路径
	local _node_Path = getNodeSavePath()
	if _node_Path == undefined do return undefined
	---更新资源路径
	updateAssetPath()
	local 资源路径 = pathConfig.appendPath _node_Path "Textures"
	makedir 资源路径
	local 资源文件列表 = #()
	getMapOfSelNode _selNode &资源文件列表
	local _arrForRecovery = #(#(),#())
	-- 收集代理文件
	for item in _selNode where isProperty item #fileName  do(
		if item.fileName != "" do append  资源文件列表 item.fileName
		if isProperty item #fileNamePreview and item.fileNamePreview != "" do
			append  资源文件列表 item.fileNamePreview
		if isProperty item #filenameeditbox    and item.filenameeditbox  != "" do
			append  资源文件列表 item.filenameeditbox
	)
	for item in 资源文件列表 do(
		local 新文件名 = (pathConfig.appendPath 资源路径 (filenameFromPath item))
		新文件名 = getValidFileName 新文件名
		copyFile item 新文件名
		append _arrForRecovery[1]  item
		append _arrForRecovery[2]  新文件名
	)
	--调整资源路径
	for index = 1 to _arrForRecovery[1].count do(
		ModifyResourcePath _arrForRecovery[1][index] _arrForRecovery[2][index]
	)
	-- 保存节点到文件
	local 场景文件名 = saveSelToFile _node_Path "/CGSAN_" _selNode
	--恢复资源路径
	for index = 1 to _arrForRecovery[1].count do(
		ModifyResourcePath _arrForRecovery[2][index] _arrForRecovery[1][index]
	)
	append _arrForRecovery[2] 场景文件名
	pack 场景文件名 _arrForRecovery[2]
)
getNodeAsSaveFile()
