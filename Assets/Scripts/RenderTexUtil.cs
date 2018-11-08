﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace UnityTools.Common
{
    public class RenderTexUtil
    {
        static public void Rebuild(RenderTexture src, ref RenderTexture target)
        {
            if (target != null)
            {
                Object.Destroy(target);
                target = null;
            }
            var desc = src.descriptor; 
            desc.enableRandomWrite = true;
            desc.colorFormat = RenderTextureFormat.ARGBFloat;
            target = new RenderTexture(desc);
            target.Create();
        }

        static public bool ShouldRebuildTarget(RenderTexture src, RenderTexture target)
        {
            return src != null && (target == null || target.width != src.width || target.height != src.height);
        }

        static public void CheckAndRebuild(RenderTexture src, ref RenderTexture target)
        {
            if (ShouldRebuildTarget(src, target))
            {
                Rebuild(src, ref target);
            }
        }

        static public void Clear(RenderTexture target)
        {
            if (target == null) return;
            var old = RenderTexture.active;
            RenderTexture.active = target;
            GL.Clear(true, true, Color.clear);
            RenderTexture.active = old;
        }

        static public void Destory(RenderTexture target)
        {
            if (target != null)
            {
                Object.Destroy(target);
                target = null;
            }
        }

        public static void savePng(RenderTexture rt, string path)
        {
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
            RenderTexture.active = rt;
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            byte[] bytes = tex.EncodeToPNG();
            Object.Destroy(tex);
            File.WriteAllBytes(Application.dataPath + $"{path}.png", bytes);
        }
    }
}
