using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Reflection;
using System.Collections.Generic;
using System.IO;

public class AssetNameChecker : AssetPostprocessor
{
    static bool verify(string filename){
        bool result = true;
        for (int i = 0; i < filename.Length; i++)
        {
            if ((int)filename[i] > 127)
            {
                result = false;
                break;
            }
                
        }
        return !filename.Contains(" ") && !filename.Contains(" ") && result;
	}
	
	static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths){
        foreach (string str in importedAssets)
        {
            if (!verify(str))
            {
                EditorUtility.DisplayDialog("导入资源时有误", "检查到文件名中含有非法字符，请删除，然后后重命名该文件，再次导入\n文件名为："+str+"\n", "确认");
            }
            
        }
        
    }
}

