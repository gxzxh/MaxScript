unregisterRedrawViewsCallback gw_viewInfo
fn gw_viewInfo =if not isAnimPlaying() and selection.count != 0 do (
	_pcount = "0"; printmsg = " "; 	printmsg2 = ""; 	_color = color 255 255 255
	if modPanel.getCurrentObject() != undefined then (
		--“修改”面板堆栈中当前选定不为空。
		local selbas = modPanel.getCurrentObject()
		case classOf selbas of (
			Editable_poly: (
				case getSelectionLevel selbas of (
					#vertex: (
						userPS = polyOp.getVertSelection selbas
						_pcount = userPS.numberSet as String
						printmsg += "Vertexs: " + _pcount + " / " + (polyOp.getNumVerts selbas) as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					#edge: (
						userPS = polyOp.getEdgeSelection selbas
						_pcount = userPS.numberSet as String
						printmsg += "Edges: " + _pcount + " / " + (polyOp.getNumEdges selbas) as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					#face: (
						userPS = polyOp.getFaceSelection selbas
						_pcount = userPS.numberSet as String
						printmsg += "Faces: " + _pcount + " / " + (polyOp.getNumFaces selbas) as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					default: printmsg += "Vertexs: " + (polyOp.getNumVerts selbas) as String + " | edges: " + (polyOp.getNumEdges selbas) as String + " | faces: " + (polyOp.getNumFaces selbas) as String
				)
				if selbas.ignoreBackfacing do ( printmsg2 += "忽略背面" )
				if selbas.preserveUVs do (
					if printmsg2.count != 0 do printmsg2 += " | "
					printmsg2 += "保持 UVs" 
				)
				if selbas.constrainType != 0 do (
					if printmsg2.count != 0 do ( printmsg2 += " | " )
					case selbas.constrainType Of (
						1: printmsg2 += "约束: 边"
						2: printmsg2 += "约束: 面"
						3: printmsg2 += "约束: 法线"
					)
				)
			)
			Edit_Poly: (
				case getSelectionLevel selbas of (
					#vertex: (
						userPS = (selbas.getSelection #vertex node:selection[1])
						_pcount = userPS.numberSet as String
						printmsg += "Vertexs: " + _pcount + " / " + selbas.getNumVertices() as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					#edge: (
						userPS = (selbas.getSelection #edge node:selection[1])
						_pcount = userPS.numberSet as String
						printmsg += "Edges: " + _pcount + " / " + selbas.getNumEdges() as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					#face: (
						userPS = (selbas.getSelection #face node:selection[1])
						_pcount = userPS.numberSet as String
						printmsg += "Faces: " + _pcount + " / " + selbas.getNumFaces() as String
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					default: printmsg += "Vertexs: " + selbas.getNumVertices() as String + " | Edges: " + selbas.getNumEdges() as String + " | faces: " + selbas.getNumFaces() as String
				)
				if selbas.ignoreBackfacing do ( printmsg2 += "忽略背面" )
				if selbas.preserveUVs do (
					if printmsg2.count != 0 do printmsg2 += " | "
					printmsg2 += "保持 UVs"
				)
				if selbas.constrainType != 0 do (
					if printmsg2.count != 0 do ( printmsg2 += " | " )
					case selbas.constrainType Of (
						1: printmsg2 += "保持: 边"
						2: printmsg2 += "保持: 面"
						3: printmsg2 += "保持: 法线"
					)
				)
			)
			Unwrap_UVW: (
				case subObjectLevel of (
					1: (
						userPS = selbas.getSelectedGeomVerts()
						_pcount = userPS.numberSet as String
						printmsg += "Vertexs: " + _pcount
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					2: (
						userPS = selbas.getSelectedEdges()
						_pcount = userPS.numberSet as String
						printmsg += "edges: " + _pcount
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					3: ( userPS = selbas.getSelectedFaces()
						_pcount = userPS.numberSet as String
						printmsg += "faces: " + _pcount
						if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
					)
					default: printmsg += "UVW 展开"
				)
			)
			Edit_Normals: (
				printmsg = "NOrmals: " + selbas.EditNormalsMod.GetNumNormals() as String
				userPS = (selbas.EditNormalsMod.GetSelection())
				_pcount = userPS.numberSet as String
				if userPS.numberSet == 1 do _pcount += " #" + ((userPS as Array)[1] as String)
			)
			SplineShape: (
				obj = selection[1]
				case getSelectionLevel selbas of (
					#vertex: (
						knots = #()
						for s = 1 to numsplines obj do for v in getknotselection obj s do append knots v
						totalKnots = 0
						for s =1 to numsplines obj do totalKnots += numKnots obj s
						_pcount = knots.count as String
						printmsg += "Knots: " + _pcount + " / " + totalKnots as String
					)
					#face: (
						segments = #()
						for s = 1 to numsplines obj do for v in getSegSelection obj s do append segments v
						totalSegments = 0
						for s = 1 to numsplines obj do totalSegments += (numSegments obj s)
						_pcount = segments.count as String
						printmsg += "Segments: " + _pcount + " / " + totalSegments as String
					)
					#edge: ( splines = getSplineSelection obj
						_pcount = splines.count as String
						printmsg += "Splines: " + _pcount + " / " + (numsplines obj) as String
					)
					default: (
						knots = #()
						for s = 1 to numsplines obj do for v in getknotselection obj s do append knots v
						totalKnots = 0
						for s =1 to numsplines obj do totalKnots += numKnots obj s
						segments = #()
						for s = 1 to numsplines obj do for v in getSegSelection obj s do append segments v
						totalSegments = 0
						for s = 1 to numsplines obj do totalSegments += (numSegments obj s)
						printmsg += "Knots: " + totalKnots as String
						printmsg += " | Segments: " + totalSegments as String
						printmsg += " | Spline: " + (numsplines obj) as String
					)
				)
			)
			Line: (
				obj = selection[1]
				case getSelectionLevel selbas of (
					#vertex: (
						knots = #()
						for s = 1 to numsplines obj do for v in getknotselection obj s do append knots v
						totalKnots = 0
						for s =1 to numsplines obj do totalKnots += numKnots obj s
						_pcount = knots.count as String
						printmsg += "Knots: " + _pcount + " / " + totalKnots as String
					)
					#face: (
						segments = #()
						for s = 1 to numsplines obj do for v in getSegSelection obj s do append segments v
						totalSegments = 0
						for s = 1 to numsplines obj do totalSegments += (numSegments obj s)
						_pcount = segments.count as String
						printmsg += "Segments: " + _pcount + " / " + totalSegments as String
					)
					#edge: (
						splines = getSplineSelection obj
						_pcount = splines.count as String
						printmsg += "Spline: " + _pcount + " / " + (numsplines obj) as String
					)
					default: (
						knots = #()
						for s = 1 to numsplines obj do for v in getknotselection obj s do append knots v
						totalKnots = 0
						for s =1 to numsplines obj do totalKnots += numKnots obj s
						segments = #()
						for s = 1 to numsplines obj do for v in getSegSelection obj s do append segments v
						totalSegments = 0
						for s = 1 to numsplines obj do totalSegments += (numSegments obj s)
						printmsg += "Knots: " + totalKnots as String
						printmsg += " | Segments: " + totalSegments as String
						printmsg += " | Spline: " + (numsplines obj) as String
					)
				)
			)
			Default: (
				classes = #()
				for i in getCurrentSelection() where isValidNode i do ( appendIfUnique classes (superClassOf i) )
				selArray = for v = 1 to classes.count collect #()
				totalArray = for v = 1 to classes.count collect #()
				for o in $* where not o.isHiddenInVpt do (
					oc = superClassOf o
					ocp = findItem classes oc
					if ocp != 0 do (
						append totalArray[ocp] o
						if o.isSelected do append selArray[ocp] o
					)
				)
				for c = 1 to classes.count do (
					clas = if classes[c] == GeometryClass then ("Object") else (classes[c] as String)
					clas[1] = toUpper clas[1]
					if selArray[c].count > 1 do clas += "s"
					if c == 1 and printmsg.count > 1 do clas = " | " + clas
					if classes.count == 1 and selArray[c].count == 1 and selArray[c].count == totalArray[c].count then (
						printmsg += selArray[c][1].name as String
					) else (
						printmsg += clas + ":" + selArray[c].count as String + "/" + totalArray[c].count as String
						if c != classes.count do printmsg += " | "
						if classes.count == 1 and selArray[c].count == 1 do ( printmsg2 += selArray[c][1].name as String )
					)
				)
			)
		)
		if subObjectLevel != 0 do gw.wtext [mouse.pos.x+20, mouse.pos.y+25, 0] _pcount color:_color
	) else (
		--“修改”面板堆栈中当前选定为空。
		classes = #()
		for i in getCurrentSelection() where isValidNode i do ( appendIfUnique classes (superClassOf i) )
		selArray = for v = 1 to classes.count collect #()
		totalArray = for v = 1 to classes.count collect #()
		for o in $* where not o.isHiddenInVpt do (
			oc = superClassOf o
			ocp = findItem classes oc
			if ocp != 0 do (
				append totalArray[ocp] o
				if o.isSelected do append selArray[ocp] o
			)
		)
		for c = 1 to classes.count do (
			clas = if classes[c] == GeometryClass then ("Object") else (classes[c] as String)
			clas[1] = toUpper clas[1]
			if selArray[c].count > 1 do clas += "s"
			if c == 1 and printmsg.count > 1 do clas = " | " + clas
			if classes.count == 1 and selArray[c].count == 1 and selArray[c].count == totalArray[c].count then (
				printmsg += selArray[c][1].name as String
			) else (
				printmsg += clas + ":" + selArray[c].count as String + "/" + totalArray[c].count as String
				if c != classes.count do printmsg += " | "
				if classes.count == 1 and selArray[c].count == 1 do ( printmsg2 += selArray[c][1].name as String )
			)
		)
	)
	printmsg += " "
	if subobjectlevel != undefined and subobjectlevel >= 1 do (
		_x_ = (getViewSize()).x; 
		_y_ = (getViewSize()).y
		_hx_ = _x_ / 2
		gw.hPolyline #([_x_-2, _y_-12, 0], [_x_-12, _y_-2, 0], [_x_-2, _y_-2, 0]) true
		gw.hPolyline #([_x_-2, 12, 0], [_x_-12, 2, 0], [_x_-2, 2, 0]) true
		gw.hPolyline #([2, 12, 0], [12, 2, 0], [2, 2, 0]) true
	)
	gw.wtext [((getViewSize()).x - (gw.getTextExtent printmsg).x) / 2, 27, 0] printmsg color:_color
	if printmsg2.count != 0 do (
		gw.wtext [((getViewSize()).x - (gw.getTextExtent printmsg2).x) / 2, 39, 0] printmsg2 color:(color 255 255 255)
	)
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
registerRedrawViewsCallback gw_viewInfo
