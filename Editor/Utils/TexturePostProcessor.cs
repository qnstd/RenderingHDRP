using System.IO;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 纹理资源导入时的相关设置
    /// <para>作者：强辰</para>
    /// </summary>
    public class TexturePostProcessor : AssetPostprocessor
    {
        /// <summary>
        /// 导入纹理时的预处理
        /// </summary>
        private void OnPreprocessTexture()
        {
            GlobalDataSettings gds = GraphiSettings.GlobalSettings;
            if(gds == null) { return; }
           
            TextureImporter importer = (TextureImporter)assetImporter;
            if (importer == null) { return; }

            string filename = Path.GetFileNameWithoutExtension(importer.assetPath);
            if (!string.IsNullOrEmpty(gds.m_UiTexTag) && filename.EndsWith(gds.m_UiTexTag))
                importer.textureType = TextureImporterType.Sprite;
            else if (!string.IsNullOrEmpty(gds.m_NormalTexTag) && filename.EndsWith(gds.m_NormalTexTag))
                importer.textureType = TextureImporterType.NormalMap;
        }
    }
}