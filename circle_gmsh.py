import gmsh
gmsh.initialize()
model_name = "circle_model"
gmsh.model.add(model_name)
#gmsh.model.setDimension(2)

radius = 0.15
center=[0,0]
circle = gmsh.model.occ.addDisk(0,0,0,0.15,0.15)
gmsh.model.occ.synchronize() #同步到模型
gmsh.model.mesh.setOrder(2)
gmsh.model.mesh.setSize(gmsh.model.getEntities(0), 0.0025)  #设置网格尺寸
# 边界物理组
curve_loop = gmsh.model.getBoundary([(2,circle)],oriented=False)
gmsh.model.addPhysicalGroup(1,[curve_loop[0][1]],tag=1)
gmsh.model.setPhysicalName(1,1,"CircleBoundary")  #dim,tag,name
#内部区域物理组
gmsh.model.addPhysicalGroup(2,[circle],tag=2)
gmsh.model.setPhysicalName(2,2,"Domain")
#gmsh.option.setNumber("Mesh.Smoothing", 1000)
#gmsh.model.geo.mesh.setRecombine(2, 1)  #将三角形网格重新组合成四边形网格
gmsh.model.mesh.generate(2)
gmsh.write("circle.msh")

gmsh.fltk.run()  #图形界面显示
gmsh.finalize()  #结束使用gmsh
