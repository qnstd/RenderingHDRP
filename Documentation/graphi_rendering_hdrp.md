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
> 点击 Unity 窗体左上角带有 ***Graphi*** 标签的按钮，

> ![](images/doc1.png)

> 此时会弹出 Project Settings 检视板中的 Graphi 页签。在页签中，点击 ***Set*** 按钮，执行着色库与当前工程进行适配。

> ![](images/doc3.png)

> 执行完毕后，即可使用着色库进行图形相关的操作了。



## 操作项
着色库所有操作项都被包含在 Unity 的菜单栏中。

> Shader : 着色器
>> 1. 在材质中，可动态设置选择的着色器都在 Graphi 路径下。
>> ![](images/doc5.png)
>> 2. 在 ShaderGraph 操作面板中，着色库也提供了特定的 ShaderGraph Node 节点。所有自定义节点也都在 Graphi 页签下。
>> ![](images/doc6.png)
>> 3. 后处理（PostProcess）及全屏处理（FullScreen）的着色器全部绑定在体积（Volume）组件内。


## 其他
##### **[关于 CN.Graphi](https://github.com/qnstd)**