--����Ԥ��ͼ
Function saveViewToPreview PreviewFileName = (
	view_size = getViewSize()
	_dib = gw.getViewportDib()
	_dib.filename = PreviewFileName
	save _dib
	close _dib
)
--��ѡ�񼯱���Ϊ�ļ����ļ�����ǰ׺���������
function saveSelToFile ·�� prefix sel = (
	local �������� = getLocalTime()
	local �����ļ��� = pathConfig.appendPath ·��  (prefix + ��������[1] as string + "_" + ��������[2] as string + "_" + ��������[4] as string + "_" + ��������[5] as string + "_" + ��������[6] as string + "_" + ��������[7] as string + ".max")
	saveNodes sel �����ļ��� quiet:true
	return �����ļ���
)
--����������ͼ��Դ��·��(���ļ���)
Function ModifyResourcePath src des = (
	local _fileList = #(src)
	ATSOps.clearSelection()
	ATSOps.selectFiles &_fileList
	ATSOps.retargetSelection des
)
--������Դ·��
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
--��ȡ�ڵ��ļ�����·��
Function getNodeSavePath = (
	local _INI_FileName =getFilenamePath (getSourceFileName())+"getNodeAsSaveFile.ini"
	local _node_Path = getINISetting _INI_FileName  "PATH"  "NodePath"
	if _node_Path == "" then(
		messageBox "·��Ϊ�գ����ֶ�ָ��·����"
		_node_Path = getSavePath caption:"���ֶ�ָ���ڵ��ļ������·����"
		if _node_Path == undefined then(
			messageBox "ָ��·��Ϊ�գ����������㡣"
			return undefined
		)
		setINISetting _INI_FileName  "PATH"  "NodePath" _node_Path
		messageBox ("��Ҫ�޸Ľڵ��ļ�����·������ɾ�������ļ���\n" + _INI_FileName)
	)
	return _node_Path
)
-- ��ȡѡ������ʹ�õ���ͼ�ļ����ƣ����� fileList ����
Function getMapOfSelNode Sel &fileList=(
	for obj in sel where obj.material != undefined do(
		for theMap in usedMaps obj.material do
			appendIfUnique filelist theMap
	)
)
--���ļ����ڴ����ϣ�������ļ���������
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
Function pack �����ļ��� ��Դ·�� = (
	local �����ļ�·�� = getFilenamePath �����ļ���
	local Ԥ��ͼ�� = pathConfig.appendPath  �����ļ�·��  (getFilenameFile �����ļ��� + ".jpg")
	local ѹ������ = pathConfig.appendPath  �����ļ�·��  (getFilenameFile �����ļ��� + ".zip")
	saveViewToPreview Ԥ��ͼ��
	--ѹ������ = "  \""  +  ѹ������ + "\""
	��Դ·��= "  \""  + ��Դ·�� + "\""
	Ԥ��ͼ�� = "  \""  +  Ԥ��ͼ�� + "\""
	�����ļ��� =  "  \""  + �����ļ��� + "\""
	packCommand = pathConfig.appendPath (getFilenamePath (getSourceFileName())) "7z.exe  a  -tzip  -sdel -mx9"
	--packCommand += ѹ������
	packCommand += �����ļ���
	packCommand += Ԥ��ͼ��
	packCommand += ��Դ·��
	HiddenDOSCommand packCommand
	pushPrompt ("�����ɴ���ļ���" + ѹ������)	
)
--������
Function getNodeAsSaveFile = (
	local _selNode = getCurrentSelection()
	if 0 == _selNode.count do(
		messageBox "δѡ���κζ����˳���"
 		return undefined
 	)
 	--��ȡ����ļ�����·��
	local _node_Path = getNodeSavePath()
	if _node_Path == undefined do return undefined
	---������Դ·��
	updateAssetPath()
	local ��Դ·�� = pathConfig.appendPath _node_Path "Textures"
	makedir ��Դ·��
	local ��Դ�ļ��б� = #()
	getMapOfSelNode _selNode &��Դ�ļ��б�
	-- �ռ������ļ�
	for item in _selNode where isProperty item #fileName  do(
		if item.fileName != "" do append  ��Դ�ļ��б� item.fileName
		if isProperty item #fileNamePreview  and  item.fileNamePreview != "" do
			append  ��Դ�ļ��б� item.fileNamePreview
		if isProperty item #filenameeditbox    and  item.filenameeditbox  != "" do
			append  ��Դ�ļ��б� item.filenameeditbox
	)
	local _arrForRecovery = #()
	for item in ��Դ�ļ��б� where item  !=  undefined  do(
		local ���ļ��� = (pathConfig.appendPath ��Դ·�� (filenameFromPath item))
		���ļ��� = getValidFileName ���ļ���
		copyFile item ���ļ���
		append _arrForRecovery #(item, ���ļ���)
	)
	--������Դ·��
	for item in _arrForRecovery do(
		ModifyResourcePath item[1] item[2]
	)
	-- ����ڵ㵽�ļ�
	local �����ļ��� = saveSelToFile _node_Path "/CGSAN_" _selNode
	--�ָ���Դ·��
	for item in _arrForRecovery do(
		ModifyResourcePath item[2] item[1]
	)
	pack �����ļ��� ��Դ·��
)
getNodeAsSaveFile()