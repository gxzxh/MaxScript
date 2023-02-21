SME_isOpen = SME.isOpen()
SME.open() --打开SME
for view_index = 1 to SME.getNumViews() do(						--遍历SME的视图
	view_obj=SME.getView view_index								--获取视图对象
	del_objs=#()												--存放待清除的材质
	for node_index = 1 to view_obj.getNumNodes() do(			--在视图的节点中循环
		node_obj = view_obj.getNode node_index 					--获取节点接口对象
		mat_obj = node_obj.reference							--获取节点引用的材质、贴图
		if (superclassof mat_obj)==material then(				--节点引用为材质
			if  (refs.dependentNodes mat_obj).count==0 then		--材质未使用
 				append del_objs mat_obj
		)
	)
 	view_obj.setSelectedNodes del_objs							--按材质选定节点
 	view_obj.deleteSelection()									--删除选定节点	
)
if not SME_isOpen then
	SME.close()