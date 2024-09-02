# Graphi Rendering (*HDRP*)

#
## 日志
#

### 1.2.0 

新增着色器
>Video (视频着色器)

>Planetary（行星通用着色器）

>Ring (星体光环着色器)

新增 ShaderGraph 节点
>TriSample（三向采样）

>NormalTriSample（法线-三向采样）

>Fresnel、FresnelLight（菲涅尔边缘光）

新增函数库
>Graphi-Filter.hlsl (滤镜) 

>Tex.hlsl（纹理）

>Fresnel.hlsl（菲涅尔）

>Planet.hlsl（星体）

1. 新增视频播放组件
2. 新增 CS 层数学、视椎体、平面、向量等相关操作的工具包
3. 新增着色库内置的 3D 网格模型
4. 优化 FallbackErr.shader 着色效果
5. 将 RuntimePerformance 中的系统信息分离，并提供对外接口
6. 优化 CoverColor 绘制节点，解决覆盖色贴图中存在灰度值过低的像素，从而导致覆盖上色时出现破点（黑块）问题
7. 优化着色库目录结构，同时删除 Prefabs、Materials 目录，将此目录下的内容改为程序脚本动态创建


### 1.1.11
新增着色器

>LitStandardIridescence （带有薄膜干涉效果的标准光照）；

>LitStandardIridescence2 ；

>LitIridescenceCover （带有覆盖色效果的薄膜干涉类型着色器）；

新增 ShaderGraph 节点

>Gray (灰度处理)；

>MainLight (主光源信息)；

>Iridescence (薄膜干涉)；

>Iridescence2 (薄膜干涉2)；

新增函数库

>Graphi-Light.hlsl (光源) ；

>Iridescence.hlsl (薄膜干涉)；

1. 编辑模式（Editor），增加 Avatar 预览窗体组件及骨骼信息读取组件；
2. 优化 LitStandardCover 着色器，取消 HSBC 模块，同时为每个通道的覆盖色增加亮度控制器；
3. 优化着色器 LitStandardVari 的 ShaderGUI 面板渲染及控制结构；
4. 增加 LOD 组件，并对检视板的操作进行优化；


### 1.1.10
新增着色器

>FastDecal （轻量级贴花投影器）；

>DrawCustomObjectColorAndDepthBuffer (自定义对象的颜色及深度缓冲纹理绘制) ；

>OccDisplay (遮挡显示) ；

>LitStandardCover (带有覆盖色的光照着色器) ；

新增函数库

>GMth.hlsl (数学库) ；

>GNoise.hlsl (噪声库)；

>TextureComputes.compute (动态纹理) ；

新增 ShaderGraph 节点

>ParallaxOccMapping (视差遮蔽映射)；

>TransmissionRefraction (半透明折射)；

>BlendNormal (法线混合)；

>BlendColor (颜色混合)；

>BlendColorKind (颜色混合类型)；

>CoverColor (覆盖色)；

>HSBC (调色器（色相、对比度、明度、饱和度）)；

1. 新增遮挡显示所使用的 CustomPass 触发器预制体；
2. 新增 Graphi 着色库内置 Layer 渲染层级（Edges 及 OccDisplay）；
3. 新增网格混合形变编辑工具及运行时控制器；
4. 新增着色数据提取工具，将 "HDRP/Lit" 内置着色器的着色数据提取到指定的材质内；
5. 优化 Graphi 颜色操作库，增加对 RGB、HSV 等颜色格式及颜色混合操作的相关处理函数；
6. 优化 LitStandardVariant ShaderGraph 着色器，将内部使用的默认节点全部修改为自定义脚本节点，便于后续二次扩展； 
7. 优化着色器构建模块，增加 COMPUTE、SHADERSUBGRAPH 文件类型的构建；
8. Unity 工具栏中增加 Graphi 着色库相关信息并优化着色库部分组件的可视化图标；


### 1.1.9
增加星体着色器

> Moon

> Sun

> CoronaStorm

1. 增加Fx半透明 RainDrop 镜面雨滴着色器；
2. 增加基于 Mipmap 方式的全屏模糊着色器 BlurWithMipmap ;
3. 增加在运行时可动态调整关于品质、后处理渲染等画质相关的 API 接口；
4. 增加3D纹理创建工具；
5. 优化着色器构建模块，增加 HLSL、SHADERGRAPH 文件类型的构建；
6. 优化标准光照着色器模板（手动编写模式[Manual]）的创建工具，调整由模板文件生成新文件的内部结构；
7. 优化输出打印系统，在编辑器内与发布后的程序将显示各自的关键性信息；
8. 优化Twist热扭曲相关的着色器，取消DisableBatching限制标记；
9. 优化Graphi_Color.hlsl接口中Gray灰度计算后的返回值类型；

### 1.1.8
增加表面细节融合类型的相关着色器及材质创建工具

> NormalDisplacement

> NormalBlend

> DecalHybrid

> ClipRGB

> ClipColor

