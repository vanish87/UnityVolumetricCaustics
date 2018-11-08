﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;
using UnityTools.Common;

namespace UnityTools.LightCamera
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class CameraRender : MonoBehaviour
    {
        private static readonly int NumberOfRenderTarget = 2;
        [SerializeField] private RenderTexture[] mrtTex = new RenderTexture[NumberOfRenderTarget];
        private RenderBuffer[] mrtRB = new RenderBuffer[NumberOfRenderTarget];


        private Camera targetCamera = null;
        private Shader lightShader = null;

        public RenderTexture[] GBuffer
        {
            get { return this.mrtTex; }
        }

        private void Start()
        {
            this.lightShader = Shader.Find("Custom/RenderToGbuffer");
            Assert.IsNotNull(this.lightShader);

            this.targetCamera = this.GetComponent<Camera>();
            Assert.IsNotNull(this.targetCamera);

            var source = this.targetCamera.targetTexture;
            if(source == null)
            {
                source = new RenderTexture(Screen.width,Screen.height, 24);
            }

            for (var i = 0; i < this.mrtTex.Length; ++i)
            {
                RenderTexUtil.CheckAndRebuild(source, ref this.mrtTex[i]);
                this.mrtRB[i] = mrtTex[i].colorBuffer;
            }

            this.targetCamera.clearFlags = CameraClearFlags.SolidColor;
            this.targetCamera?.SetTargetBuffers(mrtRB, mrtTex[0].depthBuffer);
        }

        private void Update()
        {
            for (var i = 0; i < this.mrtTex.Length; ++i)
            {
                RenderTexUtil.Clear(this.mrtTex[i]);
            }

            this.targetCamera.RenderWithShader(this.lightShader, null);
        }
        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Graphics.Blit(source, destination);
            //Graphics.Blit(this.mrtTex[0], destination);
            //Graphics.Blit(this.mrtTex[1], destination);
        }
    }

}
