# Graphi Rendering HDRP 文档

>
## 目录结构

> Documentation（文档）
 
> Editor（编辑器）

> Runtime（运行时）

> CHANGELOG.md （日志）

> LICENSE.md （许可）

> README.md （自述）

> package.json（配置）


## 部署 
> 用 UnityHub 创建一个 Unity 2022.3.21f1c1 或以上版本的默认3D工程。
> 
> 打开 PackageManager 窗体，点击 **“+”** 号，选择 **git URL** 方式加载着色库的 UPM 包体。***gitURL = https://github.com/qnstd/RenderingHDRP.git***

> ![](images/doc5.png)
> 
> 等待着色库及相关依赖的安装。待安装完毕后，点击菜单 ***[Window/Rendering/HDRP Wizard]***。在弹出的面板中，点击所有 **“Fix”**按钮， 执行 HDRP 高清渲染管线所需的资源及配置对象的创建及部署。
> 
> ![](images/doc6.png) 
> 
> ![](images/doc7.png)

> 操作完毕后，此时在Assets目录下会生成一个HDRP资源配置目录，进入此目录后，有两个文件需要设置。
>> **HDRenderPipelineAsset:** 点击后在Inspector检视板中，选择 LitShaderMode 下拉菜单中的 ForwardOnly 选项卡。 
>
>> ![](images/doc8.png)
>
>> ![](images/doc9.png)
>
>> **HDRenderPipelineGlobalSettings:** 点击后在Inspector检视板中，找到FrameSettings（Default Value）模块，分别将Camera，Realtime Reflection，Baked or Custom Reflection的Rendering/LitShaderMode 的选项卡设置为Forward。 (其中Reflection相关的Rendering的LitShaderMode根据实际情况而定)
>>
>> ![](images/doc10.png)
>
>> *其他选项设置请按照实际情况进行配置，这里不再说明。对于HDRP管线配置及全局帧渲染配置项建议TA来完成。*
>

> 上述已完成HDRP基本的设置操作，接下来点击 Unity 窗体左上角带有 ***Graphi*** 标签的按钮，此时会弹出 ***Project Settings*** 检视板中的 ***Graphi Rendering HDRP*** 页签。在页签中，点击 ***Set*** 按钮，使着色库与当前工程进行适配。

> ![](images/doc1.png)

> 

> ![](images/doc2.png)

> 执行完毕后，即可使用着色库进行图形相关的操作了。



## 操作项
着色库所有操作项都被包含在 Unity 的菜单栏中。

> **Hierarchy**

>> 层次结构中需要创建的游戏对象，都绑定在 GameObject 菜单项中。例如：GameObject/Volume/OccDisplay Volume（创建遮挡显示体积组件）。在 GameObject 支持创建的游戏可通过 ***HierarchyUtils.cs*** 脚本查看。

> **Project**

>> Project工程面板中可创建的资源对象都绑定在 Assets/Create 菜单项中。例如：Assets/Create/Shader/HLSL（创建 HLSL 着色文件）。所有资源对象创建的脚本可在 ***Editor/Shader*** 目录下找到。

> **Shader**
>> 1. 在材质中，可动态设置选择的着色器都在 ***Graphi*** 路径下。
>> ![](images/doc3.png)
>> 2. 在 ***ShaderGraph*** 操作面板中，着色库也提供了特定的 ***ShaderGraph Node*** 节点。所有自定义节点也都在 ***Graphi*** 页签下。
>> ![](images/doc4.png)
>> 3. 后处理（PostProcess）、全屏处理（FullScreen）、天空盒（Sky）等着色器全部绑定在体积（Volume）组件内。

> **Component**

>> 着色库提供了一些组件，其中部分组件是需要配合同名着色器一起使用（例如：Runtime/Components/Shield.cs 组件需要与 Graphi/Fx/Shield 着色器一起使用）。这些组件可在 ***Runtime/Components*** 目录下找到。


## 其他
##### **[关于 CN.Graphi](https://github.com/qnstd)**