1. 增加运行时可动态修改纹理流相关信息的接口；
2. 调整着色库核心包结构，将CustomPass、Fx目录合并为Gameobjs目录。同时，将与光照相关的 HLSL 脚本从着色器内部分离并独立维护；
3. 调整着色库相关的工具窗体菜单项结构，并将粒子对象查询操作移至到分析器的粒子页签内；
4. 优化护盾着色器，增加交互时的渲染表现及相关控制参数；
5. 优化RuntimePerformance、TextureStreamingGraphics数据信息跟踪窗体的显示方式，并增加额外的信息收集，同时增加快捷键进行快速显示切换；

### 1.1.7
1. 增加 UI 禁用绘制组件 DisableUIDrawRender，取消绘制但保留相应的功能；
2. 增加动态粒子（Draw Dynamic）的合批优化组件 TranslucentBatch；
3. 增加纹理流 TextureStreaming 配置、工具及数据信息统计窗体；
4. 增加后处理着色器 MotionBlur (For Camera)；
5. 调整并优化分析器面板中使用的各种字体，以兼容不同分辨率下的清晰度；
6. 优化 Graphi 着色库的 MenuItem 菜单项结构，将所包含的功能分配到 Unity 各类型菜单项内；
7. 优化 Graphi 着色库全局配置项，调整关于几何渲染中法线相关的参数设置及相关说明。同时，增加纹理相关的配置项；
8. 将着色库设置面板移植到 ProjectSettings 面板中；

### 1.1.6
1. 增加自定义通道全屏着色器 径向模糊 FullScreen (RadialBlur)；
2. 增加 LitStandardVariant 着色器模板。此模板不仅实现了 Unity 内置的 Lit Standard 常规渲染效果，还可以此为基础实现其他的附加自定义渲染效果；
3. 增加 LitStandardVariant 着色器模板的创建工具；
4. 优化自定义通道全屏模糊着色器，增加附加纹理及相关参数，用于增强模糊效果及其质感；
5. 优化设置面板，调整全局渲染配置自定义后处理项的追加判定；

### 1.1.5
新增着色器

> Bloom、Gray、Edges (全屏着色器)

> TwistVert、TwistDouble (特效扭曲着色器)

1. 优化 FullScreen（Blur）全屏模糊着色器的执行性能，并调整 Inspector 操作面板中的显示内容；
2. 优化着色库内的相关命名，由 HDGra 标记的前缀改为 Graphi；
3. 优化当前场景内所有几何着色渲染的移除操作，调整移除时的计算方式；
4. 优化粒子通用材质着色器，将其分为两种类型。分别应用于粒子系统（由着色库创建的带自定义数据的粒子系统对象）及模型的着色；
5. 调整关于着色效果 Hue 的调用方式及应用结构；
6. 优化设置面板，增加 Graphi 着色库的应用环境监测模块；

### 1.1.4
1. 优化分析器，增加 “着色器”、“粒子系统最大粒子数及网格” 分析模块；
2. 优化运行时监测器，增加动、静态及 GPU 实例合批信息；
3. 优化在Editor模式下显示网格及网格法线的快捷键；

### 1.1.3
1. 增加 RuntimePerformance 运行时性能监测器；
2. 增加 分析器 操作面板；
3. 增加子弹类着色器 (Bullet.shader) 及快速创建对应材质工具；

### 1.1.2
1. 优化 Graphi_Color.hlsl 文件，增加颜色相关的处理函数。同时，对获取曝光及反曝光系数的操作函数参数进行调整，由 'float4' 类型改为 'float3'；
2. 优化 Graphi/Lit/Layered 分层渲染着色器，对基础颜色值进行颜色空间优化；
3. 优化 GraphicsInclude 列表，将原有的 Outline.shader 着色器移除；
4. 增加 UiVFX 视觉效果着色器，增强传统 UGUI 的 Image 及 Text（Legacy）组件；

### 1.1.1
1. 增加标准光照前向渲染着色器模板（LitStandard Template）及相关操作的 HLSL 文件，用于编写自定义含有光照模型的着色器。同时，增加由模板文件快速创建自定义着色器工具；
2. 增加法线融合操作库（Graphi-BlendNormal.hlsl）； 
3. 增加自定义分层渲染着色器（LayeredLit），代替 HDRP 环境下默认的 LayeredLit 着色器；
4. 增加着色器在无法正常渲染时启用的 Fallback 默认渲染着色器（FallbackErr），其中着色器路径：Hidden/Graphi/FallbackErr；
5. 增加 Graphi 着色库组件在 SceneView 模式下的定制化图标；
6. 调整 Graphi MenuItem 菜单项结构；
7. 调整 Graphi 着色库操作工具的快捷键，同时增加快捷键控制面板；

### 1.1.0
1. 增加新的渲染模块-星球。同时增加星球大气散射着色器（Planet AtmoSphere）；
2. 增加漫反射贴图转法线贴图工具；
3. 增加颜色相关操作的 HLSL 文件，整合着色库关于颜色变换操作事项；
4. 增加模型几何渲染着色器（顶点法线、网格等。若场景存在一盏平行光，则法线及网格的显示效果会伴随此平行光的影响）及菜单操作项；
5. 增加 Graphi 着色库在 Editor 模式下的全局渲染参数配置；
6. 优化 Graphi 着色库的材质快速创建方式；
7. 优化特效雾在摄像机旋转、位移等变换时不被裁剪，且效果保持不变。裁剪判定方式由 CullMode 更改为 FrontFace。同时关闭场景雾对特效雾的影响；
8. 优化着色器菜单列表结构；

