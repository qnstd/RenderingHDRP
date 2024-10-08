# Graphi Rendering HDRP

#
## 日志
#

### 1.0.2 [2024-09-29]
> Runtime
>> 1. 增加几何着色器（绒毛）

### 1.0.1 [2024-09-11]
> Runtime
>> 1. 优化 Mth.hlsl 数学操作库，增加可控范围的 PingPong 算法

### 1.0.0 [2024-09-8]
> Editor
>> 1. 增加 HierarchyUtils 工具包，提供在层次列表中创建着色库中的游戏对象
>> 2. 增加 Layer 层级相关操作的工具包
>> 3. 增加 Project 检视板相关操作的工具包。 可在 ProjectUtils 文件中查看
>> 4. 为着色库增加自定义的 Toolbar 工具菜单项，并在 Hierarchy 列表中支持着色库内游戏对象的图标显示
>> 5. 增加着色库工程设置操作检视板，提供适配当前工程的所有操作
>> 6. 为所有着色器增加对应的GUI检视板

> Runtime
>> 1. 增加 Fx 半透明着色库，用于所有特效等半透明的渲染着色器
>> 2. 增加纹理计算着色器，用于在运行时实时创建并生成动态纹理（例如：噪声Noise纹理）等
>> 3. 增加光照类型的着色器（例如：表面法线置换、融合等）
>> 4. 为 ShaderGraph 增加自定义的 Node 节点（例如：CoverColor等）。 所有着色库节点都在 Graphi 节点内。
>> 5. 增加 FullScreen、PostProcess、Sky 等体积渲染着色器，用于后期处理等操作
>> 6. 增加无光渲染着色器（例如：UI、Video等）
>> 7. 增加宇宙空间类型的着色器（例如：行星、日冕、风暴等）。适用于制作宇宙、太空题材的项目
>> 8. 增加基于 Mono 可交互的着色器组件（例如：Shield护盾着色器）
>> 9. 增加运行时图形数据统计组件，可实时检测图形渲染数据信息