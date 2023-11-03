--��ѡ�񼯱���Ϊ�ļ����ļ�����ǰ׺���������
function saveSelToFile ·�� prefix sel = (
	local �������� = getLocalTime()
	local �����ļ��� = pathConfig.appendPath ·��  (prefix + ��������[1] as string + "_" + ��������[2] as string + "_" + ��������[4] as string + "_" + ��������[5] as string + "_" + ��������[6] as string + "_" + ��������[7] as string + ".max")
	saveNodes sel �����ļ��� quiet:true
	pushPrompt ("��ѡ�ڵ��ѱ���Ϊ�ļ���" + �����ļ���)
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
-- ��ȡѡ������ʹ�õ���ͼ�ļ����ƣ�����fileList����
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
-- ������ list ��������������ļ�
Function printListToFile outFileName &list=(
	local _outFile = openFile  outFileName mode:"wt"
	if _outFile == undefined do(
		messageBox "δ�ܴ���ѹ������"
		return undefined
	)
	for item in list do(
		print item to:_outFile
	)
	close _outFile
)
Function pack �����ļ��� �ļ��嵥 = (
	local ѹ����·�� = getFilenamePath �����ļ���
	local ѹ������ = pathConfig.appendPath  ѹ����·��  (getFilenameFile �����ļ��� + ".zip")
	local ����嵥�ļ��� = pathConfig.appendPath ѹ����·��  "abcdefghijklmh.txt"
	printListToFile ����嵥�ļ��� &�ļ��嵥
	packCommand = pathConfig.appendPath (getFilenamePath (getSourceFileName())) "7z.exe"
	packCommand += " a  -tzip  -sdel -mx9  "
	packCommand += ѹ������
	packCommand += " @"
	packCommand += ����嵥�ļ���
	HiddenDOSCommand packCommand
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
	local _arrForRecovery = #(#(),#())
	-- �ռ������ļ�
	for item in _selNode where isProperty item #fileName  do(
		if item.fileName != "" do append  ��Դ�ļ��б� item.fileName
		if isProperty item #fileNamePreview and item.fileNamePreview != "" do
			append  ��Դ�ļ��б� item.fileNamePreview
		if isProperty item #filenameeditbox    and item.filenameeditbox  != "" do
			append  ��Դ�ļ��б� item.filenameeditbox
	)
	for item in ��Դ�ļ��б� do(
		local ���ļ��� = (pathConfig.appendPath ��Դ·�� (filenameFromPath item))
		���ļ��� = getValidFileName ���ļ���
		copyFile item ���ļ���
		append _arrForRecovery[1]  item
		append _arrForRecovery[2]  ���ļ���
	)
	--������Դ·��
	for index = 1 to _arrForRecovery[1].count do(
		ModifyResourcePath _arrForRecovery[1][index] _arrForRecovery[2][index]
	)
	-- ����ڵ㵽�ļ�
	local �����ļ��� = saveSelToFile _node_Path "/CGSAN_" _selNode
	--�ָ���Դ·��
	for index = 1 to _arrForRecovery[1].count do(
		ModifyResourcePath _arrForRecovery[2][index] _arrForRecovery[1][index]
	)
	append _arrForRecovery[2] �����ļ���
	pack �����ļ��� _arrForRecovery[2]
)
getNodeAsSaveFile()