### 1.0.9
1. 增加新的着色器 - 场景雾效（Fog）；
2. 增加场景雾效材质菜单项及创建工具；

### 1.0.8
1. 优化热扭曲效果。修改热扭曲的效果计算公式及对应的 Inspector 控制面板参数、说明信息；
2. 优化日志系统。修改控制台输出内容的显示模式及缓存数量的设置方式；
3. 优化着色库渲染脚本引用管理。增加自定义的 HLSL 文件，实现模块化脚本处理，并以 Include 方式引用。同时增加自定义 HLSL 文件创建工具；
4. 优化材质面板中带有 Foldout 属性默认的折叠状态，当前可通过 Shader 文件的 Foldout 进行初始化默认设置；

### 1.0.7
1. 优化着色器 Fx 路径下的特效、粒子渲染脚本，兼容并支持 DOTs ECSGraphics 混合模式渲染；
2. 优化特定粒子系统对象的创建工具，修改自定义数据的数据类型，同时在顶点数据流中增加切线数据，用于计算切线到世界坐标系的转换矩阵；
3. 优化 Graphi 着色库系统设置工具，增加对工程首次使用着色库的一键初始化设置项（GraphicsInclude追加、自定义后处理项追加）；
4. 优化 Graphi 着色库 ShaderFind 运行时脚本，修改 Editor 及 Runtime 模式下的操作方案；
5. 优化特效通用着色器对主贴图的颜色计算，同时修改主贴图亮度调节算法；
6. 删除未使用的 Using 指令。在Unity高版本中，未使用的 Using 指令中存在有不兼容的问题；
7. 新增天空盒着色器 HDRI SkyFloat；

### 1.0.6
1. 优化 Graphi 渲染库的 MenuItem 菜单项，并增加【设置】选项卡；
2. 优化 GraphiMachine 管理器的初始化函数，增加全局自定义渲染通道的初始化；
3. 渲染库增加内置特定渲染层（LayerMask），用于渲染包含透明通道的热扭曲；
4. 增加屏幕级热扭曲渲染效果（Twist），并优化渲染效果；
5. 特效通用着色器为扭曲遮罩纹理增加 UV 流动速度参数，并将增加的参数与扭曲纹理 UV 流动速度参数进行合并到一个Vector参数中；
6. 增加新的粒子闪电特效（Lightning）；

### 1.0.5
1. 优化特效通用着色器，为主贴图增加曝光度计算。可增强激光、爆破类特效的质感；
2. 修改工程配置中Tonemapping类型，由ACES改为Custom。解决并兼容特效、场景、模型制作时的颜色差异化；
3. 增加全屏自定义效果-高斯双线性模糊（Blur）；
4. 增加着色器编辑工具（包含GraphicsInclude、构建等操作）；
5. 增加 AssetBundle 浏览器及 MissingMono 查询工具；

### 1.0.4
1. 修改全局默认配置中的 Exposure、Tonemapping、Bloom 参数；
2. 增加场景天空盒处理工具（6面纹理转Hdr或Exr纹理）；

### 1.0.3
1. 针对特效通用着色器，增加新的渲染功能（溶解、扭曲、顶点动画）；
2. 增加特效通用着色器的 ShaderGUI，用于动态控制着色器的变体；
3. 增加对特效粒子着色器的MenuItem菜单项（创建粒子游戏对象、特效通用材质的创建）工具；

### 1.0.2
1. 增加 HDRP 渲染管线下自定义特效通用着色器（ParticleStandard）；
2. 对特效通用着色器主贴图增加UV偏移设置。同时为菲涅尔边缘光增加渲染类型，以适应不同环境下的效果；
3. 设置全局配置中光源相关信息。针对点光源、聚光灯实时混合照明形成的ShadowAtlas尺寸调整为4096，面光源调整为4096。<br>同时，对光源品质进行调整。从low到very high的等级以此是512,1024,2048,4096；

### 1.0.1
1. 增加后期处理效果-色相（Hue）。此后处理的执行节点在Unity渲染管线的后处理之后进行，对最终的图像进行Hue调整；
2. 调整全局配置中关于Shadow同屏数量及分辨率尺寸；
3. 在全局配置的 Volume Diffsion 中增加两套 SSS 效果配置（SkinDiffusion、FoliageDiffusion）；

### 1.0.0
1. 增加 HDRP 渲染默认配置文件，并对默认配置中的参数进行调优设置；
2. 创建自定义 HDRP 渲染库-Graphi库，并为库设置相关结构；
3. 增加 Runtime 文件（Lg、GraphiMachine管理器等）；
4. 增加 UI 层的文本描边着色器（Outline.shader)；
5. 创建 Graphi 库的 Editor 结构并编写通用的操作函数及全局变量；